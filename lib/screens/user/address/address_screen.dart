import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';


class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentAddress();
  }

  Future<void> _loadCurrentAddress() async {
    final prefs = await SharedPreferences.getInstance();
    String localAddress = prefs.getString('shipping_address') ?? '';

    // Lấy từ Firestore nếu user đã đăng nhập
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        localAddress = data['address'] ?? localAddress;
      }
    }

    setState(() {
      _addressController.text = localAddress;
      _isLoading = false;
    });
  }

  Future<void> _saveAddress() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ')),
      );
      return;
    }

    final newAddress = _addressController.text.trim();

    // Lưu vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shipping_address', newAddress);

    // Lưu vào Firestore nếu user đã đăng nhập
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'address': newAddress,
      });

      // Cập nhật AppUser trong Provider
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.fetchUserData();
  
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'address': newAddress,
        }, SetOptions(merge: true));
      }

    Navigator.pop(context, newAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhập địa chỉ giao hàng')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveAddress,
                    child: const Text('Lưu địa chỉ'),
                  ),
                ],
              ),
            ),
    );
  }
}
