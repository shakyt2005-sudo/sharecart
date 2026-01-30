import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

import 'package:flutter/foundation.dart';

String get baseUrl {
  if (kIsWeb) return 'http://localhost:5000/api';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:5000/api';
  return 'http://localhost:5000/api';
} 

class ApiService {
  Future<Vendor> login(String phone, String shopName, String type) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'shopName': shopName, 'type': type}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return Vendor.fromJson(data['data']);
        } else {
           throw Exception(data['error']);
        }
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  Future<List<Item>> getItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/items'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['data'] as List).map((i) => Item.fromJson(i)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }

  Future<bool> createItem(String productName, String quantity, DateTime expiryDate, String vendorId) async {
     try {
      final response = await http.post(
        Uri.parse('$baseUrl/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productName': productName,
          'quantity': quantity,
          'expiryDate': expiryDate.toIso8601String(),
          'vendorId': vendorId
        }),
      );

      if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         return data['success'];
      }
      return false;
    } catch (e) {
      print('Error creating item: $e');
      return false;
    }
  }
  
  Future<void> seedData() async {
     try {
        await http.post(Uri.parse('$baseUrl/seed'));
     } catch (e) {
       print("Seed error $e");
     }
  }
}
