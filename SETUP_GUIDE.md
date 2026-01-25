# 🚀 Quick Setup Guide

## Step-by-Step Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment Variables

You mentioned that `.env` file is already set up with Supabase credentials. Verify it contains:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
```

### 3. Setup Database

1. Open your Supabase project dashboard
2. Go to **SQL Editor**
3. Copy all content from `supabase-schema.sql`
4. Paste and execute the SQL script
5. Verify tables were created in **Table Editor**

### 4. Create Your Admin Account

**Option A: Via SQL (Recommended)**

1. Register a regular account through the app at `/auth/register`
2. Go to Supabase → SQL Editor
3. Run this query (replace YOUR_EMAIL):

```sql
UPDATE user_profiles
SET role = 'admin'
WHERE id = (
  SELECT id FROM auth.users 
  WHERE email = 'YOUR_EMAIL'
);
```

**Option B: Manual**

1. Register at `/auth/register`
2. Go to Supabase → **Authentication** → **Users**
3. Copy your user UUID
4. Go to **Table Editor** → `user_profiles`
5. Find your row and change `role` from `student` to `admin`

### 5. Start Development Server

```bash
npm run dev
```

Visit: `http://localhost:3000`

## 🎯 First Steps After Setup

### As Admin:

1. **Login** at `/auth/login` with your admin account
2. **Go to Admin Panel** at `/admin`
3. **Create Content Structure**:
   - Click "Dodaj poziom edukacji" (Add Education Level)
   - Create "Liceum" (High School)
   - Click "Dodaj kategorię" (Add Category)  
   - Create "Analiza matematyczna" (Mathematical Analysis)
   - Click "Dodaj temat" (Add Topic)
   - Create "Pochodne funkcji" (Function Derivatives)

4. **Test the Public View**:
   - Navigate to homepage
   - Browse through levels → categories → topics
   - Verify content displays correctly

### Test Data Example

Here's a quick SQL script to insert sample data:

```sql
-- Insert education level
INSERT INTO education_levels (name, slug, description, display_order, is_published)
VALUES ('Liceum', 'liceum', 'Zakres liceum ogólnokształcącego', 1, true)
RETURNING id;

-- Copy the returned ID and use it below (replace YOUR_LEVEL_ID)

-- Insert category
INSERT INTO categories (education_level_id, name, slug, description, icon, display_order, is_published)
VALUES ('YOUR_LEVEL_ID', 'Analiza matematyczna', 'analiza', 'Zagadnienia z analizy matematycznej', 'i-heroicons-calculator', 1, true)
RETURNING id;

-- Copy the returned ID and use it below (replace YOUR_CATEGORY_ID)

-- Insert topic
INSERT INTO topics (category_id, name, slug, description, difficulty_level, estimated_time, display_order, is_published)
VALUES ('YOUR_CATEGORY_ID', 'Pochodne funkcji', 'pochodne', 'Wprowadzenie do pochodnych funkcji', 'basic', 45, 1, true);
```

## 📋 Admin Features Checklist

- ✅ Dashboard with statistics
- ✅ Education Levels management (`/admin/levels`)
- ✅ Categories management (`/admin/categories`)
- ✅ Topics management (`/admin/topics`)
- ✅ Create, edit, delete functionality for all
- ✅ Publish/unpublish toggle
- ✅ Slug auto-generation
- ✅ Hierarchical content structure

## 🎨 Customization Tips

### Change App Title

Edit `nuxt.config.ts`:

```typescript
app: {
  head: {
    title: "Your Custom Title"
  }
}
```

### Add More Content Types

1. Update `supabase-schema.sql` with new tables
2. Add TypeScript types in `app/types/database.ts`
3. Create admin CRUD page in `app/pages/admin/`
4. Add to sidebar navigation in `app/layouts/admin.vue`

### Customize Colors

Nuxt UI uses Tailwind CSS. Edit color classes in components or configure in `app.config.ts`.

## 🐛 Troubleshooting

### "Cannot read properties of null"
- Ensure Supabase is connected
- Check `.env` file exists and has correct values
- Restart dev server after changing `.env`

### "Row Level Security policy violation"
- Run the complete SQL schema including RLS policies
- Verify your user has correct role in `user_profiles` table

### Admin panel redirects to home
- Verify your user role is `'admin'` (not `'Admin'` - lowercase matters)
- Check browser console for auth errors

### Content not showing on public pages
- Make sure `is_published = true` for all parent entities
- Check RLS policies are correctly applied

## 📚 Key Routes

**Public:**
- `/` - Homepage
- `/[level]` - Education level page
- `/[level]/[category]` - Category page
- `/[level]/[category]/[topic]` - Topic detail page
- `/[level]/[category]/[topic]/test/[id]` - Test page

**Admin:**
- `/admin` - Dashboard
- `/admin/levels` - Education levels
- `/admin/categories` - Categories
- `/admin/topics` - Topics

**Auth:**
- `/auth/login` - Login
- `/auth/register` - Register

## 🔐 Security Notes

- All admin routes protected by middleware
- RLS policies enforce data access rules
- Test answers validated server-side
- Passwords hashed by Supabase Auth

## 📞 Need Help?

Check these files for implementation details:
- `README.md` - Full documentation
- `supabase-schema.sql` - Database structure
- `app/types/database.ts` - TypeScript types
- `app/stores/` - State management logic

## ✅ Production Checklist

Before deploying:
- [ ] Update meta tags in `nuxt.config.ts`
- [ ] Configure production Supabase project
- [ ] Enable RLS policies in production
- [ ] Test all admin functionality
- [ ] Test public content display
- [ ] Verify authentication flows
- [ ] Check mobile responsiveness
- [ ] Test dark mode
- [ ] Run `npm run build` successfully

---

**Happy coding! 🎉**

