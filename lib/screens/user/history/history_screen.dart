import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/order.dart';
import '../../../providers/order_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Chỉ lấy đơn hàng có trạng thái "Đã giao"
  Future<List<Order>> _getDeliveredOrders(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];
    final allOrders = await Provider.of<OrderProvider>(context, listen: false).fetchOrders(userId);

    // Lọc những đơn có trạng thái "Đã giao"
    return allOrders.where((order) => order.status.toLowerCase() == 'đã giao').toList();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      body: FutureBuilder<List<Order>>(
        future: _getDeliveredOrders(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              // Tiêu đề
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '📦 Lịch sử đơn hàng',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),

              // Nếu chưa có đơn hàng
              if (orders.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'Không có đơn hàng đã giao',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              else ...[
                // Danh sách đơn hàng
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final order = orders[index];
                      final orderDate = DateFormat('dd/MM/yyyy HH:mm').format(order.timestamp);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            title: Text(
                              'Đơn hàng #${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            subtitle: Text(
                              'Ngày: $orderDate\nTổng: ${currencyFormat.format(order.total)} VNĐ',
                              style: const TextStyle(fontSize: 14),
                            ),
                            children: order.items.map<Widget>((item) {
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    item.product.imageUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(item.product.name),
                                subtitle: Text('Số lượng: ${item.quantity}'),
                                trailing: Text(
                                  '${currencyFormat.format(item.product.price * item.quantity)} đ',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                    childCount: orders.length,
                  ),
                ),

                // Tổng kết số đơn hàng đã mua
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tổng số đơn hàng đã giao:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${orders.length}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tổng tiền đã mua:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${currencyFormat.format(orders.fold<double>(0, (prev, o) => prev + o.total))} VNĐ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
