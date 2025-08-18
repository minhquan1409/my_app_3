import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';


// Providers
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';
import 'providers/category_provider.dart';
import 'providers/chat_provider.dart';

// Screens
import 'screens/user/home/home_screen.dart';
import 'screens/user/cart/cart_screen.dart';
import 'screens/user/category/category_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/user/history/history_screen.dart';
import 'screens/user/profile/person_info_screen.dart';
import 'screens/admin/admin_dashboard.dart'; 

import 'firebase_options.dart'; // file cấu hình Firebase CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..fetchUserData()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),

      // ✅ Phân quyền admin/user tại đây
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (authProvider.user != null) {
            if (authProvider.isAdmin) {
              return const AdminDashboardScreen(); // ✅ Nếu là admin
            } else {
              return const HomeScreen(); // ✅ Nếu là user thường
            }
          }

          return const LoginScreen(); // ✅ Nếu chưa đăng nhập
        },
      ),

      // ✅ Các route
      routes: {
        '/home': (context) => const HomeScreen(),
        '/category': (context) => CategoryScreen(),
        '/cart': (context) => const CartScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const PersonInfoScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
