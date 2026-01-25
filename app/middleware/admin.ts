export default defineNuxtRouteMiddleware(async (to) => {
  const user = useSupabaseUser()
  const supabase = useSupabaseClient()

  // Check authentication first
  if (!user.value) {
    return navigateTo({
      path: '/auth/login',
      query: { redirect: to.fullPath },
    })
  }

  // Check if user has admin role
  try {
    const { data: profile, error } = await supabase
      .from('user_profiles')
      .select('role')
      .eq('id', user.value.sub)
      .single()

    if (error || !profile || profile.role !== 'admin') {
      return navigateTo('/')
    }
  } catch (error) {
    console.error('Admin check failed:', error)
    return navigateTo('/')
  }
})

