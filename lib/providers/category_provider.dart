import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> fetchCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    _categories.clear();
    _categories.addAll(snapshot.docs.map((doc) => Category.fromMap(doc.data(), doc.id)));
    notifyListeners();
  }

  Future<void> addCategory(String name, String icon) async {
    final doc = await _firestore.collection('categories').add({'name': name, 'icon': icon});
    _categories.add(Category(id: doc.id, name: name, icon: icon));
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
