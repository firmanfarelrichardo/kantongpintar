// lib/models/category.dart
// (100% Siap Pakai)

/// Model Data untuk tabel 'Categories'.
/// Digunakan untuk mengelompokkan transaksi.
class Category {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'
  final String? iconEmoji;
  final String? parentId; // Untuk sub-kategori
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.iconEmoji,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon_emoji': iconEmoji,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      iconEmoji: map['icon_emoji'] as String?,
      parentId: map['parent_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}