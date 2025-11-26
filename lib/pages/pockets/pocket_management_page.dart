import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/models/category.dart';
import 'package:testflutter/models/pocket.dart';
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/services/category_repository.dart';
import 'package:testflutter/services/pocket_repository.dart';
import 'package:testflutter/pages/pockets/pocket_form_modal.dart';
import 'package:testflutter/services/transaction_repository.dart';

class PocketManagementPage extends StatefulWidget {
  const PocketManagementPage({super.key});

  @override
  State<PocketManagementPage> createState() => _PocketManagementPageState();
}

class _PocketManagementPageState extends State<PocketManagementPage> {
  bool _isLoading = true;
  List<Pocket> _pockets = [];
  Map<String, Account> _accountMap = {};
  Map<String, double> _pocketExpenses = {};

  final _pocketRepo = PocketRepository();
  final _accountRepo = AccountRepository();
  final _transactionRepo = TransactionRepository();

  // Warna Tema
  final Color _primaryColor = const Color(0xFF2A2A72);
  final Color _backgroundColor = const Color(0xFFF8F9FE);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _pocketRepo.getAllPockets(),
        _accountRepo.getAllAccounts(),
        _transactionRepo.getAggregatedExpensesByPocket(),
      ]);

      if (mounted) {
        setState(() {
          _pockets = results[0] as List<Pocket>;
          final accounts = results[1] as List<Account>;
          _pocketExpenses = results[2] as Map<String, double>;
          _accountMap = { for (var a in accounts) a.id : a };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddPocketModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketFormModal(onSaveSuccess: _loadData),
    );
  }

  Future<void> _deletePocket(String id) async {
    try {
      await _pocketRepo.deletePocket(id);
      _loadData();
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kantong dihapus")));
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal hapus. Kantong sedang dipakai.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Anggaran Bulanan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 18),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPocketModal,
        backgroundColor: const Color(0xFF009FFD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pockets.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _pockets.length,
        itemBuilder: (context, index) {
          return _buildPocketCard(_pockets[index]);
        },
      ),
    );
  }

  Widget _buildPocketCard(Pocket pocket) {
    final formatCurrency = NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Kalkulasi Progress
    final expenses = _pocketExpenses[pocket.id] ?? 0.0;
    final limit = pocket.budgetedAmount;
    final remaining = limit - expenses;
    double progress = limit > 0 ? (expenses / limit) : 0.0;
    if (progress > 1.0) progress = 1.0;

    // Tentukan Warna Status
    Color statusColor = Colors.green;
    if (progress >= 0.9) statusColor = Colors.red;
    else if (progress >= 0.75) statusColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pocket.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Sumber: ${_accountMap[pocket.accountId]?.name ?? "Akun"}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () => _confirmDelete(pocket),
              )
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 12),

          // Detail Angka
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Terpakai", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    formatCurrency.format(expenses),
                    style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Sisa Budget", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    formatCurrency.format(remaining),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Pocket pocket) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Hapus ${pocket.name}?"),
        content: const Text("Data budget akan dihapus, tapi transaksi terkait tetap aman."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deletePocket(pocket.id);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada anggaran dibuat",
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            "Tekan (+) untuk mulai budgeting",
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }
}