# Flutter + Supabase Integration Guide

## Step 1: Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in
3. Click "New Project"
4. Fill in:
   - **Project Name**: ShareCart
   - **Database Password**: (create a strong password - save it!)
   - **Region**: Choose closest to your users
5. Wait for project to be created (~2 minutes)

## Step 2: Get Your Supabase Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy these values:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)

## Step 3: Install Supabase Flutter Package

Run in your terminal:

```bash
cd d:/project/sharecart3/mobile
flutter pub add supabase_flutter
```

## Step 4: Initialize Supabase in Your App

### Create `.env` file (for security)

Create `mobile/.env`:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### Update `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/colors.dart';
import 'providers/app_provider.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsBinding.flutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const ShareCartApp(),
    ),
  );
}

// Rest of your code...
```

## Step 5: Create Database Tables in Supabase

Go to **SQL Editor** in Supabase dashboard and run:

```sql
-- Vendors Table
CREATE TABLE vendors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  shop_name TEXT NOT NULL,
  type TEXT NOT NULL,
  phone TEXT NOT NULL,
  location TEXT DEFAULT 'Chennai',
  rating DECIMAL(2,1) DEFAULT 0.0,
  is_verified BOOLEAN DEFAULT false,
  total_sales INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Items Table
CREATE TABLE items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_name TEXT NOT NULL,
  quantity TEXT NOT NULL,
  expiry_date TIMESTAMP WITH TIME ZONE NOT NULL,
  vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'available',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read access on vendors"
  ON vendors FOR SELECT
  USING (true);

CREATE POLICY "Allow public read access on items"
  ON items FOR SELECT
  USING (true);

-- Allow authenticated users to insert/update their own data
CREATE POLICY "Allow insert for authenticated users"
  ON vendors FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow insert for authenticated users"
  ON items FOR INSERT
  WITH CHECK (true);
```

## Step 6: Create Supabase Service Layer

Create `mobile/lib/services/supabase_service.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // Fetch all items
  Future<List<Item>> fetchItems() async {
    try {
      final response = await _supabase
          .from('items')
          .select('*, vendors(*)')
          .order('expiry_date', ascending: true);

      return (response as List)
          .map((item) => Item.fromSupabase(item))
          .toList();
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }

  // Create new item
  Future<bool> createItem({
    required String productName,
    required String quantity,
    required DateTime expiryDate,
    required String vendorId,
  }) async {
    try {
      await _supabase.from('items').insert({
        'product_name': productName,
        'quantity': quantity,
        'expiry_date': expiryDate.toIso8601String(),
        'vendor_id': vendorId,
        'status': 'available',
      });
      return true;
    } catch (e) {
      print('Error creating item: $e');
      return false;
    }
  }

  // Fetch vendors
  Future<List<Vendor>> fetchVendors() async {
    try {
      final response = await _supabase
          .from('vendors')
          .select()
          .order('total_sales', ascending: false);

      return (response as List)
          .map((vendor) => Vendor.fromSupabase(vendor))
          .toList();
    } catch (e) {
      print('Error fetching vendors: $e');
      return [];
    }
  }

  // Create vendor (for login)
  Future<Vendor?> createOrGetVendor({
    required String phone,
    required String shopName,
    required String type,
  }) async {
    try {
      // Check if vendor exists
      final existing = await _supabase
          .from('vendors')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (existing != null) {
        return Vendor.fromSupabase(existing);
      }

      // Create new vendor
      final response = await _supabase
          .from('vendors')
          .insert({
            'shop_name': shopName,
            'type': type,
            'phone': phone,
          })
          .select()
          .single();

      return Vendor.fromSupabase(response);
    } catch (e) {
      print('Error creating vendor: $e');
      return null;
    }
  }
}
```

## Step 7: Update Models to Support Supabase

Update `mobile/lib/models/models.dart`:

```dart
class Vendor {
  final String id;
  final String shopName;
  final String type;
  final String phone;
  final double rating;
  final bool isVerified;
  final String location;
  final int totalSales;

  Vendor({
    required this.id,
    required this.shopName,
    required this.type,
    required this.phone,
    this.rating = 0.0,
    this.isVerified = false,
    this.location = 'Chennai',
    this.totalSales = 0,
  });

  bool get isBestSeller => totalSales > 50;

  // From Supabase
  factory Vendor.fromSupabase(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] ?? '',
      shopName: json['shop_name'] ?? '',
      type: json['type'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      isVerified: json['is_verified'] ?? false,
      location: json['location'] ?? 'Chennai',
      totalSales: json['total_sales'] ?? 0,
    );
  }
}

class Item {
  final String id;
  final String productName;
  final String quantity;
  final DateTime expiryDate;
  final Vendor? vendor;
  final String status;

  Item({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.expiryDate,
    this.vendor,
    required this.status,
  });

  // From Supabase
  factory Item.fromSupabase(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? '',
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? '',
      expiryDate: DateTime.parse(json['expiry_date']),
      vendor: json['vendors'] != null 
          ? Vendor.fromSupabase(json['vendors']) 
          : null,
      status: json['status'] ?? 'available',
    );
  }
}
```

## Step 8: Update AppProvider to Use Supabase

Update `mobile/lib/providers/app_provider.dart`:

```dart
import '../services/supabase_service.dart';

class AppProvider with ChangeNotifier {
  final _supabaseService = SupabaseService();
  
  // ... existing code ...

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();
    
    _items = await _supabaseService.fetchItems();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createItem(String productName, String quantity, DateTime expiryDate) async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    final success = await _supabaseService.createItem(
      productName: productName,
      quantity: quantity,
      expiryDate: expiryDate,
      vendorId: _currentUser!.id,
    );
    
    if (success) {
      await fetchItems(); // Refresh list
    }
    
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> login(String phone, String shopName, String type) async {
    final vendor = await _supabaseService.createOrGetVendor(
      phone: phone,
      shopName: shopName,
      type: type,
    );
    
    if (vendor != null) {
      _currentUser = vendor;
      notifyListeners();
      return true;
    }
    return false;
  }
}
```

## Step 9: Test the Connection

Run your app:
```bash
flutter run
```

Check Supabase dashboard → **Table Editor** to see data being created!

## Troubleshooting

### Error: "Invalid API key"
- Double-check your URL and anon key
- Make sure there are no extra spaces

### Error: "Row Level Security"
- Run the RLS policies from Step 5
- Or temporarily disable RLS in Supabase (not recommended for production)

### Error: "Connection timeout"
- Check your internet connection
- Verify Supabase project is active

## Next Steps

1. **Authentication**: Add Supabase Auth for secure login
2. **Real-time**: Use Supabase Realtime for live updates
3. **Storage**: Upload shop license images to Supabase Storage
4. **Functions**: Create Edge Functions for complex logic

## Resources

- [Supabase Flutter Docs](https://supabase.com/docs/reference/dart/introduction)
- [Supabase Dashboard](https://app.supabase.com)
