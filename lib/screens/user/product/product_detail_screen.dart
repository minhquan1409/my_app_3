import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/product.dart';
import '../../../providers/cart_provider.dart';
import '../check_out/check_out_screen.dart';

class ProductDetail extends StatelessWidget {
  final Product product;
  const ProductDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final quantity = cart.totalItems;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Image.network(
              product.imageUrl,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${product.price.toStringAsFixed(0)} đ',
            style: const TextStyle(fontSize: 20, color: Colors.deepPurple),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            product.description,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 24),

          // Nút thêm vào giỏ hàng
          ElevatedButton.icon(
            onPressed: () {
              cart.addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã thêm vào giỏ hàng")),
              );
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text("Thêm vào giỏ hàng"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.deepPurple.shade200,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),

          const SizedBox(height: 12),

          // Nút tiến hành đặt hàng
          if (quantity > 0)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
              icon: const Icon(Icons.shopping_bag),
              label: const Text("Tiến hành đặt hàng"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.deepPurple.shade200,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

          const SizedBox(height: 16),

          if (quantity > 0)
            Column(
              children: [
                const Text(
                  'Điều chỉnh số lượng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        cart.decreaseQuantity(product);
                      },
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        cart.increaseQuantity(product);
                      },
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
