import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeliveredOrdersScreen extends StatelessWidget {
  const DeliveredOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'Đã giao')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('❌ Đã xảy ra lỗi.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return const Center(child: Text('Không có đơn hàng đã giao.'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final orderDoc = orders[index];
            final orderData = orderDoc.data() as Map<String, dynamic>;

            final userName = orderData['name'] ?? 'Không rõ';
            final userAddress = orderData['address'] ?? '';
            final userPhone = orderData['phone'] ?? '';
            final totalPrice = orderData['total'] ?? 0;

            // Lấy danh sách items từ Firestore
            final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);

            return Card(
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('👤 Người đặt: $userName',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('📍 Địa chỉ: $userAddress'),
                    const SizedBox(height: 4),
                    Text('📞 SĐT: $userPhone'),
                    const SizedBox(height: 8),

                    const Text('🛒 Sản phẩm:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),

                    // Hiển thị từng sản phẩm
                    ...items.map((item) {
                      final productData = item['product'] ?? {};
                      final productName = productData['name'] ?? 'Không rõ';
                      final productPrice = productData['price'] ?? 0;
                      final imageUrl = productData['imageUrl'] ?? '';
                      final quantity = item['quantity'] ?? 1;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: imageUrl.isNotEmpty
                            ? Image.network(imageUrl,
                                width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported),
                        title: Text(productName),
                        subtitle: Text(
                            'Giá: ${productPrice.toStringAsFixed(0)} VND\nSố lượng: $quantity'),
                      );
                    }).toList(),

                    const SizedBox(height: 4),
                    Text('💰 Tổng tiền: ${totalPrice.toStringAsFixed(0)} VND',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange)),
                    const SizedBox(height: 8),

                    const Text('✅ Đã giao',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
