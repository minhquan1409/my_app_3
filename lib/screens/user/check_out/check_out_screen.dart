import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/user_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final user = context.read<UserProvider>().user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập.')),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin cá nhân')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      await orderProvider.placeOrder(cartProvider.items, user);
      cartProvider.clearCart();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Đặt hàng thành công'),
          content: Text(
            'Cảm ơn bạn, ${_nameController.text}!\nĐơn hàng sẽ được giao đến:\n${_addressController.text}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Về trang chính'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đặt hàng: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sản phẩm',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...cartProvider.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          item.product.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('${item.quantity} x ${currencyFormat.format(item.product.price)} đ'),
                          ],
                        ),
                      ),
                      Text(
                        '${currencyFormat.format(item.totalPrice)} đ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),

              const Divider(height: 32, thickness: 1),

              const Text(
                'Thông tin nhận hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Họ và tên',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Địa chỉ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Đệm để không bị che
            ],
          ),
        ),
      ),

      // PHẦN CỐ ĐỊNH Ở CUỐI MÀN HÌNH
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tổng cộng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${currencyFormat.format(cartProvider.totalAmount)} đ',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Nút thanh toán
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isPlacingOrder
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.payment),
                onPressed: _isPlacingOrder
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _placeOrder();
                        }
                      },
                label: const Text(
                  'Xác nhận thanh toán',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

// import '../../providers/cart_provider.dart';
// import '../../providers/order_provider.dart';
// import '../../providers/user_provider.dart';

// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({super.key});

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _addressController = TextEditingController();

//   bool _isPlacingOrder = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadUserInfo();
//     });
//   }

//   void _loadUserInfo() {
//     final user = context.read<UserProvider>().user;
//     if (user != null) {
//       _nameController.text = user.name;
//       _phoneController.text = user.phone;
//       _addressController.text = user.address;
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   Future<void> _placeOrder() async {
//     final cartProvider = context.read<CartProvider>();
//     final orderProvider = context.read<OrderProvider>();
//     final user = context.read<UserProvider>().user;

//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng đăng nhập.')),
//       );
//       return;
//     }

//     if (_nameController.text.trim().isEmpty ||
//         _phoneController.text.trim().isEmpty ||
//         _addressController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin cá nhân')),
//       );
//       return;
//     }

//     setState(() => _isPlacingOrder = true);

//     try {
//       await orderProvider.placeOrder(cartProvider.items, user.uid);
//       cartProvider.clearCart();

//       if (!mounted) return;

//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: const Text('Đặt hàng thành công'),
//           content: Text(
//             'Cảm ơn bạn, ${_nameController.text}!\nĐơn hàng sẽ được giao đến:\n${_addressController.text}',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).popUntil((route) => route.isFirst);
//               },
//               child: const Text('Về trang chính'),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Lỗi khi đặt hàng: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _isPlacingOrder = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cartProvider = context.watch<CartProvider>();
//     final currencyFormat = NumberFormat('#,###', 'vi_VN');

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Thanh toán'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: cartProvider.items.length,
//                 itemBuilder: (context, index) {
//                   final item = cartProvider.items[index];
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // STT
//                         Padding(
//                           padding: const EdgeInsets.only(right: 8),
//                           child: CircleAvatar(
//                             radius: 14,
//                             backgroundColor: Colors.deepPurple.shade100,
//                             child: Text(
//                               '${index + 1}',
//                               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ),
//                         // Hình ảnh
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(6),
//                           child: Image.network(
//                             item.product.imageUrl,
//                             width: 50,
//                             height: 50,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         // Tên + mô tả
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 item.product.name,
//                                 style: const TextStyle(fontWeight: FontWeight.w600),
//                               ),
//                               const SizedBox(height: 4),
//                               Text('${item.quantity} x ${currencyFormat.format(item.product.price)} đ'),
//                             ],
//                           ),
//                         ),
//                         // Tổng giá
//                         const SizedBox(width: 20),
//                         Text(
//                           '${currencyFormat.format(item.totalPrice)} đ',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   );

//                 },
//               ),
//             ),
//             const SizedBox(height: 12),
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(labelText: 'Họ và tên'),
//                   ),
//                   TextFormField(
//                     controller: _phoneController,
//                     decoration: const InputDecoration(labelText: 'Số điện thoại'),
//                     keyboardType: TextInputType.phone,
//                   ),
//                   TextFormField(
//                     controller: _addressController,
//                     decoration: const InputDecoration(labelText: 'Địa chỉ'),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Tổng cộng:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                 Text(
//                   '${currencyFormat.format(cartProvider.totalAmount)} đ',
//                   style: const TextStyle(fontSize: 18, color: Colors.redAccent, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: _isPlacingOrder
//                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                     : const Icon(Icons.payment),
//                 onPressed: _isPlacingOrder
//                     ? null
//                     : () {
//                         if (_formKey.currentState!.validate()) {
//                           _placeOrder();
//                         }
//                       },
//                 label: const Text('Xác nhận thanh toán'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
