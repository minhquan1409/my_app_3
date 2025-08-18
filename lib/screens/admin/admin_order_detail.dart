import 'package:flutter/material.dart';
import 'pending_order_screen.dart';
import 'delivering_order_screen.dart';
import 'delivered_order_screen.dart';
import 'canceled_order.dart';

class AdminOrderTabsScreen extends StatefulWidget {
  const AdminOrderTabsScreen({super.key});

  @override
  State<AdminOrderTabsScreen> createState() => _AdminOrderTabsScreenState();
}

class _AdminOrderTabsScreenState extends State<AdminOrderTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> tabs = const [
    Tab(text: 'Chờ xác nhận'),
    Tab(text: 'Đang giao'),
    Tab(text: 'Đã giao'),
    Tab(text: 'Đã huỷ'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.red,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PendingOrdersScreen(),
          DeliveringOrdersScreen(),
          DeliveredOrdersScreen(),
          CanceledOrdersScreen(),
        ],
      ),
    );
  }
}
