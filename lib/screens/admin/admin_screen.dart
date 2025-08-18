import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({super.key});

  Future<List<AppUser>> fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) => AppUser.fromMap(doc.id, doc.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('👥 Quản lý người dùng')),
      body: FutureBuilder<List<AppUser>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('❌ Đã xảy ra lỗi khi tải dữ liệu'));
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(child: Text('Không có người dùng nào'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📞 SĐT: ${user.phone}'),
                      Text('🏠 Địa chỉ: ${user.address}'),
                      Text('📧 Email: ${user.name}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
