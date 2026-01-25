# Admin Panel Setup Guide

## Problem Fixed

The error "Nie znaleziono poziomu edukacji" (No education level found) was occurring because there was no `/admin/index.vue` page. When navigating to `/admin`, Nuxt was treating "admin" as a dynamic `[level]` parameter and trying to find an education level called "admin" in the database.

## Solution

Created the following admin panel pages:

### ✅ Completed Pages

1. **`/admin`** - Admin Dashboard (main page)
   - Shows system statistics
   - Quick action buttons
   - Recent activity feed

2. **`/admin/levels`** - Education Levels Management
   - Full CRUD interface
   - Create, edit, and delete education levels
   - Publish/unpublish functionality

3. **`/admin/categories`** - Categories Management (already existed)
   - Full CRUD interface
   - Filter by education level
   - Icon and ordering support

4. **`/admin/topics`** - Topics Management
   - Full CRUD interface
   - Linked to categories
   - Publish/unpublish functionality

### 🚧 Placeholder Pages (Coming Soon)

5. **`/admin/materials`** - Materials Management
6. **`/admin/tests`** - Tests Management
7. **`/admin/questions`** - Questions Management
8. **`/admin/settings`** - System Settings

## Loading Sample Data

If you don't have data in your database yet, you can load the sample data:

### Option 1: Using Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Open the `sample-data.sql` file
4. Copy and paste the contents into the SQL Editor
5. Click "Run" to execute

### Option 2: Using psql Command Line

```bash
psql "your-connection-string" < sample-data.sql
```

### Option 3: Using Supabase CLI

```bash
supabase db push < sample-data.sql
```

## Sample Data Includes

The `sample-data.sql` file contains:

- **3 Education Levels**:
  - Szkoła Podstawowa (Primary School)
  - Liceum (High School)
  - Studia (University)

- **4 Categories** per level:
  - Algebra
  - Geometria (Geometry)
  - Analiza (Analysis)
  - Trygonometria (Trigonometry)

- **2 Topics** with full content:
  - Równania liniowe (Linear Equations)
  - Pochodne (Derivatives)

- **Tests and Questions** for each topic

## Admin Access

To access the admin panel, your user account must have the `admin` role in the `user_profiles` table.

### Checking Your Role

```sql
SELECT id, display_name, role 
FROM user_profiles 
WHERE id = 'your-user-id';
```

### Setting Admin Role

```sql
UPDATE user_profiles 
SET role = 'admin' 
WHERE id = 'your-user-id';
```

Or use your email:

```sql
UPDATE user_profiles 
SET role = 'admin' 
WHERE id = (
  SELECT id FROM auth.users 
  WHERE email = 'your-email@example.com'
);
```

## Navigation

The admin layout includes a sidebar with navigation to all sections:

- 🏠 Dashboard (`/admin`)
- 🎓 Poziomy edukacji (`/admin/levels`)
- 📁 Kategorie (`/admin/categories`)
- 📖 Tematy (`/admin/topics`)
- 📄 Materiały (`/admin/materials`)
- 📋 Testy (`/admin/tests`)
- ❓ Pytania (`/admin/questions`)

## Features

### Dashboard
- Real-time statistics (levels, categories, topics, users)
- Quick action buttons for all sections
- Recent activity feed

### CRUD Pages
- List view with filtering
- Create/Edit modals
- Delete confirmation
- Publish/unpublish toggle
- Display order management
- Slug generation

## Next Steps

1. **Load sample data** (if not already loaded)
2. **Verify admin access** (set your user role to 'admin')
3. **Navigate to `/admin`** to see the dashboard
4. **Start managing content** through the admin panel

## Troubleshooting

### Still seeing "Nie znaleziono poziomu edukacji"?

1. Clear your browser cache
2. Restart the development server:
   ```bash
   npm run dev
   ```
3. Check if you're logged in as an admin user
4. Verify the sample data is loaded in your database

### Can't access admin pages?

1. Check your user role in the database
2. Verify the admin middleware is working
3. Check browser console for errors
4. Ensure Supabase connection is configured correctly

## Development Notes

- All admin pages use the `admin` layout
- All admin pages are protected by the `admin` middleware
- Pages use `ClientOnly` components to avoid SSR hydration issues
- Toast notifications for user feedback
- Consistent UI patterns across all CRUD pages
