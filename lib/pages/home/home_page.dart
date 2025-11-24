// lib/pages/home/home_page.dart
// (REDESIGN A: Tampilan Records ala MyMoney - Header Ringkasan & Navigasi Tanggal)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testflutter/main.dart'; // Mengambil warna tema baru
import 'package:testflutter/models/account.dart';
import 'package:testflutter/models/transaction.dart';
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/services/transaction_repository.dart';
import 'package:testflutter/pages/transaction/transaction_form_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // === State Variables ===
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now(); // Menyimpan tanggal yang sedang dipilih

  // Data List
  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = []; // Transaksi khusus hari ini
  Map<String, Account> _accountMap = {}; // Peta nama akun

  // Ringkasan Header
  double _incomeToday = 0.0;
  double _expenseToday = 0.0;
  double _balanceTotal = 0.0;

  // Repositories
  final _accountRepo = AccountRepository();
  final _transactionRepo = TransactionRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Memuat semua data dari database sekaligus
  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    try {
      final results = await Future.wait([
        _accountRepo.getAllAccounts(),
        _transactionRepo.getAllTransactions(),
      ]);

      final accounts = results[0] as List<Account>;
      final transactions = results[1] as List<Transaction>;

      // Hitung Total Aset Global (Saldo semua akun)
      double totalAsset = accounts.fold(0.0, (sum, acc) => sum + acc.initialBalance);

      // Update total asset berdasarkan seluruh income - expense bersejarah
      // (Asumsi: initialBalance adalah saldo awal, transaksi menambah/mengurangi)
      for (var t in transactions) {
        if (t.type == 'income') totalAsset += t.amount;
        if (t.type == 'expense') totalAsset -= t.amount;
      }

      // Buat Map agar kita bisa menampilkan nama akun di list transaksi dengan cepat
      final accMap = { for (var a in accounts) a.id : a };

      if (mounted) {
        setState(() {
          _accountMap = accMap;
          _allTransactions = transactions;
          _balanceTotal = totalAsset;
          _isLoading = false;
        });
        // Setelah data siap, langsung filter untuk tampilan hari ini
        _filterDataByDate();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error loading data: $e");
    }
  }

  /// Logika Inti: Memfilter transaksi hanya untuk tanggal _selectedDate
  void _filterDataByDate() {
    // Tentukan awal hari (00:00:00) dan akhir hari (23:59:59)
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

    // Ambil transaksi yang berada dalam rentang waktu tersebut
    final dailyTrx = _allTransactions.where((t) {
      return t.transactionDate.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          t.transactionDate.isBefore(endOfDay.add(const Duration(seconds: 1)));
    }).toList();

    // Hitung total Income & Expense HARI INI saja
    double inc = 0.0;
    double exp = 0.0;

    for (var t in dailyTrx) {
      if (t.type == 'income') inc += t.amount;
      if (t.type == 'expense') exp += t.amount;
    }

    setState(() {
      _filteredTransactions = dailyTrx;
      _incomeToday = inc;
      _expenseToday = exp;
      // _balanceTotal tidak berubah karena itu adalah saldo global, bukan saldo harian
    });
  }

  /// Mengubah tanggal (maju/mundur)
  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _filterDataByDate(); // Refresh data list setelah tanggal berubah
  }

  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => TransactionFormModal(onSaveSuccess: _loadData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, d MMM yyyy', 'id_ID'); // Format tanggal Indonesia
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      // Tidak perlu AppBar standar, kita buat custom header
      body: Column(
        children: [
          // === BAGIAN 1: HEADER NAVIGASI & STATISTIK ===
          Container(
            color: kBackgroundColor,
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                // A. Navigasi Tanggal (< Tanggal >)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 50, 8, 10), // Top 50 agar aman di bawah status bar
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 30, color: kTextColor),
                        onPressed: () => _changeDate(-1),
                      ),
                      Text(
                        dateFormat.format(_selectedDate),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kTextColor
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 30, color: kTextColor),
                        onPressed: () => _changeDate(1),
                      ),
                    ],
                  ),
                ),

                // B. Statistik 3 Kolom (Expense | Income | Balance)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem('EXPENSE', _expenseToday, kDangerColor), // Merah
                      _buildStatItem('INCOME', _incomeToday, kSuccessColor),  // Hijau
                      _buildStatItem('TOTAL BALANCE', _balanceTotal, kTextColor), // Abu/Hitam
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1), // Garis pemisah header

          // === BAGIAN 2: LIST TRANSAKSI ===
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTransactions.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _filteredTransactions.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 70),
              itemBuilder: (context, index) {
                final trx = _filteredTransactions[index];
                return _buildTransactionItem(trx, currencyFormat);
              },
            ),
          ),
        ],
      ),

      // Tombol Tambah (+) Biru
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionModal,
        backgroundColor: kPrimaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  // Widget kecil untuk satu item statistik (Judul kecil, Angka besar)
  Widget _buildStatItem(String label, double amount, Color color) {
    final format = NumberFormat.compactCurrency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          format.format(amount),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  // Tampilan jika tidak ada transaksi hari itu (Icon dokumen kosong)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada catatan hari ini.',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // Item list transaksi (Icon di kiri, Text di tengah, Harga di kanan)
  Widget _buildTransactionItem(Transaction trx, NumberFormat format) {
    final isExpense = trx.type == 'expense';
    final color = isExpense ? kDangerColor : kSuccessColor;
    final sign = isExpense ? '-' : '+';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.1), // Warna background pudar
        child: Icon(
            isExpense ? Icons.shopping_cart : Icons.savings, // Ikon sementara
            color: color,
            size: 18
        ),
      ),
      title: Text(
        trx.description?.isNotEmpty == true ? trx.description! : 'Tanpa Keterangan',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: kTextColor),
      ),
      subtitle: Text(
        _accountMap[trx.accountId]?.name ?? 'Akun Terhapus',
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: Text(
        '$sign ${format.format(trx.amount)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 14,
        ),
      ),
    );
  }
}