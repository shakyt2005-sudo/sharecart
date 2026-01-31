import 'package:flutter/material.dart';
import '../models/models.dart';
import '../core/mock_data.dart';
import '../services/supabase_service.dart';

class AppProvider with ChangeNotifier {
  final _supabaseService = SupabaseService();
  
  // User State
  Vendor? _currentUser;
  
  // Data State
  List<Item> _items = [];
  List<Vendor> _bestSellers = [];
  bool _isLoading = false;
  bool _useSupabase = true; // Use Supabase by default (was false)

  // Tutorial State
  bool _showTutorial = true;
  int _tutorialStep = 0;
  String _currentPage = 'home';

  // Subscription State
  bool _showSubscriptionPopup = false;
  DateTime? _lastSubscriptionShown;

  Vendor? get currentUser => _currentUser;
  List<Item> get items => _items;
  List<Vendor> get bestSellers => _bestSellers;
  bool get isLoading => _isLoading;
  bool get showTutorial => _showTutorial;
  int get tutorialStep => _tutorialStep;
  String get currentPage => _currentPage;
  bool get shouldShowSubscriptionPopup => _showSubscriptionPopup;
  bool get useSupabase => _useSupabase;

  // Search State
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Live Filtered Items
  List<Item> get filteredItems {
    if (_searchQuery.isEmpty) return _items;
    return _items.where((item) {
      final q = _searchQuery.toLowerCase();
      return item.productName.toLowerCase().contains(q) ||
             (item.vendor?.shopName.toLowerCase() ?? '').contains(q) ||
             (item.category?.toLowerCase() ?? '').contains(q);
    }).toList();
  }

  // Nearby Items (Exclude own posts)
  List<Item> get nearbyItems {
    final baseItems = _searchQuery.isEmpty ? _items : filteredItems;
    
    // If no user is logged in, return all items
    if (_currentUser == null) return baseItems;
    
    // Filter out items posted by the current user
    return baseItems.where((item) {
      return item.vendor?.id != _currentUser?.id;
    }).toList();
  }

  // My Products (Only user's own posts)
  List<Item> get myProducts {
    if (_currentUser == null) return [];
    
    return _items.where((item) {
      return item.vendor?.id == _currentUser?.id;
    }).toList();
  }

  AppProvider() {
    // Initialize
    fetchItems();
    _checkSubscriptionPopup();
  }

  // Role Management
  bool _isGuest = false;
  bool get isGuest => _isGuest;

  // Login as Guest (Client-side only)
  void loginAsGuest() {
    _isGuest = true;
    _currentUser = null; // No profile for guests
    notifyListeners();
  }

