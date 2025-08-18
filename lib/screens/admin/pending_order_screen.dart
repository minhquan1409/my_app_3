import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_item.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

class PendingOrdersScreen extends StatefulWidget {
  const PendingOrdersScreen({super.key});

  @override
  State<PendingOrdersScreen> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<PendingOrdersScreen> {
  late Future<List<Order>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }


  void _loadOrders() {
    _futureOrders =
        Provider.of<OrderProvider>(context, listen: false).fetchAllOrders();
  }

  void _refresh() {
    setState(() {
      _loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Order>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('❌ Lỗi khi tải đơn hàng.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có đơn hàng nào.'));
          }

          final pendingOrders = snapshot.data!
              .where((order) => order.status == 'Chờ xác nhận')
              .toList();

          if (pendingOrders.isEmpty) {
            return const Center(child: Text('Không có đơn hàng chờ xác nhận.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pendingOrders.length,
            itemBuilder: (context, index) {
              final order = pendingOrders[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === LEFT COLUMN ===
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🛒 Sản phẩm:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ...order.items.map((CartItem item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        item.product.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.product.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500)),
                                          Text('Số lượng: ${item.quantity}'),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${item.totalPrice.toStringAsFixed(0)} đ',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 10),
                            Text(
                              '💰 Tổng tiền: ${order.total.toStringAsFixed(0)} đ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '📦 Thông tin người mua:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('👤 ${order.name.isNotEmpty ? order.name : "Không rõ"}'),
                            Text('📞 ${order.phone.isNotEmpty ? order.phone : "Không rõ"}'),
                            Text('🏠 ${order.address.isNotEmpty ? order.address : "Không rõ"}'),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      SizedBox(
                        height: 150, // hoặc MediaQuery.of(context).size.height * 0.2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Provider.of<OrderProvider>(context, listen: false)
                                    .updateOrderStatus(order.id, 'Đang giao');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✅ Đã xác nhận đơn hàng.')),
                                );

                                _refresh();
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Xác nhận'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(100, 40),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Provider.of<OrderProvider>(context, listen: false)
                                    .updateOrderStatus(order.id, 'Đã huỷ');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('❌ Đã huỷ đơn hàng.')),
                                );

                                _refresh();
                              },
                              icon: const Icon(Icons.cancel),
                              label: const Text('Huỷ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(100, 40),
                              ),
                            ),
                          ],
                        ),
                      ),

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
