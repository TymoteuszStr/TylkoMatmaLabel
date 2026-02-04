# TylkoMatmaOnline

A modern, scalable educational web platform built with **Nuxt 4** and **Supabase** for teaching mathematics.

## 🚀 Features

- **📚 Hierarchical Content Structure**: Education levels → Categories → Topics → Materials
- **✅ ABCD Multiple-Choice Tests**: Interactive testing with instant results
- **👨‍🏫 Admin CMS**: Complete content management system for teachers
- **🎨 Modern UI**: Built with Nuxt UI and Tailwind CSS
- **🌙 Dark Mode**: Full dark mode support
- **🔐 Authentication**: Supabase Auth with role-based access control
- **📱 Responsive**: Works on desktop, tablet, and mobile
- **⚡ SEO Optimized**: Server-side rendering for optimal search engine indexing

## 🏗️ Tech Stack

- **Framework**: Nuxt 4
- **Database & Auth**: Supabase (PostgreSQL + Auth)
- **UI Components**: Nuxt UI
- **Styling**: Tailwind CSS
- **State Management**: Pinia
- **Content Rendering**: Markdown support with marked
- **Icons**: Nuxt Icon (Heroicons)
- **TypeScript**: Full type safety

## 📋 Prerequisites

- Node.js 18+ 
- npm/pnpm/yarn
- Supabase account

## 🛠️ Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Supabase

Create a `.env` file in the project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key-here
```

### 3. Setup Database

1. Go to your Supabase project SQL Editor
2. Copy and paste the contents of `supabase-schema.sql`
3. Execute the SQL script to create all tables, policies, and functions

### 4. Create Admin User

After running the schema, you need to create an admin user:

1. Sign up through the app at `/auth/register`
2. Go to your Supabase dashboard → Authentication → Users
3. Find your user and copy their UUID
4. Go to Table Editor → `user_profiles`
5. Find the row with your UUID and change `role` from `student` to `admin`

Alternatively, run this SQL query (replace YOUR_USER_ID):

```sql
UPDATE user_profiles
SET role = 'admin'
WHERE id = 'YOUR_USER_ID';
```

## 🚀 Development

Start the development server:

```bash
npm run dev
```

The app will be available at `http://localhost:3000`

## 📦 Production Build

Build for production:

```bash
npm run build
```

Preview production build:

```bash
npm run preview
```

## 📖 Usage Guide

### For Teachers (Admin)

1. **Login** as admin at `/auth/login`
2. **Access Admin Panel** at `/admin`
3. **Create Content Hierarchy**:
   - First, create Education Levels (e.g., "Liceum")
   - Then create Categories (e.g., "Analiza matematyczna")
   - Add Topics within categories
   - Create Materials for each topic
4. **Build Tests**:
   - Create questions in the question bank
   - Build tests and assign questions
   - Link tests to topics
5. **Publish** content by checking the "Published" checkbox

### For Students

1. **Browse Content** from the homepage
2. **Navigate** through levels → categories → topics
3. **Study Materials** on topic pages
4. **Take Tests** to check understanding
5. **View Results** immediately after completing tests

## 📁 Project Structure

```
app/
├── assets/          # Global CSS and static assets
├── components/      # Vue components
│   └── ContentRenderer.vue
├── composables/     # Composable functions
│   └── useAuth.ts
├── layouts/         # Page layouts (default, admin, test)
├── middleware/      # Route middleware (auth, admin)
├── pages/           # File-based routing
│   ├── auth/        # Authentication pages
│   ├── admin/       # Admin CMS pages
│   └── [level]/     # Dynamic content pages
├── plugins/         # Nuxt plugins
├── stores/          # Pinia state management
│   ├── auth.ts
│   ├── content.ts
│   └── test.ts
└── types/           # TypeScript definitions
    └── database.ts
```

## 🗄️ Database Schema

**Main Tables:**
- `education_levels` - Top-level education stages
- `categories` - Content categories within levels
- `topics` - Specific learning topics
- `materials` - Educational content blocks
- `tests` - Test configurations
- `questions` - Question bank
- `answers` - Answer options (A, B, C, D)
- `user_profiles` - Extended user information
- `test_attempts` - Student test results
- `user_progress` - Learning progress tracking

**Security:**
- Row Level Security (RLS) enabled on all tables
- Role-based policies for admin vs student access
- Public read access to published content

## 🎨 Customization

### Colors

Edit theme colors in `nuxt.config.ts`:

```typescript
export default defineNuxtConfig({
  colorMode: {
    preference: 'light'
  }
})
```

### UI Components

Using Nuxt UI components. Customize in component props or globally in `app.config.ts`

## 🔒 Security Features

- ✅ Row Level Security (RLS) policies
- ✅ Role-based access control (RBAC)
- ✅ Server-side auth validation
- ✅ Protected admin routes
- ✅ Secure test answer validation
- ✅ SQL injection prevention via Supabase
- ✅ XSS protection

## 📈 Performance

- ✅ Server-Side Rendering (SSR)
- ✅ Automatic code splitting
- ✅ Image optimization with Nuxt Image
- ✅ Lazy loading for components
- ✅ Efficient database queries with indexes

## 🤝 Contributing

This is a private educational platform. For questions or issues, contact the administrator.

## 📝 License

Private - All rights reserved

## 👨‍💻 Development Notes

### Adding New Content Types

1. Update database schema in `supabase-schema.sql`
2. Add TypeScript types in `app/types/database.ts`
3. Create Pinia store if needed
4. Build admin CRUD pages
5. Create public viewing components

### Admin Pages Pattern

Each admin resource follows this pattern:
- Index page with table view and filters
- Create/Edit modal with form
- Delete confirmation
- Toast notifications for feedback

## 🆘 Troubleshooting

**Issue: Can't access admin panel**
- Ensure your user has `role = 'admin'` in `user_profiles` table

**Issue: Content not showing**
- Check that content is published (`is_published = true`)
- Verify database RLS policies are correctly set up

**Issue: Supabase connection errors**
- Verify `.env` file has correct `SUPABASE_URL` and `SUPABASE_KEY`
- Check that Supabase project is active

## 📞 Support

For technical support or questions about the platform, contact the development team.

---

**Built with ❤️ for education**