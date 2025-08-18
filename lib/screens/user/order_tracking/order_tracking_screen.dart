import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

    String _getStatusText(String status) {
    switch (status) {
      case 'Đang xử lý':
        return '🕒 Đang xử lý';
      case 'Đang giao':
        return '🚚 Đang giao';
      case 'Đã giao':
        return '✅ Đã giao';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đang xử lý':
        return Colors.orange;
      case 'Đang giao':
        return Colors.blue;
      case 'Đã giao':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Bạn cần đăng nhập để xem đơn hàng")),
      );
    }

    return Scaffold(
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Lỗi khi tải đơn hàng.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text('Bạn chưa có đơn hàng nào.'));
          }

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Theo dõi đơn hàng',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final order = orders[index];
                      final orderData = order.data() as Map<String, dynamic>;

                      final status = orderData['status'] ?? 'Chưa rõ';
                      final totalPrice = orderData['total'] ?? 0;
                      final createdAt =
                          (orderData['timestamp'] as Timestamp?)?.toDate();
                      final items = List<Map<String, dynamic>>.from(
                          orderData['items'] ?? []);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ExpansionTile(
                          leading: const Icon(Icons.shopping_cart,
                              color: Colors.blue),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hiển thị sản phẩm luôn
                              ...items.map((item) {
                                final product = item['product'] ?? {};
                                final productName =
                                    product['name'] ?? 'Không rõ';
                                final productPrice = product['price'] ?? 0;
                                final imageUrl = product['imageUrl'] ?? '';
                                final quantity = item['quantity'] ?? 1;

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    children: [
                                      imageUrl.isNotEmpty
                                          ? Image.network(imageUrl,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover)
                                          : const Icon(
                                              Icons.image_not_supported),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "$productName x$quantity",
                                          style:
                                              const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      Text(
                                        "$productPrice VND",
                                        style:
                                            const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 4),
                              Text(
                                "💰 Tổng: $totalPrice VND",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          children: [
                            // Khi bấm mới hiện trạng thái
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ngày đặt: ${createdAt != null ? "${createdAt.day}/${createdAt.month}/${createdAt.year}" : "Không rõ"}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text("Trạng thái: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                        _getStatusText(status),
                                        style: TextStyle(
                                          color: _getStatusColor(status),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: orders.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


}
