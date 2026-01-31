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

  // Legacy fromJson for backward compatibility
  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor.fromSupabase(json);
  }
}

class Item {
  final String id;
  final String productName;
  final String quantity;
  final DateTime expiryDate;
  final Vendor? vendor;
  final String status;
  final String? category;

  Item({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.expiryDate,
    this.vendor,
    required this.status,
    this.category,
  });

  // From Supabase
  factory Item.fromSupabase(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? '',
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? '',
      expiryDate: DateTime.parse(json['expiry_date']),
      vendor: json['vendors'] != null && json['vendors'] is Map<String, dynamic>
          ? Vendor.fromSupabase(json['vendors'])
          : null,
      status: json['status'] ?? 'available',
      category: json['category'],
    );
  }

  // Legacy fromJson for backward compatibility
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item.fromSupabase(json);
  }
}

class Category {
  final String name;
  final String imageUrl;
  final String icon;

  Category({required this.name, required this.imageUrl, required this.icon});
}
