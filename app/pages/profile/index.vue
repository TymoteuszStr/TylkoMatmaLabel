<template>
  <div class="container mx-auto px-4 py-8">
    <div class="mx-auto max-w-4xl">
      <!-- Page Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
          Mój profil
        </h1>
        <p class="mt-2 text-gray-600 dark:text-gray-400">
          Zarządzaj swoim kontem i ustawieniami
        </p>
      </div>

      <!-- Profile Overview Card -->
      <ClientOnly>
        <UCard class="mb-6">
          <template #header>
            <div class="flex items-center justify-between">
              <h2 class="text-xl font-semibold">Informacje o koncie</h2>
              <UBadge
                :color="isAdmin ? 'red' : 'blue'"
                variant="subtle"
                size="lg"
              >
                {{ isAdmin ? 'Administrator' : 'Uczeń' }}
              </UBadge>
            </div>
          </template>

          <div class="flex flex-col items-center gap-6 sm:flex-row sm:items-start">
            <!-- Avatar -->
            <div class="flex flex-col items-center gap-3">
              <UAvatar
                :src="profile?.avatar_url || undefined"
                :alt="profile?.display_name || 'User'"
                size="3xl"
              />
              <UButton
                size="sm"
                color="gray"
                variant="outline"
                @click="isEditingAvatar = true"
              >
                Zmień zdjęcie
              </UButton>
            </div>

            <!-- User Info -->
            <div class="flex-1 space-y-4">
              <div>
                <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
                  Nazwa wyświetlana
                </label>
                <p class="mt-1 text-lg text-gray-900 dark:text-white">
                  {{ profile?.display_name || 'Brak nazwy' }}
                </p>
              </div>
              
              <div>
                <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
                  Email
                </label>
                <p class="mt-1 text-lg text-gray-900 dark:text-white">
                  {{ user?.email }}
                </p>
              </div>

              <div>
                <label class="text-sm font-medium text-gray-700 dark:text-gray-300">
                  Data dołączenia
                </label>
                <p class="mt-1 text-gray-600 dark:text-gray-400">
                  {{ formatDate(profile?.created_at) }}
                </p>
              </div>

              <div class="flex gap-2">
                <UButton
                  color="primary"
                  @click="isEditingProfile = true"
                >
                  Edytuj profil
                </UButton>
                <UButton
                  color="gray"
                  variant="outline"
                  @click="isChangingPassword = true"
                >
                  Zmień hasło
                </UButton>
              </div>
            </div>
          </div>
        </UCard>
      </ClientOnly>

      <!-- Statistics Cards -->
      <ClientOnly>
        <div class="mb-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <UCard>
            <div class="flex items-center gap-4">
              <div class="rounded-lg bg-primary-100 p-3 dark:bg-primary-900">
                <UIcon
                  name="i-heroicons-academic-cap"
                  class="text-2xl text-primary-600 dark:text-primary-400"
                />
              </div>
              <div>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  Ukończone tematy
                </p>
                <p class="text-2xl font-bold text-gray-900 dark:text-white">
                  {{ stats.completedTopics }}
                </p>
              </div>
            </div>
          </UCard>

          <UCard>
            <div class="flex items-center gap-4">
              <div class="rounded-lg bg-green-100 p-3 dark:bg-green-900">
                <UIcon
                  name="i-heroicons-check-badge"
                  class="text-2xl text-green-600 dark:text-green-400"
                />
              </div>
              <div>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  Zdane testy
                </p>
                <p class="text-2xl font-bold text-gray-900 dark:text-white">
                  {{ stats.passedTests }}
                </p>
              </div>
            </div>
          </UCard>

          <UCard>
            <div class="flex items-center gap-4">
              <div class="rounded-lg bg-orange-100 p-3 dark:bg-orange-900">
                <UIcon
                  name="i-heroicons-fire"
                  class="text-2xl text-orange-600 dark:text-orange-400"
                />
              </div>
              <div>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  Dni z rzędu
                </p>
                <p class="text-2xl font-bold text-gray-900 dark:text-white">
                  {{ stats.streak }}
                </p>
              </div>
            </div>
          </UCard>
        </div>
      </ClientOnly>

      <!-- Account Actions -->
      <ClientOnly>
        <UCard>
          <template #header>
            <h2 class="text-xl font-semibold">Ustawienia konta</h2>
          </template>

          <div class="space-y-4">
            <div class="flex items-center justify-between border-b border-gray-200 pb-4 dark:border-gray-700">
              <div>
                <h3 class="font-medium text-gray-900 dark:text-white">
                  Powiadomienia email
                </h3>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  Otrzymuj powiadomienia o nowych materiałach
                </p>
              </div>
              <UToggle
                v-model="emailNotifications"
                @update:model-value="updateNotificationSettings"
              />
            </div>

            <div class="flex items-center justify-between">
              <div>
                <h3 class="font-medium text-gray-900 dark:text-white">
                  Usuń konto
                </h3>
                <p class="text-sm text-gray-600 dark:text-gray-400">
                  Trwale usuń swoje konto i wszystkie dane
                </p>
              </div>
              <UButton
                color="red"
                variant="outline"
                @click="isConfirmingDelete = true"
              >
                Usuń konto
              </UButton>
            </div>
          </div>
        </UCard>
      </ClientOnly>
    </div>

    <!-- Edit Profile Modal -->
    <UModal v-model="isEditingProfile">
      <UCard>
        <template #header>
          <h3 class="text-lg font-semibold">Edytuj profil</h3>
        </template>

        <form class="space-y-4" @submit.prevent="handleUpdateProfile">
          <UFormGroup label="Nazwa wyświetlana" name="displayName" required>
            <UInput
              v-model="editForm.displayName"
              placeholder="Twoja nazwa"
              size="lg"
              :disabled="updateLoading"
            />
          </UFormGroup>

          <UAlert
            v-if="updateError"
            color="red"
            variant="subtle"
            :title="updateError"
            icon="i-heroicons-exclamation-circle"
          />

          <UAlert
            v-if="updateSuccess"
            color="green"
            variant="subtle"
            title="Profil zaktualizowany pomyślnie!"
            icon="i-heroicons-check-circle"
          />

          <div class="flex justify-end gap-2">
            <UButton
              color="gray"
              variant="outline"
              :disabled="updateLoading"
              @click="isEditingProfile = false"
            >
              Anuluj
            </UButton>
            <UButton
              type="submit"
              color="primary"
              :loading="updateLoading"
              :disabled="!editForm.displayName"
            >
              Zapisz zmiany
            </UButton>
          </div>
        </form>
      </UCard>
    </UModal>

    <!-- Change Avatar Modal -->
    <UModal v-model="isEditingAvatar">
      <UCard>
        <template #header>
          <h3 class="text-lg font-semibold">Zmień zdjęcie profilowe</h3>
        </template>

        <form class="space-y-4" @submit.prevent="handleUpdateAvatar">
          <UFormGroup
            label="URL zdjęcia"
            name="avatarUrl"
            help="Wklej link do swojego zdjęcia profilowego"
          >
            <UInput
              v-model="editForm.avatarUrl"
              placeholder="https://example.com/avatar.jpg"
              size="lg"
              :disabled="updateLoading"
            />
          </UFormGroup>

          <div v-if="editForm.avatarUrl" class="flex justify-center">
            <UAvatar
              :src="editForm.avatarUrl"
              alt="Podgląd"
              size="2xl"
            />
          </div>

          <UAlert
            v-if="updateError"
            color="red"
            variant="subtle"
            :title="updateError"
            icon="i-heroicons-exclamation-circle"
          />

          <UAlert
            v-if="updateSuccess"
            color="green"
            variant="subtle"
            title="Zdjęcie zaktualizowane pomyślnie!"
            icon="i-heroicons-check-circle"
          />

          <div class="flex justify-end gap-2">
            <UButton
              color="gray"
              variant="outline"
              :disabled="updateLoading"
              @click="isEditingAvatar = false"
            >
              Anuluj
            </UButton>
            <UButton
              type="submit"
              color="primary"
              :loading="updateLoading"
            >
              Zapisz zmiany
            </UButton>
          </div>
        </form>
      </UCard>
    </UModal>

    <!-- Change Password Modal -->
    <UModal v-model="isChangingPassword">
      <UCard>
        <template #header>
          <h3 class="text-lg font-semibold">Zmień hasło</h3>
        </template>

        <form class="space-y-4" @submit.prevent="handleChangePassword">
          <UFormGroup label="Nowe hasło" name="password" required>
            <UInput
              v-model="passwordForm.newPassword"
              type="password"
              placeholder="••••••••"
              size="lg"
              :disabled="passwordLoading"
              autocomplete="new-password"
            />
          </UFormGroup>

          <UFormGroup label="Potwierdź hasło" name="confirmPassword" required>
            <UInput
              v-model="passwordForm.confirmPassword"
              type="password"
              placeholder="••••••••"
              size="lg"
              :disabled="passwordLoading"
              autocomplete="new-password"
            />
          </UFormGroup>

          <UAlert
            v-if="passwordError"
            color="red"
            variant="subtle"
            :title="passwordError"
            icon="i-heroicons-exclamation-circle"
          />

          <UAlert
            v-if="passwordSuccess"
            color="green"
            variant="subtle"
            title="Hasło zmienione pomyślnie!"
            icon="i-heroicons-check-circle"
          />

          <div class="flex justify-end gap-2">
            <UButton
              color="gray"
              variant="outline"
              :disabled="passwordLoading"
              @click="isChangingPassword = false"
            >
              Anuluj
            </UButton>
            <UButton
              type="submit"
              color="primary"
              :loading="passwordLoading"
              :disabled="!passwordForm.newPassword || !passwordForm.confirmPassword"
            >
              Zmień hasło
            </UButton>
          </div>
        </form>
      </UCard>
    </UModal>

    <!-- Delete Account Confirmation Modal -->
    <UModal v-model="isConfirmingDelete">
      <UCard>
        <template #header>
          <div class="flex items-center gap-2 text-red-600">
            <UIcon name="i-heroicons-exclamation-triangle" class="text-xl" />
            <h3 class="text-lg font-semibold">Usuń konto</h3>
          </div>
        </template>

        <div class="space-y-4">
          <p class="text-gray-700 dark:text-gray-300">
            Czy na pewno chcesz usunąć swoje konto? Ta operacja jest nieodwracalna
            i spowoduje trwałe usunięcie wszystkich Twoich danych, w tym:
          </p>

          <ul class="list-inside list-disc space-y-1 text-sm text-gray-600 dark:text-gray-400">
            <li>Postępów w nauce</li>
            <li>Wyników testów</li>
            <li>Ustawień konta</li>
            <li>Wszystkich innych danych osobowych</li>
          </ul>

          <UAlert
            color="red"
            variant="soft"
            title="Tej operacji nie można cofnąć!"
            icon="i-heroicons-exclamation-triangle"
          />

          <div class="flex justify-end gap-2">
            <UButton
              color="gray"
              variant="outline"
              @click="isConfirmingDelete = false"
            >
              Anuluj
            </UButton>
            <UButton
              color="red"
              :loading="deleteLoading"
              @click="handleDeleteAccount"
            >
              Tak, usuń moje konto
            </UButton>
          </div>
        </div>
      </UCard>
    </UModal>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: 'auth',
})

