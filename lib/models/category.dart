
class Category {
  final String id;
  final String name;
  final String icon;

  Category({required this.id, required this.name, required this.icon});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      name: map['name'],
      icon: map['icon'],
    );
  }
}
