# Profile Creation Fix

## Problem
When users registered for a new account, their user profile was not being created properly due to missing database policies and lack of automatic profile creation.

## Root Causes

1. **Missing RLS Policy**: The `user_profiles` table had Row Level Security (RLS) policies for SELECT and UPDATE, but was missing an INSERT policy that would allow users to create their own profile.

2. **No Database Trigger**: Profile creation was only handled in the application code, which is less reliable than using a database trigger that automatically creates profiles when users sign up.

## Solution

### 1. Database Changes (Required)

Run the SQL migration in `fix-profile-creation.sql` in your Supabase SQL Editor. This will:

- ✅ Add INSERT policy allowing users to create their own profiles
- ✅ Add INSERT policy allowing admins to create any profile
- ✅ Create a database trigger that automatically creates a profile when a new user signs up
- ✅ Grant necessary permissions for the trigger to work

**To apply:**
```bash
# Copy the contents of fix-profile-creation.sql
# Paste into Supabase Dashboard > SQL Editor
# Run the query
```

### 2. Application Changes (Already Applied)

The auth store has been updated to:

- ✅ Wait for the database trigger to create the profile (with a small delay)
- ✅ Check if profile exists after signup
- ✅ Create profile manually as fallback if trigger fails
- ✅ Handle duplicate key errors gracefully (ignore if profile already exists)

## How It Works

### New User Registration Flow

1. User fills out registration form with email, password, and display name
2. Application calls `signUp()` function
3. Supabase Auth creates the user in `auth.users` table
4. **Database trigger automatically creates profile** in `user_profiles` table
5. Application waits 500ms for trigger to complete
6. Application fetches the newly created profile
7. If profile doesn't exist (trigger failed), application creates it manually as fallback
8. User is redirected to home page with their profile loaded

### Automatic Profile Creation (Database Trigger)

The database trigger (`on_auth_user_created`) runs automatically when a new user is created:

```sql
-- Extracts display_name from user metadata or uses email prefix
-- Sets role to 'student' by default
-- Creates empty preferences object
```

## Testing

To test the fix:

1. **Apply the SQL migration** (run `fix-profile-creation.sql` in Supabase SQL Editor)
2. Clear your browser data or use incognito mode
3. Go to `/auth/register`
4. Register a new account with:
   - Display Name: Test User
   - Email: test@example.com
   - Password: password123
5. After successful registration, check:
   - User should be redirected to home page
   - User should be logged in
   - Profile should be visible in `/profile` page
6. Verify in Supabase Dashboard:
   - Check `auth.users` table - new user should exist
   - Check `user_profiles` table - profile should exist with same ID

## Troubleshooting

### Profile still not being created?

1. **Check RLS policies**: Make sure the INSERT policies were created successfully
2. **Check trigger**: Verify the trigger exists and is enabled
3. **Check permissions**: Make sure the function has proper permissions
4. **Check logs**: Look at Supabase logs for any errors

### Can't insert profiles manually?

If you need to manually create profiles for existing users:

```sql
-- Insert profile for a specific user
INSERT INTO public.user_profiles (id, display_name, role, preferences)
SELECT 
  id,
  COALESCE(raw_user_meta_data->>'display_name', split_part(email, '@', 1)),
  'student',
  '{}'::jsonb
FROM auth.users
WHERE id = 'USER_ID_HERE';

-- Insert profiles for all users that don't have one
INSERT INTO public.user_profiles (id, display_name, role, preferences)
SELECT 
  u.id,
  COALESCE(u.raw_user_meta_data->>'display_name', split_part(u.email, '@', 1)),
  'student',
  '{}'::jsonb
FROM auth.users u
LEFT JOIN public.user_profiles p ON u.id = p.id
WHERE p.id IS NULL;
```

## Files Modified

- ✅ `fix-profile-creation.sql` - New SQL migration file
- ✅ `app/stores/auth.ts` - Updated signUp and createProfile functions
- ✅ `PROFILE_CREATION_FIX.md` - This documentation file

## Migration Status

- [ ] Run `fix-profile-creation.sql` in Supabase SQL Editor
- [ ] Test new user registration
- [ ] Verify profiles are being created automatically

---

**Created**: 2026-01-25
**Status**: Ready to apply
