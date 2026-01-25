export const useAuth = () => {
  const authStore = useAuthStore()

  return {
    user: computed(() => authStore.user),
    profile: computed(() => authStore.profile),
    loading: computed(() => authStore.loading),
    isAuthenticated: computed(() => authStore.isAuthenticated),
    isAdmin: computed(() => authStore.isAdmin),
    isStudent: computed(() => authStore.isStudent),
    userRole: computed(() => authStore.userRole),

    signIn: authStore.signIn,
    signUp: authStore.signUp,
    signOut: authStore.signOut,
    updateProfile: authStore.updateProfile,
    initialize: authStore.initialize,
  }
}

