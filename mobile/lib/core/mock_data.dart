import '../models/models.dart';

class MockData {
  static final List<Category> categories = [
    Category(
      name: 'Vegetables',
      imageUrl: 'https://images.unsplash.com/photo-1566385101042-1a0aa0c1268c?w=400', // Premium Veggies
      icon: '',
    ),
    Category(
      name: 'Fruits',
      imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400', // Fresh Fruits
      icon: '',
    ),
    Category(
      name: 'Bakery',
      imageUrl: 'assets/images/categories/bakery.png',
      icon: '',
    ),
    Category(
      name: 'Dairy',
      imageUrl: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=400', // Gourmet Cheese
      icon: '',
    ),
    Category(
      name: 'Packaged',
      imageUrl: 'assets/images/categories/packaged.png',
      icon: '',
    ),
    Category(
      name: 'Beverages',
      imageUrl: 'assets/images/categories/beverages.png',
      icon: '',
    ),
    Category(
      name: 'Meat',
      imageUrl: 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400', // Fresh Meat
      icon: '',
    ),
    Category(
      name: 'Seafood',
      imageUrl: 'assets/images/categories/seafood.png',
      icon: '',
    ),
    Category(
      name: 'Grains',
      imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400', // Wheat/Grains
      icon: '',
    ),
  ];

  static final List<Vendor> vendors = [
    Vendor(
      id: 'v1',
      shopName: 'Fresh Farms',
      type: 'Farm',
      phone: '123',
      rating: 4.8,
      isVerified: true,
      location: 'T. Nagar, Chennai',
      totalSales: 120,
    ),
    Vendor(
      id: 'v2',
      shopName: 'City Bakery',
      type: 'Bakery',
      phone: '456',
      rating: 4.5,
      isVerified: true,
      location: 'Anna Nagar, Chennai',
      totalSales: 85,
    ),
    Vendor(
      id: 'v3',
      shopName: 'Daily Dairy',
      type: 'Dairy',
      phone: '789',
      rating: 4.2,
      isVerified: false,
      location: 'Adyar, Chennai',
      totalSales: 45,
    ),
    Vendor(
      id: 'v4',
      shopName: 'Metro Mart',
      type: 'Grocery',
      phone: '101',
      rating: 4.6,
      isVerified: true,
      location: 'Velachery, Chennai',
      totalSales: 95,
    ),
  ];

  static final List<Item> items = [
    Item(
      id: '1',
      productName: 'Organic Carrots',
      quantity: '10 kg',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      vendor: vendors[0],
      status: 'available',
    ),
    Item(
      id: '2',
      productName: 'Whole Wheat Bread',
      quantity: '20 Loaves',
      expiryDate: DateTime.now().add(const Duration(days: 1)),
      vendor: vendors[1],
      status: 'available',
    ),
    Item(
      id: '3',
      productName: 'Full Cream Milk',
      quantity: '50 Liters',
      expiryDate: DateTime.now().add(const Duration(hours: 12)),
      vendor: vendors[2],
      status: 'available',
    ),
    Item(
      id: '4',
      productName: 'Canned Beans',
      quantity: '50 Cans',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      vendor: vendors[3],
      status: 'available',
    ),
    Item(
      id: '5',
      productName: 'Assorted Donuts',
      quantity: '4 Boxes',
      expiryDate: DateTime.now().add(const Duration(hours: 6)),
      vendor: vendors[1],
      status: 'available',
    ),
    Item(
      id: '6',
      productName: 'Fresh Tomatoes',
      quantity: '15 kg',
      expiryDate: DateTime.now().add(const Duration(days: 3)),
      vendor: vendors[0],
      status: 'available',
    ),
  ];

  static List<Vendor> get bestSellers => vendors.where((v) => v.isBestSeller).toList()
    ..sort((a, b) => b.totalSales.compareTo(a.totalSales));
}