const { user, profile, isAdmin, updateProfile, signOut } = useAuth()
const supabase = useSupabaseClient()
const router = useRouter()
const toast = useToast()

// State
const isEditingProfile = ref(false)
const isEditingAvatar = ref(false)
const isChangingPassword = ref(false)
const isConfirmingDelete = ref(false)
const emailNotifications = ref(true)

const updateLoading = ref(false)
const updateError = ref('')
const updateSuccess = ref(false)

const passwordLoading = ref(false)
const passwordError = ref('')
const passwordSuccess = ref(false)

const deleteLoading = ref(false)

// Stats
const stats = ref({
  completedTopics: 0,
  passedTests: 0,
  streak: 0,
})

// Forms
const editForm = reactive({
  displayName: '',
  avatarUrl: '',
})

const passwordForm = reactive({
  newPassword: '',
  confirmPassword: '',
})

// Fetch user statistics
const fetchStats = async () => {
  if (!user.value) return

  try {
    // Fetch completed topics count
    const { count: topicsCount } = await supabase
      .from('user_progress')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', user.value.id)
      .eq('status', 'completed')

    // Fetch passed tests count
    const { count: testsCount } = await supabase
      .from('test_attempts')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', user.value.id)
      .gte('score', 60) // Assuming 60% is passing score

    stats.value.completedTopics = topicsCount || 0
    stats.value.passedTests = testsCount || 0
    
    // Calculate streak (simplified - just days since last activity)
    const { data: recentProgress } = await supabase
      .from('user_progress')
      .select('last_accessed_at')
      .eq('user_id', user.value.id)
      .order('last_accessed_at', { ascending: false })
      .limit(1)

    if (recentProgress && recentProgress.length > 0) {
      const item = recentProgress[0] as { last_accessed_at: string }
      if (item?.last_accessed_at) {
        const lastAccess = new Date(item.last_accessed_at)
        const now = new Date()
        const diffDays = Math.floor((now.getTime() - lastAccess.getTime()) / (1000 * 60 * 60 * 24))
        stats.value.streak = diffDays === 0 ? 1 : 0
      }
    }
  } catch (error) {
    console.error('Failed to fetch stats:', error)
  }
}

