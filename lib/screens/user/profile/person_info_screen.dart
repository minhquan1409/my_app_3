import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app_3/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import 'person_info_form_screen.dart';

class PersonInfoScreen extends StatefulWidget {
  const PersonInfoScreen({super.key});

  @override
  State<PersonInfoScreen> createState() => _PersonInfoScreenState();
}
class _PersonInfoScreenState extends State<PersonInfoScreen> {
  bool _checkedInfo = false; // tránh gọi _promptUpdateInfo nhiều lần

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndPromptInfo();
  }

  Future<void> _checkAndPromptInfo() async {
    if (_checkedInfo) return; // chỉ check 1 lần khi mở screen
    _checkedInfo = true;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userProvider = context.read<UserProvider>();
    if (userProvider.user == null) {
      await userProvider.fetchUserData();
    }

    final user = userProvider.user;
    if (user == null || user.name.isEmpty || user.address.isEmpty || user.phone.isEmpty) {
      _promptUpdateInfo();
    }
  }

  void _promptUpdateInfo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Thông tin chưa đầy đủ'),
          content: const Text('Bạn cần điền đầy đủ thông tin cá nhân để tiếp tục.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Bỏ qua'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _navigateToUpdateInfo();
              },
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    context.read<UserProvider>().clearUser();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _navigateToUpdateInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PersonInfoFormScreen()),
    ).then((_) => context.read<UserProvider>().fetchUserData());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '👤 Thông tin cá nhân',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.deepPurple,
                              child: Icon(Icons.person, size: 45, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text(user.name, style: const TextStyle(fontSize: 18)),
                            ),
                            ListTile(
                              leading: const Icon(Icons.phone),
                              title: Text(user.phone, style: const TextStyle(fontSize: 16)),
                            ),
                            ListTile(
                              leading: const Icon(Icons.home),
                              title: Text(user.address, style: const TextStyle(fontSize: 16)),
                            ),
                            ListTile(
                              leading: const Icon(Icons.star, color: Colors.amber),
                              title: Text('Hạng thành viên: ${user.membership.toUpperCase()}'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.attach_money, color: Colors.green),
                              title: Text('Tổng chi tiêu: ${user.totalSpent.toStringAsFixed(0)} VND'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 28),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _navigateToUpdateInfo,
                            icon: const Icon(Icons.edit),
                            label: const Text("Cập nhật thông tin"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text("Đăng xuất"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
