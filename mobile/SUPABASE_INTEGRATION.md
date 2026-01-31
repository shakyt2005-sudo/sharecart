# 🚀 Supabase Integration - Quick Start Guide

## ✅ What's Been Implemented

Your ShareCart app now has **full Supabase backend integration** with:

- ✨ **Real database** storage for vendors and items
- 🔄 **Automatic data sync** between app and cloud
- 🎯 **Smart toggle** - switch between mock data (testing) and real data (production)
- 📊 **Best sellers** ranking system
- 📍 **Location-based** filtering
- 🏷️ **Category** filtering

## 🎯 Setup Steps (5 minutes)

### Step 1: Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up/login
3. Click **"New Project"**
4. Fill in:
   - Name: `ShareCart`
   - Database Password: (create strong password - **SAVE IT!**)
   - Region: Choose closest to you
5. Wait ~2 minutes for setup

### Step 2: Run SQL Setup

1. In Supabase dashboard → **SQL Editor**
2. Copy entire contents of `mobile/supabase_setup.sql`
3. Paste and click **"Run"**
4. You should see: ✅ Success (tables, policies, sample data created)

### Step 3: Get Your Credentials

1. In Supabase → **Settings** → **API**
2. Copy:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJ...` (long string)

### Step 4: Update Flutter App

Open `mobile/lib/main.dart` and replace:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL_HERE',  // ← Paste your URL
  anonKey: 'YOUR_SUPABASE_ANON_KEY_HERE',  // ← Paste your key
);
```

### Step 5: Enable Supabase in App

In your app, go to **Profile** → tap "Use Supabase" toggle (coming soon, or manually set in code):

```dart
// In any screen, call:
Provider.of<AppProvider>(context, listen: false).toggleSupabase(true);
```

### Step 6: Test!

```bash
flutter run
```

- Add a new item → Check Supabase dashboard → **Table Editor** → `items`
- You should see your item appear! 🎉

## 📁 Files Created

| File | Purpose |
|------|---------|
| `lib/services/supabase_service.dart` | All API calls to Supabase |
| `lib/models/models.dart` | Updated with `fromSupabase()` |
| `lib/providers/app_provider.dart` | Integrated Supabase service |
| `lib/main.dart` | Supabase initialization |
| `supabase_setup.sql` | Database schema & sample data |

## 🎮 How It Works

### Mock Mode (Default)
- Uses local mock data
- No internet required
- Perfect for testing UI

### Supabase Mode
- Real cloud database
- Data persists across devices
- Requires internet

### Toggle Between Modes

```dart
// Enable Supabase
provider.toggleSupabase(true);

// Disable (use mock)
provider.toggleSupabase(false);
```

## 📊 Database Schema

### `vendors` Table
```
- id (UUID)
- shop_name
- type
- phone (unique)
- location
- rating (0-5)
- is_verified (boolean)
- total_sales (integer)
```

### `items` Table
```
- id (UUID)
- product_name
- quantity
- expiry_date
- vendor_id (foreign key)
- category
- status (available/reserved/sold)
```

## 🔥 Features Available

### ✅ Already Working
- ✨ Fetch all items
- ✨ Create new items
- ✨ Vendor login/registration
- ✨ Best sellers ranking
- ✨ Category filtering
- ✨ Location-based search

### 🚀 Easy to Add
- Real-time updates (Supabase Realtime)
- Image upload (Supabase Storage)
- Authentication (Supabase Auth)
- Chat system

## 🐛 Troubleshooting

### "Invalid API key"
- Double-check URL and key (no extra spaces)
- Make sure you copied the **anon/public** key, not service key

### "Permission denied"
- Run the SQL setup script again
- Check RLS policies are created

### "No data showing"
- Check `useSupabase` is `true`
- Verify SQL script ran successfully
- Check Supabase dashboard → Table Editor for data

### "Connection timeout"
- Check internet connection
- Verify Supabase project is active (not paused)

## 📱 Testing Checklist

- [ ] SQL script runs without errors
- [ ] Sample data visible in Supabase dashboard
- [ ] App connects (no errors in console)
- [ ] Can create new item
- [ ] New item appears in Supabase dashboard
- [ ] Can fetch items from database
- [ ] Best sellers show correctly

## 🎯 Next Steps

1. **Add Settings Screen** - Toggle Supabase on/off in UI
2. **Real-time Sync** - Items update live across devices
3. **Image Upload** - Shop licenses to Supabase Storage
4. **Authentication** - Secure user login with Supabase Auth
5. **Chat System** - Vendor-to-vendor messaging

## 🔗 Resources

- [Supabase Dashboard](https://app.supabase.com)
- [Flutter Docs](https://supabase.com/docs/reference/dart)
- [SQL Editor](https://app.supabase.com/project/_/sql)

---

**🎉 You're all set!** Your app now has a production-ready backend powered by Supabase.