// Initialize forms
watch(() => profile.value, (newProfile) => {
  if (newProfile) {
    editForm.displayName = newProfile.display_name || ''
    editForm.avatarUrl = newProfile.avatar_url || ''
    
    // Load email notification preference from preferences
    try {
      if (newProfile.preferences && typeof newProfile.preferences === 'object' && !Array.isArray(newProfile.preferences)) {
        const prefs = newProfile.preferences as Record<string, unknown>
        emailNotifications.value = prefs?.emailNotifications !== false
      }
    } catch {
      // Ignore preference loading errors
    }
  }
}, { immediate: true })

// Update profile
const handleUpdateProfile = async () => {
  updateLoading.value = true
  updateError.value = ''
  updateSuccess.value = false

  const result = await updateProfile({
    display_name: editForm.displayName,
  })

  updateLoading.value = false

  if (result.success) {
    updateSuccess.value = true
    toast.add({
      title: 'Sukces',
      description: 'Profil zaktualizowany pomyślnie',
      color: 'green',
    })
    setTimeout(() => {
      isEditingProfile.value = false
      updateSuccess.value = false
    }, 1500)
  } else {
    updateError.value = result.error || 'Błąd aktualizacji profilu'
  }
}

// Update avatar
const handleUpdateAvatar = async () => {
  updateLoading.value = true
  updateError.value = ''
  updateSuccess.value = false

  const result = await updateProfile({
    avatar_url: editForm.avatarUrl || null,
  })

  updateLoading.value = false

  if (result.success) {
    updateSuccess.value = true
    toast.add({
      title: 'Sukces',
      description: 'Zdjęcie zaktualizowane pomyślnie',
      color: 'green',
    })
    setTimeout(() => {
      isEditingAvatar.value = false
      updateSuccess.value = false
    }, 1500)
  } else {
    updateError.value = result.error || 'Błąd aktualizacji zdjęcia'
  }
}

