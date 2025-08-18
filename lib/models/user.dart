class AppUser {
  final String uid;
  final String name;
  final String phone;
  final String address;
  final String membership;
  final double totalSpent;
  final bool isAdmin;

  AppUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.address,
    required this.membership,
    this.totalSpent = 0.0,
    this.isAdmin = false,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    final role = map['role'];
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      membership: map['membership'] ?? 'bronze',
      totalSpent: (map['totalSpent'] as num?)?.toDouble() ?? 0.0,
      isAdmin: role == 'admin', 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'role': isAdmin ? 'admin' : 'user', // ✅ Lưu ngược lại đúng format
      'membership': membership,
      'totalSpent': totalSpent,
    };
  }
}
