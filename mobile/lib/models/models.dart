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

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['_id'] ?? '',
      shopName: json['shopName'] ?? '',
      type: json['type'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      isVerified: json['isVerified'] ?? false,
      location: json['location'] ?? 'Chennai',
      totalSales: json['totalSales'] ?? 0,
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

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? '',
      expiryDate: DateTime.parse(json['expiryDate']),
      vendor: json['vendor'] != null && json['vendor'] is Map<String, dynamic> 
          ? Vendor.fromJson(json['vendor']) 
          : null,
      status: json['status'] ?? 'available',
    );
  }
}

class Category {
  final String name;
  final String imageUrl;
  final String icon;

  Category({required this.name, required this.imageUrl, required this.icon});
}
