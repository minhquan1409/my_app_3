import 'package:flutter/material.dart';
import 'package:my_app_3/screens/admin/admin_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'admin_category_screen.dart';
import 'admin_order_detail.dart';
import 'admin_chat_screen.dart';
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void _logout(BuildContext context) async {
    await Provider.of<AuthProvider>(context, listen: false).signOut();

    // Điều hướng về LoginScreen và xóa stack cũ
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang quản trị'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminTile(
            context,
            title: 'Quản lý sản phẩm',
            icon: Icons.shopping_bag,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminCategoryScreen(),
                ),
              );
            },
          ),
          _buildAdminTile(
            context,
            title: 'Đơn hàng',
            icon: Icons.receipt_long,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminOrderTabsScreen(),
                ),
              );
            },
          ),
          _buildAdminTile(
            context,
            title: 'Người dùng',
            icon: Icons.people,
            onTap: () {
              // TODO: thêm chức năng quản lý người dùng
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminUserManagementScreen()),
              );
            },
          ),
          _buildAdminTile(
            context,
            title: 'Chat với người dùng',
            icon: Icons.chat,
            onTap: () { 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminChatScreen(),
                ),
              );

            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTile(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
