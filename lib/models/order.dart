import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';
import 'user.dart';
 AppUser? user;
class Order {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final List<CartItem> items;
  final double total;
  final DateTime timestamp;
  final String status;

  Order({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.items,
    required this.total,
    required this.timestamp,
    required this.status,
  });

  factory Order.fromMap(Map<String, dynamic> map, String documentId) {
    return Order(
      id: documentId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      items: (map['items'] as List<dynamic>)
          .map((item) => CartItem.fromMap(item))
          .toList(),
      total: (map['total'] ?? 0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      status: map['status'] ?? 'Chờ xác nhận',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'address': address,
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'timestamp': timestamp,
      'status': status,
    };
  }
}
