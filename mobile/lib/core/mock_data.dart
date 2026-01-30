import '../models/models.dart';

class MockData {
  static final List<Category> categories = [
    Category(
      name: 'Vegetables',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=200',
      icon: '🥬',
    ),
    Category(
      name: 'Fruits',
      imageUrl: 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=200',
      icon: '🍎',
    ),
    Category(
      name: 'Bakery',
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200',
      icon: '🍞',
    ),
    Category(
      name: 'Dairy',
      imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=200',
      icon: '🥛',
    ),
    Category(
      name: 'Packaged',
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=200',
      icon: '📦',
    ),
    Category(
      name: 'Beverages',
      imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=200',
      icon: '🥤',
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
