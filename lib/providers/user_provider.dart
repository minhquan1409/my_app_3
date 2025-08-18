import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _user;

  AppUser? get user => _user;

  /// Lấy dữ liệu user từ Firestore và lưu vào Provider
  Future<void> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    print("📌 Fetching data for userId: ${currentUser.uid}");

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (doc.exists) {
      _user = AppUser.fromMap(currentUser.uid, doc.data()!);
      await updateMembership();
      notifyListeners();
    } else {
      print("⚠️ User document does not exist in Firestore");
    }
  }

  /// Xoá dữ liệu user khỏi Provider (khi logout)
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Future<void> updateMembership() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("⚠️ currentUser is null");
      return;
    }

    print("🔍 Updating membership for userId: ${currentUser.uid}");

    try {
      // Lấy tất cả đơn đã giao
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'Đã giao')
          .get();

      print("📦 Delivered orders found: ${ordersSnapshot.docs.length}");

      // Tính tổng tiền
      double totalSpent = ordersSnapshot.docs.fold(0.0, (sum, doc) {
        return sum + ((doc['total'] ?? 0) as num).toDouble();
      });

      print("💰 totalSpent = $totalSpent");

      // Xác định membership
      String membership;
      if (totalSpent >= 5000000) {
        membership = 'gold';
      } else if (totalSpent >= 1000000) {
        membership = 'silver';
      } else {
        membership = 'bronze';
      }

      print("🏅 membership = $membership");

      // Cập nhật Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'totalSpent': totalSpent,
        'membership': membership,
      });

      print("✅ Firestore updated successfully");

      // Cập nhật local provider
      if (_user != null) {
        _user = AppUser(
          uid: _user!.uid,
          name: _user!.name,
          phone: _user!.phone,
          address: _user!.address,
          membership: membership,
          totalSpent: totalSpent,
          isAdmin: _user!.isAdmin,
        );
        notifyListeners();
      }
    } catch (e) {
      print("❌ Error updating membership: $e");
    }
  }
}