// Change password
const handleChangePassword = async () => {
  passwordError.value = ''
  passwordSuccess.value = false

  if (passwordForm.newPassword !== passwordForm.confirmPassword) {
    passwordError.value = 'Hasła nie są identyczne'
    return
  }

  if (passwordForm.newPassword.length < 6) {
    passwordError.value = 'Hasło musi mieć co najmniej 6 znaków'
    return
  }

  passwordLoading.value = true

  try {
    const { error } = await supabase.auth.updateUser({
      password: passwordForm.newPassword,
    })

    if (error) throw error

    passwordSuccess.value = true
    toast.add({
      title: 'Sukces',
      description: 'Hasło zmienione pomyślnie',
      color: 'green',
    })

    // Reset form
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''

    setTimeout(() => {
      isChangingPassword.value = false
      passwordSuccess.value = false
    }, 1500)
  } catch (error) {
    console.error('Failed to change password:', error)
    passwordError.value = error instanceof Error ? error.message : 'Błąd zmiany hasła'
  } finally {
    passwordLoading.value = false
  }
}

// Update notification settings
const updateNotificationSettings = async (value: boolean) => {
  const currentPrefs = (profile.value?.preferences && typeof profile.value.preferences === 'object' && !Array.isArray(profile.value.preferences))
    ? profile.value.preferences as Record<string, unknown>
    : {}
  
  await updateProfile({
    preferences: {
      ...currentPrefs,
      emailNotifications: value,
    },
  })

  toast.add({
    title: 'Sukces',
    description: 'Ustawienia powiadomień zaktualizowane',
    color: 'green',
  })
}

// Delete account
const handleDeleteAccount = async () => {
  deleteLoading.value = true

  try {
    // Delete user profile
    if (user.value) {
      const { error: profileError } = await supabase
        .from('user_profiles')
        .delete()
        .eq('id', user.value.id)

      if (profileError) throw profileError

      // Sign out and delete auth user (admin function would be needed for full deletion)
      await signOut()
      
      toast.add({
        title: 'Sukces',
        description: 'Konto zostało usunięte',
        color: 'green',
      })

      router.push('/')
    }
  } catch (error) {
    console.error('Failed to delete account:', error)
    toast.add({
      title: 'Błąd',
      description: error instanceof Error ? error.message : 'Nie udało się usunąć konta',
      color: 'red',
    })
  } finally {
    deleteLoading.value = false
    isConfirmingDelete.value = false
  }
}

// Format date
const formatDate = (dateString?: string) => {
  if (!dateString) return 'Nie określono'
  
  const date = new Date(dateString)
  return date.toLocaleDateString('pl-PL', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

// Fetch stats on mount
onMounted(() => {
  fetchStats()
})
</script>
