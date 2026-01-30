import 'package:flutter/material.dart';
import '../models/models.dart';
import '../core/mock_data.dart';

class AppProvider with ChangeNotifier {
  
  // User State
  Vendor? _currentUser;
  
  // Data State
  List<Item> _items = [];
  bool _isLoading = false;

  // Tutorial State
  bool _showTutorial = true;
  int _tutorialStep = 0;
  String _currentPage = 'home';

  // Subscription State
  bool _showSubscriptionPopup = false;
  DateTime? _lastSubscriptionShown;

  Vendor? get currentUser => _currentUser;
  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  bool get showTutorial => _showTutorial;
  int get tutorialStep => _tutorialStep;
  String get currentPage => _currentPage;
  bool get shouldShowSubscriptionPopup => _showSubscriptionPopup;

  AppProvider() {
    // Auto-init "Guest" Login
    _loginGuest();
    fetchItems();
    _checkSubscriptionPopup();
  }

  void _loginGuest() {
    _currentUser = MockData.vendors[0]; // Use a real vendor from mock data
    notifyListeners();
  }

  Future<bool> login(String phone, String shopName, String type) async {
    _loginGuest();
    return true;
  }

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    _items = List.from(MockData.items);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createItem(String productName, String quantity, DateTime expiryDate) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final newItem = Item(
      id: DateTime.now().toString(),
      productName: productName,
      quantity: quantity,
      expiryDate: expiryDate,
      vendor: _currentUser,
      status: 'available'
    );
    
    _items.insert(0, newItem);
    _isLoading = false;
    notifyListeners();
    return true;
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
