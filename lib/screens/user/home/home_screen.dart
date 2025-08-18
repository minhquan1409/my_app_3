import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen_content.dart';
import '../cart/cart_screen.dart';
import '../history/history_screen.dart';
import '../profile/person_info_screen.dart';
import '../category/category_screen.dart';
import '../../../providers/cart_provider.dart';
import '../order_tracking/order_tracking_screen.dart';
import '../chat_screen/user_chat_screen.dart';
import '../../../providers/user_provider.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreenContent(),
    CategoryScreen(),
    CartScreen(),
    OrderTrackingScreen(),
    HistoryScreen(),
    PersonInfoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartItemCount = context.watch<CartProvider>().totalItems;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 12, left: 8, right: 8, bottom: 6),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                  children: [
                    const Icon(Icons.storefront, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    const Text(
                    'My Shop App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    ),
                  ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: cartItemCount > 0
                          ? badges.Badge(
                            position: badges.BadgePosition.topEnd(top: -6, end: -6),
                            badgeStyle: const badges.BadgeStyle(
                              badgeColor: Colors.red,
                              padding: EdgeInsets.all(5),
                            ),
                            badgeContent: Text(
                              cartItemCount.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                            )
                          : const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _currentIndex = 2; // Điều hướng đến trang Cart
                            });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, color: Colors.white),
                        onPressed: () async {
                          final userProvider = Provider.of<UserProvider>(context, listen: false);
                          await Future.delayed(const Duration(milliseconds: 1)); // Đoạn await được thêm vào đây
                          if (!mounted) return;
                          final user = userProvider.user;
                          if (user != null && user.uid.isNotEmpty) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => UserChatScreen(
                                  userId: user.uid,
                                  userName: user.name,
                                ),
                              ),
                            );
                          }
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Category'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Tracking'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
