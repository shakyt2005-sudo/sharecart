import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // Fetch all items with vendor details
  Future<List<Item>> fetchItems() async {
    try {
      final response = await _supabase
          .from('items')
          .select('*, vendors(*)')
          .eq('status', 'available')
          .order('expiry_date', ascending: true);

      return (response as List)
          .map((item) => Item.fromSupabase(item))
          .toList();
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Create new item
  Future<bool> createItem({
    required String productName,
    required String quantity,
    required DateTime expiryDate,
    required String vendorId,
    String? category,
  }) async {
    try {
      await _supabase.from('items').insert({
        'product_name': productName,
        'quantity': quantity,
        'expiry_date': expiryDate.toIso8601String(),
        'vendor_id': vendorId,
        'category': category,
        'status': 'available',
      });
      return true;
    } catch (e) {
      print('Error creating item: $e');
      return false;
    }
  }

  // Fetch vendors (for best sellers)
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

  // Fetch best sellers
  Future<List<Vendor>> fetchBestSellers() async {
    try {
      final response = await _supabase
          .from('vendors')
          .select()
          .gte('total_sales', 50)
          .order('total_sales', ascending: false)
          .limit(10);

      return (response as List)
          .map((vendor) => Vendor.fromSupabase(vendor))
          .toList();
    } catch (e) {
      print('Error fetching best sellers: $e');
      return [];
    }
  }

  // Create or get vendor (for login)
  Future<Vendor?> createOrGetVendor({
    required String phone,
    required String shopName,
    required String type,
    String? location,
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
            'location': location ?? 'Chennai',
          })
          .select()
          .single();

      return Vendor.fromSupabase(response);
    } catch (e) {
      print('Error creating vendor: $e');
      return null;
    }
  }

  // Fetch items by category
  Future<List<Item>> fetchItemsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('items')
          .select('*, vendors(*)')
          .eq('category', category)
          .eq('status', 'available')
          .order('expiry_date', ascending: true);

      return (response as List)
          .map((item) => Item.fromSupabase(item))
          .toList();
    } catch (e) {
      print('Error fetching items by category: $e');
      return [];
    }
  }

  // Fetch items by location (nearby)
  Future<List<Item>> fetchItemsByLocation(String location) async {
    try {
      final response = await _supabase
          .from('items')
          .select('*, vendors!inner(*)')
          .eq('status', 'available')
          .ilike('vendors.location', '%$location%')
          .order('expiry_date', ascending: true);

      return (response as List)
          .map((item) => Item.fromSupabase(item))
          .toList();
    } catch (e) {
      print('Error fetching items by location: $e');
      return [];
    }
  }

  // Fetch nearby items excluding user's own posts
  Future<List<Item>> fetchNearbyItemsExcludingUser(String location, String excludeVendorId) async {
    try {
      final response = await _supabase
          .from('items')
          .select('*, vendors!inner(*)')
          .eq('status', 'available')
          .neq('vendor_id', excludeVendorId)
          .ilike('vendors.location', '%$location%')
          .order('expiry_date', ascending: true);

      return (response as List)
          .map((item) => Item.fromSupabase(item))
          .toList();
    } catch (e) {
      print('Error fetching nearby items: $e');
      return [];
    }
  }

  // Fetch items by vendor (for My Products)
  Future<List<Item>> fetchItemsByVendor(String vendorId) async {
    try {
      final response = await _supabase
          .from('items')
          .select('*, vendors(*)')
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Item.fromSupabase(item))
          .toList();
    } catch (e) {
      print('Error fetching items by vendor: $e');
      return [];
    }
  }

  // Update vendor verification status
  Future<bool> updateVendorVerification(String vendorId, bool isVerified) async {
    try {
      await _supabase
          .from('vendors')
          .update({'is_verified': isVerified})
          .eq('id', vendorId);
      return true;
    } catch (e) {
      print('Error updating verification: $e');
      return false;
    }
  }

  // Increment vendor sales count
  Future<bool> incrementVendorSales(String vendorId) async {
    try {
      await _supabase.rpc('increment_sales', params: {'vendor_id': vendorId});
      return true;
    } catch (e) {
      print('Error incrementing sales: $e');
      return false;
    }
  }
}