  // Check if action is allowed (returns true if allowed, false if blocked)
  bool checkActionAllowed(BuildContext context) {
    if (_isGuest) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please create an account to chat or buy items.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // navigate to login if possible, or just dismiss
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  // Temporary "Guest" login mostly for dev testing
  void _loginGuest() {
    loginAsGuest();
  }

  // Toggle between Supabase and Mock data
  void toggleSupabase(bool value) {
    _useSupabase = value;
    fetchItems();
    notifyListeners();
  }

  Future<bool> login(String phone, String name, String role) async {
    if (_useSupabase) {
      // For now, simpler login
      // In a real app we'd map 'name' and 'role' to the profile
      final vendor = await _supabaseService.createOrGetVendor(
        phone: phone,
        shopName: name, // Using name as shopName/identifier
        type: role == 'Vendor' ? 'Grocery' : 'User', // Defaulting for simple demo
      );
      
      if (vendor != null) {
        _currentUser = vendor;
        notifyListeners();
        return true;
      }
      return false;
    } else {
      _loginGuest();
      return true;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      // Sign out from Supabase if using it
      if (_useSupabase) {
        await _supabaseService.logout();
      }
      
      // Reset all state
      _currentUser = null;
      _isGuest = false;
      _items = [];
      _bestSellers = [];
      _searchQuery = '';
      _showTutorial = true;
      _tutorialStep = 0;
      
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
      // Even if there's an error, reset local state
      _currentUser = null;
      _isGuest = false;
      _items = [];
      _bestSellers = [];
      notifyListeners();
    }
  }

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();
    
    if (_useSupabase) {
      try {
        // Fetch from Supabase
        _items = await _supabaseService.fetchItems();
        _bestSellers = await _supabaseService.fetchBestSellers();
        
        // If no data in Supabase, use mock data as fallback
        if (_items.isEmpty) {
          print('No items in Supabase, using mock data');
          _items = List.from(MockData.items);
          _bestSellers = MockData.bestSellers;
        }
      } catch (e) {
        print('Error fetching from Supabase: $e');
        // Fallback to mock data on error
        _items = List.from(MockData.items);
        _bestSellers = MockData.bestSellers;
      }
    } else {
      // Use mock data
      await Future.delayed(const Duration(milliseconds: 800));
      _items = List.from(MockData.items);
      _bestSellers = MockData.bestSellers;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createItem(String productName, String quantity, DateTime expiryDate, {String? category}) async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    bool success = false;
    
    if (_useSupabase) {
      try {
        // Create in Supabase
        success = await _supabaseService.createItem(
          productName: productName,
          quantity: quantity,
          expiryDate: expiryDate,
          vendorId: _currentUser!.id,
          category: category,
        );
        
        if (success) {
          await fetchItems(); // Refresh list
        }
      } catch (e) {
        print('Error creating item in Supabase: $e');
        success = false;
      }
    } else {
      // Mock creation
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final newItem = Item(
        id: DateTime.now().toString(),
        productName: productName,
        quantity: quantity,
        expiryDate: expiryDate,
        vendor: _currentUser,
        status: 'available',
        category: category,
      );
      
      _items.insert(0, newItem);
      success = true;
    }
    
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<List<Item>> fetchItemsByCategory(String category) async {
    if (_useSupabase) {
      return await _supabaseService.fetchItemsByCategory(category);
    } else {
      // Filter mock data
      return _items.where((item) {
        final productLower = item.productName.toLowerCase();
        final categoryLower = category.toLowerCase();
        
        if (categoryLower.contains('vegetable')) {
          return productLower.contains('carrot') || productLower.contains('tomato');
        } else if (categoryLower.contains('bakery')) {
          return productLower.contains('bread') || productLower.contains('donut');
        } else if (categoryLower.contains('dairy')) {
          return productLower.contains('milk') || productLower.contains('cheese');
        }
        return true;
      }).toList();
    }
  }
  
  // Tutorial Logic
  void setCurrentPage(String page) {
    if (_currentPage != page) {
      _currentPage = page;
      _tutorialStep = 0;
      _showTutorial = true;
      notifyListeners();
    }
  }

  void nextTutorial() {
    _tutorialStep++;
    if (_tutorialStep > _getMaxTutorialSteps()) {
      _showTutorial = false;
    }
    notifyListeners();
  }
  
  void skipTutorial() {
    _showTutorial = false;
    notifyListeners();
  }

  int _getMaxTutorialSteps() {
    switch (_currentPage) {
      case 'home': return 3;
      case 'create': return 2;
      case 'profile': return 1;
      default: return 0;
    }
  }

  // Subscription Logic
  void _checkSubscriptionPopup() {
    final now = DateTime.now();
    if (_lastSubscriptionShown == null ||
        now.difference(_lastSubscriptionShown!).inHours >= 24) {
      Future.delayed(const Duration(seconds: 5), () {
        _showSubscriptionPopup = true;
        _lastSubscriptionShown = now;
        notifyListeners();
      });
    }
  }

  void showSubscriptionPopup() {
    _showSubscriptionPopup = true;
    notifyListeners();
  }

  void dismissSubscriptionPopup() {
    _showSubscriptionPopup = false;
    notifyListeners();
  }

  void subscribe() {
    // Mock subscription
    _showSubscriptionPopup = false;
    notifyListeners();
  }
}
