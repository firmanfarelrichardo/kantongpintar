// lib/models/account.dart
// (100% Siap Pakai)

/// Model Data untuk tabel 'Accounts'.
/// Merepresentasikan rekening bank, dompet digital, atau uang tunai.
class Account {
  final String id;
  final String name;
  final String bankName;
  final double initialBalance;
  final String? iconPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    required this.id,
    required this.name,
    required this.bankName,
    required this.initialBalance,
    this.iconPath,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Mengubah object Dart (Account) menjadi Map untuk disimpan ke SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bank_name': bankName,
      'initial_balance': initialBalance,
      'icon_path': iconPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Mengubah Map dari SQLite menjadi object Dart (Account).
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as String,
      name: map['name'] as String,
      bankName: map['bank_name'] as String,
      initialBalance: map['initial_balance'] as double,
      iconPath: map['icon_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}