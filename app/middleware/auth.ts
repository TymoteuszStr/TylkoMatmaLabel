export default defineNuxtRouteMiddleware((to) => {
  const user = useSupabaseUser()

  // If not authenticated and trying to access protected route
  if (!user.value) {
    return navigateTo({
      path: '/auth/login',
      query: { redirect: to.fullPath },
    })
  }
})

