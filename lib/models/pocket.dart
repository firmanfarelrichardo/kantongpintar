// lib/models/pocket.dart
// (100% Siap Pakai - Menggantikan file lama)

/// Model Data untuk tabel 'Pockets'.
/// Ini adalah "amplop" virtual untuk budgeting.
class Pocket {
  final String id;
  final String accountId; // FK ke 'Accounts'
  final String? categoryId; // FK ke 'Categories' (opsional)
  final String name;
  final double budgetedAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pocket({
    required this.id,
    required this.accountId,
    this.categoryId,
    required this.name,
    required this.budgetedAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'category_id': categoryId,
      'name': name,
      'budgeted_amount': budgetedAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Pocket.fromMap(Map<String, dynamic> map) {
    return Pocket(
      id: map['id'] as String,
      accountId: map['account_id'] as String,
      categoryId: map['category_id'] as String?,
      name: map['name'] as String,
      budgetedAmount: map['budgeted_amount'] as double,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}