// lib/models/transaction.dart
// (100% Siap Pakai)

/// Model Data untuk tabel 'Transactions'.
/// Ini adalah perombakan dari model lama (lib/models/transaction.dart)
/// untuk mencocokkan skema database profesional kita.
class Transaction {
  final String id;
  final String accountId;      // Dulu tidak ada
  final String? categoryId;     // Dulu tidak ada
  final String? pocketId;       // Dulu 'pocketId' ada, tapi tidak opsional
  final String? transferGroupId; // Baru: untuk transfer
  final double amount;
  final String type;             // 'income', 'expense', atau 'transfer'
  final String? description;    // Deskripsi sekarang opsional
  final DateTime transactionDate; // Dulu 'date'
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.accountId,
    this.categoryId,
    this.pocketId,
    this.transferGroupId,
    required this.amount,
    required this.type,
    this.description,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Fungsi 'toMap': Mengubah object Dart (Transaction) menjadi Map.
  /// Ini adalah "Pintu Keluar" untuk mengirim data KE database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'category_id': categoryId,
      'pocket_id': pocketId,
      'transfer_group_id': transferGroupId,
      'amount': amount,
      'type': type,
      'description': description,
      // Kita simpan tanggal sebagai teks ISO8601 (standar profesional)
      'transaction_date': transactionDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Fungsi 'fromMap': Mengubah Map dari database menjadi object Dart.
  /// Ini adalah "Pintu Masuk" untuk data DARI database.
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      accountId: map['account_id'] as String,
      categoryId: map['category_id'] as String?,
      pocketId: map['pocket_id'] as String?,
      transferGroupId: map['transfer_group_id'] as String?,
      amount: map['amount'] as double,
      type: map['type'] as String,
      description: map['description'] as String?,
      // Kita ubah kembali teks ISO8601 menjadi object DateTime
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}