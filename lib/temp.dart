import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/cart_item_widget.dart';
import 'screens/user/check_out/check_out_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final currencyFormat = NumberFormat('#,###', 'vi_VN');
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Tiêu đề
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '🛒 Giỏ hàng của bạn',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),

            // Nếu giỏ hàng trống
            if (cartProvider.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'Giỏ hàng đang trống',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else ...[
              // Danh sách sản phẩm
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = cartProvider.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: CartItemWidget(cartItem: item),
                    );
                  },
                  childCount: cartProvider.items.length,
                ),
              ),

              // Tổng tiền + nút
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
                        // Tổng tiền
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng cộng:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${currencyFormat.format(cartProvider.totalAmount)} VNĐ',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Nút đặt hàng
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.shopping_cart_checkout),
                          label: const Text(
                            'Tiến hành đặt hàng',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        // Nút xóa toàn bộ
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xác nhận'),
                                content: const Text('Bạn có chắc muốn xoá toàn bộ giỏ hàng?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Hủy'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      cartProvider.clearCart();
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text('Xoá'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          label: const Text(
                            'Xoá toàn bộ giỏ hàng',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
      ),
    );
  }
}