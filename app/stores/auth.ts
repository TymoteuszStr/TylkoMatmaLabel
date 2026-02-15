import { defineStore } from "pinia";
import type { User } from "@supabase/supabase-js";
import type { UserProfile, UserRole } from "~/types/database";

export const useAuthStore = defineStore("auth", () => {
  const supabase = useSupabaseClient();
  const user = useSupabaseUser();

  // State
  const profile = ref<UserProfile | null>(null);
  const loading = ref(false);
  const initialized = ref(false);

  // Computed
  const isAuthenticated = computed(() => !!user.value);
  const isAdmin = computed(() => profile.value?.role === "admin");
  const isStudent = computed(() => profile.value?.role === "student");
  const userRole = computed(() => profile.value?.role || null);

  // Actions
  async function initialize() {
    if (initialized.value) return;

    loading.value = true;
    try {
      if (user.value) {
        await fetchProfile();
      }
      initialized.value = true;
    } catch (error) {
      console.error("Failed to initialize auth:", error);
    } finally {
      loading.value = false;
    }
  }

  async function fetchProfile() {
    if (!user.value || !user.value.sub) {
      profile.value = null;
      return;
    }

    try {
      const { data, error } = await supabase
        .from("user_profiles")
        .select("*")
        .eq("id", user.value.sub)
        .single();

      if (error) {
        // If profile doesn't exist, create one
        if (error.code === "PGRST116") {
          await createProfile(user.value);
          await fetchProfile();
          return;
        }
        throw error;
      }

      profile.value = data;
    } catch (error) {
      console.error("Failed to fetch profile:", error);
      profile.value = null;
    }
  }

  async function createProfile(authUser: User, role: UserRole = "student") {
    try {
      const { error } = await supabase.from("user_profiles").insert({
        id: authUser.id,
        display_name: authUser.email?.split("@")[0] || "User",
        role,
        preferences: {},
      });

      if (error) throw error;
    } catch (error) {
      console.error("Failed to create profile:", error);
      throw error;
    }
  }

  async function signIn(email: string, password: string) {
    loading.value = true;
    try {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) throw error;

      await fetchProfile();
      return { success: true };
    } catch (error: any) {
      console.error("Sign in failed:", error);
      return {
        success: false,
        error: error.message || "Błąd logowania",
      };
    } finally {
      loading.value = false;
    }
  }

  async function signUp(email: string, password: string, displayName?: string) {
    loading.value = true;
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            display_name: displayName || email.split("@")[0],
          },
        },
      });

      if (error) throw error;

      if (data.user) {
        await createProfile(data.user, "student");
        await fetchProfile();
      }

      return { success: true };
    } catch (error: any) {
      console.error("Sign up failed:", error);
      return {
        success: false,
        error: error.message || "Błąd rejestracji",
      };
    } finally {
      loading.value = false;
    }
  }

  async function signInWithGoogle() {
    loading.value = true;
    try {
      const { error } = await supabase.auth.signInWithOAuth({
        provider: "google",
        options: {
          redirectTo: `${window.location.origin}/auth/callback`,
        },
      });

      if (error) throw error;

      return { success: true };
    } catch (error: any) {
      console.error("Google sign in failed:", error);
      loading.value = false;
      return {
        success: false,
        error: error.message || "Błąd logowania przez Google",
      };
    }
  }

  async function signOut() {
    loading.value = true;
    try {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;

      profile.value = null;
      return { success: true };
    } catch (error: any) {
      console.error("Sign out failed:", error);
      return {
        success: false,
        error: error.message || "Błąd wylogowania",
      };
    } finally {
      loading.value = false;
    }
  }

  async function updateProfile(updates: Partial<UserProfile>) {
    if (!user.value) return { success: false, error: "Not authenticated" };

    loading.value = true;
    try {
      const { error } = await supabase
        .from("user_profiles")
        .update(updates)
        .eq("id", user.value.sub);

      if (error) throw error;

      await fetchProfile();
      return { success: true };
    } catch (error: any) {
      console.error("Failed to update profile:", error);
      return {
        success: false,
        error: error.message || "Błąd aktualizacji profilu",
      };
    } finally {
      loading.value = false;
    }
  }

  // Watch for auth state changes
  watch(user, async (newUser) => {
    if (newUser) {
      await fetchProfile();
    } else {
      profile.value = null;
    }
  });

  return {
    // State
    user,
    profile,
    loading,
    initialized,

    // Computed
    isAuthenticated,
    isAdmin,
    isStudent,
    userRole,

    // Actions
    initialize,
    fetchProfile,
    signIn,
    signInWithGoogle,
    signUp,
    signOut,
    updateProfile,
  };
});
