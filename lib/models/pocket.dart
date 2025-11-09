// lib/models/pocket.dart

/// Kelas Model untuk merepresentasikan fitur 'Kantong' (Wallet/Akun).
class Pocket {
  final String id;
  final String name;
  final String type; // Contoh: Tabungan, Harian
  final double initialBalance; // Saldo awal kantong
  final DateTime dateCreated;

  Pocket({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.dateCreated,
  });

  // Helper untuk membuat salinan objek (Clean Code)
  Pocket copyWith({
    String? id,
    String? name,
    String? type,
    double? initialBalance,
    DateTime? dateCreated,
  }) {
    return Pocket(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}