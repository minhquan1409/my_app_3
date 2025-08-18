import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:my_app_3/screens/admin/admin_product_detail.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';

class AdminProductScreen extends StatefulWidget {
  final String category;

  const AdminProductScreen({super.key, required this.category});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = Future.delayed(Duration.zero, () {
      return Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final imageController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm sản phẩm mới'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Giá'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'URL hình ảnh'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0.0;
              final imageUrl = imageController.text.trim();
              final description = descriptionController.text.trim();

              if (name.isEmpty || price <= 0 || imageUrl.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin hợp lệ')),
                );
                return;
              }

              final newProduct = Product(
                id: '',
                name: name,
                description: description,
                price: price,
                imageUrl: imageUrl,
                category: widget.category,
              );

              await Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct);
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xoá sản phẩm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await Provider.of<ProductProvider>(context, listen: false).deleteProduct(product.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SẢN PHẨM - ${widget.category}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProductDialog(context),
            tooltip: 'Thêm sản phẩm',
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchFuture,
        builder: (context, snapshot) {
          final productProvider = Provider.of<ProductProvider>(context);
          final products = productProvider.getProductsByCategory(widget.category);

          Widget bodyContent;

          if (snapshot.connectionState == ConnectionState.waiting || productProvider.isLoading) {
            bodyContent = const Center(child: CircularProgressIndicator());
          } else if (products.isEmpty) {
            bodyContent = const Center(child: Text('Không có sản phẩm nào.'));
          } else {
            bodyContent = ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (ctx, index) {
                final product = products[index];
                return FadeInRight(
                  duration: const Duration(milliseconds: 300),
                  child: ListTile(
                      leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15), // bo tròn
                            border: Border.all(
                              color: Colors.black, // Màu viền
                              width: 2, // Độ dày viền
                            ),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Image.network(
                          product.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),

                    title: Text(product.name),
                    subtitle: Text('${product.price.toStringAsFixed(0)} đ'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, product),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminProductDetailScreen(product: product)),
                      );
                    },
                  ),
                );
              },
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: bodyContent,
          );
        },
      ),
    );
  }
}
