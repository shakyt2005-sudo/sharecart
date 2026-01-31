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

// Chat Models
class Conversation {
  final String id;
  final String buyerId;
  final String sellerId;
  final String productId;
  final String productName;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  
  // Computed properties for UI
  Vendor? buyer;
  Vendor? seller;

  Conversation({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.productName,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
    this.buyer,
    this.seller,
  });

  factory Conversation.fromSupabase(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      buyerId: json['buyer_id'] ?? '',
      sellerId: json['seller_id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null 
          ? DateTime.parse(json['last_message_at']) 
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      buyer: json['buyers'] != null && json['buyers'] is Map<String, dynamic>
          ? Vendor.fromSupabase(json['buyers'])
          : null,
      seller: json['sellers'] != null && json['sellers'] is Map<String, dynamic>
          ? Vendor.fromSupabase(json['sellers'])
          : null,
    );
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String messageText;
  final String messageType;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    this.messageType = 'text',
    this.isRead = false,
    required this.createdAt,
  });

  factory ChatMessage.fromSupabase(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      messageText: json['message_text'] ?? '',
      messageType: json['message_type'] ?? 'text',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message_text': messageText,
      'message_type': messageType,
      'is_read': isRead,
      // Don't send created_at - let database use DEFAULT NOW()
    };
  }
}
