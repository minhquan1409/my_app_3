import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import 'admin_product.dart';
import '../../utils/icon_mapper.dart';

class AdminCategoryScreen extends StatefulWidget {
  const AdminCategoryScreen({super.key});

  @override
  State<AdminCategoryScreen> createState() => _AdminCategoryScreenState();
}

class _AdminCategoryScreenState extends State<AdminCategoryScreen> {
  Future<void>? _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
  }

Future<void> _showAddCategoryDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final iconController = TextEditingController(); // Cho nhập tên icon

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Thêm danh mục mới'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên danh mục'),
            ),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(
                labelText: 'Tên icon (VD: laptop_mac, monitor)',
              ),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (ctx) {
                final previewIcon = getIconData(iconController.text.trim());
                return Icon(previewIcon, size: 36, color: Colors.deepPurple);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            final iconName = iconController.text.trim();

            if (name.isNotEmpty && iconName.isNotEmpty) {
              await Provider.of<CategoryProvider>(context, listen: false)
                  .addCategory(name, iconName);
              Navigator.pop(context);
            }
          },
          child: const Text('Thêm'),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý danh mục'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context),
            tooltip: 'Thêm danh mục',
          )
        ],
      ),
      body: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              final icon = getIconData(category.icon);

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 400),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AdminProductScreen(category: category.name),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ));
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple.shade100, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, size: 40, color: Colors.deepPurple),
                              const SizedBox(height: 12),
                              Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () {
                              categoryProvider.deleteCategory(category.id);
                            },
                          ),
                        ),
                      ],
                    ),
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
