import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonInfoFormScreen extends StatefulWidget {
  const PersonInfoFormScreen({super.key});

  @override
  State<PersonInfoFormScreen> createState() => _PersonInfoFormScreenState();
}

class _PersonInfoFormScreenState extends State<PersonInfoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  void _saveInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'phone': _phoneController.text.trim(),
        }, SetOptions(merge: true));
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu thông tin: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Không dùng AppBar truyền thống, hiển thị tiêu đề lớn trên cùng
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Tiêu đề lớn
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 24),
              child: Text(
                '📝 Cập nhật thông tin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.left,
              ),
            ),

            // Card chứa form
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Họ tên
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Họ tên',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: Colors.deepPurple.withOpacity(0.05),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Vui lòng nhập họ tên' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // Địa chỉ
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Địa chỉ',
                          prefixIcon: const Icon(Icons.home_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: Colors.deepPurple.withOpacity(0.05),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // Số điện thoại
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: Colors.deepPurple.withOpacity(0.05),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          if (!RegExp(r'^[0-9]{9,11}$').hasMatch(value.trim())) {
                            return 'Số điện thoại không hợp lệ';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 32),

                      // Nút lưu và trở về
                      SizedBox(
                        width: double.infinity,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      textStyle: const TextStyle(
                                          fontSize: 17, fontWeight: FontWeight.w600),
                                    ),
                                    icon: const Icon(Icons.save_alt),
                                    label: const Text('Lưu thông tin'),
                                    onPressed: _saveInfo,
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton.icon(
                                    icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
                                    label: const Text(
                                      'Trở về',
                                      style: TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
