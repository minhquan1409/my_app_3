import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../models/cart_item.dart';
import '../../models/order.dart';
import '../../models/user.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Đặt đơn hàng mới
Future<void> placeOrder(List<CartItem> cartItems, AppUser user) async {
  try {
    final orderData = {
      'userId': user.uid,
      'name': user.name,
      'phone': user.phone,
      'address': user.address,
      'timestamp': Timestamp.now(),
      'items': cartItems.map((item) => item.toMap()).toList(),
      'total': cartItems.fold(0.0, (sum, item) => sum + item.totalPrice),
      'status': 'Chờ xác nhận',
    };

    await _firestore.collection('orders').add(orderData);
  } catch (e) {
    print('Error placing order: $e');
  }
}


  /// Lấy đơn hàng của người dùng
  Future<List<Order>> fetchOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Order.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching user orders: $e');
      return [];
    }
  }

  /// Lấy tất cả đơn hàng cho admin
  Future<List<Order>> fetchAllOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Order.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching all orders: $e');
      return [];
    }
  }


   Future<void> updateOrderStatus(String orderId, String status) async {
  try {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': status});
    notifyListeners();
  } catch (e) {
    print("Lỗi updateOrderStatus: $e");
  }
}



}
