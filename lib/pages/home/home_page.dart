import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../utils/currency_format.dart';
import '../transaction/transaction_form_modal.dart'; // Import form tambah
import '../transaction/transaction_list_page.dart'; // Import halaman lihat semua

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // === KONFIGURASI WARNA TEMA ===
  final Color _primaryColor = const Color(0xFF2A2A72); // Biru Tua Premium
  final Color _accentColor = const Color(0xFF009FFD); // Biru Terang
  final Color _backgroundColor = const Color(0xFFF8F9FE); // Abu-abu Terang

  @override
  void initState() {
    super.initState();
    // Memuat data saat halaman pertama kali dibuka
    Future.microtask(() => context.read<HomeProvider>().loadHomeData());
  }

  // === FUNGSI MEMUNCULKAN MODAL TAMBAH TRANSAKSI ===
  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Agar rounded corners terlihat
      builder: (ctx) {
        return TransactionFormModal(
          onSaveSuccess: () {
            // Refresh data home setelah simpan
            context.read<HomeProvider>().loadHomeData();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildCustomAppBar(),

      // === TOMBOL TAMBAH (+) MENGAMBANG ===
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionModal(context),
        backgroundColor: _accentColor,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      // ====================================

      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              // 1. KARTU SALDO UTAMA
              _buildMainBalanceCard(provider),

              const SizedBox(height: 25),

              // 2. HEADER "TRANSAKSI TERAKHIR"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Transaksi Terakhir",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // NAVIGASI KE HALAMAN DAFTAR TRANSAKSI LENGKAP
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TransactionListPage()),
                      );
                    },
                    child: const Text("Lihat Semua"),
                  )
                ],
              ),

              const SizedBox(height: 10),

              // 3. LIST TRANSAKSI
              if (provider.recentTransactions.isEmpty)
                _buildEmptyState()
              else
                ...provider.recentTransactions.map((tx) {
                  return _buildTransactionItem(tx);
                }).toList(),

              const SizedBox(height: 80), // Ruang kosong di bawah agar tidak tertutup FAB
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDER HELPERS ---

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      titleSpacing: 20,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, Pengguna!",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Selamat datang kembali",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      // Ikon pengaturan sudah dihapus di sini
    );
  }

  Widget _buildMainBalanceCard(HomeProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryColor, _accentColor],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Total Saldo",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Icon(Icons.account_balance_wallet_outlined, color: Colors.white70)
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormat.toIDR(provider.totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSummaryItem(
                icon: Icons.arrow_downward_rounded,
                color: Colors.greenAccent,
                label: "Pemasukan",
                amount: CurrencyFormat.toIDR(provider.totalIncome),
              ),
              const SizedBox(width: 24),
              _buildSummaryItem(
                icon: Icons.arrow_upward_rounded,
                color: Colors.orangeAccent,
                label: "Pengeluaran",
                amount: CurrencyFormat.toIDR(provider.totalExpense),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color color,
    required String label,
    required String amount,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              amount,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionItem(dynamic tx) {
    final isExpense = tx.type == 'expense';
    final iconBgColor = isExpense ? Colors.red[50] : Colors.green[50];
    final iconColor = isExpense ? Colors.red : Colors.green;
    final iconData = isExpense ? Icons.shopping_bag_outlined : Icons.monetization_on_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(iconData, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.categoryName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(DateTime.parse(tx.date)),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                if (tx.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tx.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic),
                  ),
                ]
              ],
            ),
          ),
          Text(
            '${isExpense ? "- " : "+ "}${CurrencyFormat.toIDR(tx.amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.redAccent : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            "Belum ada transaksi hari ini",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}