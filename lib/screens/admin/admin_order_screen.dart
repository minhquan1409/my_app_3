// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/order_provider.dart';
// import '../../models/order.dart';

// class AdminOrderTabsScreen extends StatefulWidget {
//   const AdminOrderTabsScreen({super.key});

//   @override
//   State<AdminOrderTabsScreen> createState() => _AdminOrderTabsScreenState();
// }

// class _AdminOrderTabsScreenState extends State<AdminOrderTabsScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final List<String> statuses = ['Chờ xác nhận', 'Đang giao', 'Đã giao', 'Đã huỷ'];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: statuses.length, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orderProvider = Provider.of<OrderProvider>(context, listen: false);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Quản lý đơn hàng'),
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: Colors.red,
//           unselectedLabelColor: Colors.black,
//           indicatorColor: Colors.red,
//           tabs: statuses.map((status) => Tab(text: status)).toList(),
//           isScrollable: true,
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: statuses.map((status) {
//           return FutureBuilder<List<Order>>(
//             future: orderProvider.fetchAllOrders(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Center(child: Text('Không có đơn hàng nào.'));
//               }

//               final filteredOrders = snapshot.data!.where((o) => o.status == status).toList();

//               if (filteredOrders.isEmpty) {
//                 return const Center(child: Text('Không có đơn hàng nào.'));
//               }

//               // return ListView.builder(
//               //   itemCount: filteredOrders.length,
//               //   itemBuilder: (context, index) {
//               //     final order = filteredOrders[index];
//               //     return ListTile(
//               //       title: Text('Đơn #${order.id} - ${order.name}'),
//               //       subtitle: Text(order.address),
//               //       trailing: Text('${order.total.toStringAsFixed(0)} đ'),
//               //       onTap: () {
//               //         // điều hướng đến trang chi tiết đơn hàng
//               //       },
//               //     );
//               //   },
//               // );
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/order.dart';
// import '../../models/cart_item.dart';
// import '../../providers/order_provider.dart';

// class AdminOrderDetailScreen extends StatefulWidget {
//   final Order order;

//   const AdminOrderDetailScreen({super.key, required this.order});

//   @override
//   State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
// }

// class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
//   String? _selectedStatus;
//   final List<String> _statuses = ['Chờ xác nhận', 'Đang giao', 'Đã giao', 'Đã huỷ'];

//   @override
//   void initState() {
//     super.initState();
//     _selectedStatus = widget.order.status;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final order = widget.order;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('🧾 Mã đơn: ${order.id}'),
//             Text('👤 ID người dùng: ${order.userId}'),
//             const SizedBox(height: 4),
//             Text('👨‍💼 Tên người nhận: ${order.name}'),
//             Text('📞 SĐT: ${order.phone}'),
//             Text('🏠 Địa chỉ: ${order.address}'),
//             const SizedBox(height: 8),
//             Text('💰 Tổng tiền: ${order.total.toStringAsFixed(0)} đ'),
//             Text('🕒 Thời gian: ${order.timestamp}'),

//             const SizedBox(height: 16),
//             const Text('🛒 Danh sách sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),

//             Expanded(
//               child: ListView.builder(
//                 itemCount: order.items.length,
//                 itemBuilder: (ctx, index) {
//                   final CartItem item = order.items[index];
//                   return ListTile(
//                     leading: Image.network(item.product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
//                     title: Text(item.product.name),
//                     subtitle: Text('Số lượng: ${item.quantity}'),
//                     trailing: Text('${item.totalPrice.toStringAsFixed(0)} đ'),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 20),
//             const Text('📦 Trạng thái đơn hàng:', style: TextStyle(fontWeight: FontWeight.bold)),

//             DropdownButton<String>(
//               value: _selectedStatus,
//               onChanged: (value) {
//                 setState(() {
//                   _selectedStatus = value;
//                 });
//               },
//               items: _statuses
//                   .map((status) => DropdownMenuItem(
//                         value: status,
//                         child: Text(status),
//                       ))
//                   .toList(),
//             ),

//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: () async {
//                 if (_selectedStatus != null && _selectedStatus != order.status) {
//                   await Provider.of<OrderProvider>(context, listen: false)
//                       .updateOrderStatus(order.id, _selectedStatus!);
//                   if (mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('✅ Cập nhật trạng thái thành công')),
//                     );
//                     Navigator.pop(context); // Quay lại sau khi cập nhật
//                   }
//                 }
//               },
//               icon: const Icon(Icons.update),
//               label: const Text('Cập nhật trạng thái'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }