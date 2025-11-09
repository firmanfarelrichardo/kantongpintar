// lib/services/pocket_service.dart

import '../models/pocket.dart';

/// Kelas Service untuk mengelola data Pocket (Kantong).
/// Data disimpan dalam memori (RAM).
class PocketService {
  
  static final PocketService _instance = PocketService._internal();

  factory PocketService() {
    return _instance;
  }

  PocketService._internal();

  // Daftar Kantong
  final List<Pocket> _pockets = [
    // Data dummy agar ada 1 Kantong saat aplikasi pertama kali dibuka (Sesuai desain)
    Pocket(
      id: 'p1', 
      name: 'Gaji', 
      type: 'Pendapatan', 
      initialBalance: 5000000, 
      dateCreated: DateTime.now(),
    ),
    Pocket(
      id: 'p2', 
      name: 'Warung', 
      type: 'Pengeluaran', 
      initialBalance: 2000000, 
      dateCreated: DateTime.now(),
    ),
  ];

  List<Pocket> getPockets() {
    return List.unmodifiable(_pockets);
  }

  void addPocket(Pocket pocket) {
    _pockets.add(pocket);
  }
  
  // Fungsi tambahan untuk mendapatkan total saldo awal dari semua kantong
  double getInitialTotalBalance() {
    return _pockets.fold(0.0, (sum, pocket) => sum + pocket.initialBalance);
  }

  // Fungsi untuk mencari nama kantong berdasarkan ID (diperlukan untuk transaksi)
  Pocket? getPocketById(String id) {
    try {
      return _pockets.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}