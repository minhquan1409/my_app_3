import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';

class AdminProductDetailScreen extends StatefulWidget {
  final Product product;

  const AdminProductDetailScreen({super.key, required this.product});

  @override
  State<AdminProductDetailScreen> createState() => _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.product.category);
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _imageController = TextEditingController(text: widget.product.imageUrl);
    _descriptionController = TextEditingController(text: widget.product.description);
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _saveChanges() async {
    final updatedProduct = Product(
      id: widget.product.id,
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      imageUrl: _imageController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
    );

    await Provider.of<ProductProvider>(context, listen: false).updateProduct(updatedProduct);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật sản phẩm thành công')),
      );
      Navigator.pop(context); // Quay lại màn trước
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa sản phẩm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Giá'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'URL hình ảnh'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Danh mục'),
            ),

            const SizedBox(height:20),

            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Cập nhật thông tin'),
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
