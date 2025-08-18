import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Product> _products = [];

  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch toàn bộ sản phẩm từ Firestore
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('products').get();
      _products.clear();
      _products.addAll(
        snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)),
      );
    } catch (e) {
      _error = 'Lỗi khi tải sản phẩm: $e';
      print(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Lọc sản phẩm theo danh mục
  List<Product> getProductsByCategory(String category) {
    return _products
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  Product? getById(String id) {
    return _products.firstWhere(
      (p) => p.id == id,
      orElse: () => Product(
        id: '',
        name: '',
        description: '',
        price: 0,
        imageUrl: '',
        category: '',
      ),
    );
  }

  /// ✅ Thêm sản phẩm mới và đẩy lên Firestore
  Future<void> addProduct(Product product) async {
    try {
      final docRef = await _firestore.collection('products').add(product.toMap());
      final newProduct = Product.fromMap(product.toMap(), docRef.id);
      _products.add(newProduct);
      notifyListeners();
    } catch (e) {
      print('Lỗi khi thêm sản phẩm: $e');
      throw Exception('Lỗi khi thêm sản phẩm: $e');
    }
  }

  /// ✅ Xóa sản phẩm theo ID
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      print('Lỗi khi xóa sản phẩm: $e');
      throw Exception('Lỗi khi xóa sản phẩm: $e');
    }
  }
  
  Future<void> updateProduct(Product product) async {
  try {
    final docRef = _firestore.collection('products').doc(product.id);

    // Cập nhật dữ liệu lên Firestore
    await docRef.update(product.toMap());

    // Cập nhật dữ liệu trong local list
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  } catch (e) {
    debugPrint('Lỗi khi cập nhật sản phẩm: $e');
    rethrow;
  }
}
}


