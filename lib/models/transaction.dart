// lib/models/transaction.dart (UPDATE)

enum TransactionType { 
  income,  // Pemasukan
  expense, // Pengeluaran
}

class Transaction {
  final String id; 
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date; 
  // =======================================================
  // BARU: Menambahkan Pocket ID
  final String pocketId; 
  // =======================================================

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.pocketId, // Wajib diisi
  });

  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? pocketId, // Wajib diisi
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      pocketId: pocketId ?? this.pocketId,
    );
  }
}