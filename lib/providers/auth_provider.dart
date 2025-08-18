import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = true;
  bool _isAdmin = false;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;

  // Gọi mỗi khi trạng thái đăng nhập thay đổi
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _user = firebaseUser;
    _isLoading = false;

    if (firebaseUser != null) {
      await _checkIfAdmin(firebaseUser.uid);
    } else {
      _isAdmin = false;
    }

    notifyListeners();
  }

  // Kiểm tra role trong collection 'users'
  Future<void> _checkIfAdmin(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      _isAdmin = data?['role'] == 'admin';
    } else {
      _isAdmin = false;
    }
  }

  // Public method để gọi lại khi cần kiểm tra quyền sau đăng nhập
  Future<void> refreshRole() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _checkIfAdmin(currentUser.uid);
      notifyListeners();
    }
  }

  // Đăng nhập
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await refreshRole();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Đăng ký
  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password); 
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _isAdmin = false;
    notifyListeners();
  }

  // Điều hướng sau khi đăng nhập
  Future<void> handleLoginRedirect(BuildContext context) async {
    if (_isAdmin) {
      Navigator.pushReplacementNamed(context, '/admin_dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
