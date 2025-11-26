import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testflutter/models/pocket.dart';
import 'package:testflutter/providers/home_provider.dart';
import 'package:testflutter/services/pocket_repository.dart';
import 'package:testflutter/pages/pockets/pocket_form_modal.dart';

class PocketManagementPage extends StatefulWidget {
  const PocketManagementPage({super.key});

  @override
  State<PocketManagementPage> createState() => _PocketManagementPageState();
}

class _PocketManagementPageState extends State<PocketManagementPage> {
  final _pocketRepo = PocketRepository();
  final Color _backgroundColor = const Color(0xFFF8F9FE);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HomeProvider>().loadHomeData());
  }

  void _showAddPocketModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketFormModal(
        onSaveSuccess: () {
          context.read<HomeProvider>().loadHomeData();
        },
      ),
    );
  }

  void _showEditPocketModal(Pocket pocket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketFormModal(
        onSaveSuccess: () {
          context.read<HomeProvider>().loadHomeData();
        },
        pocketToEdit: pocket,
      ),
    );
  }

  Future<void> _deletePocket(String id) async {
    try {
      await _pocketRepo.deletePocket(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kantong dihapus")));
        context.read<HomeProvider>().loadHomeData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal hapus.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final pockets = provider.pockets;
        final allTransactions = provider.allTransactions;
        final accountMap = { for (var a in provider.accounts) a.id : a };

        return Scaffold(
          backgroundColor: _backgroundColor,
          appBar: AppBar(
            title: const Text('Anggaran Bulanan'),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 18),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.grey),
                onPressed: () => provider.loadHomeData(),
              )
            ],
          ),

          // === PERBAIKAN TOMBOL TAMBAH (+) ===
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddPocketModal,
            backgroundColor: const Color(0xFF009FFD), // Warna Biru Terang
            shape: const CircleBorder(), // MEMBUATNYA BULAT SEMPURNA
            elevation: 4,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          // ===================================

          body: pockets.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: pockets.length,
            itemBuilder: (context, index) {
              final pocket = pockets[index];
              final pocketTrx = allTransactions.where((t) => t.pocketId == pocket.id && t.type == 'expense');
              final expenses = pocketTrx.fold(0.0, (sum, t) => sum + t.amount);

              return _buildPocketCard(pocket, expenses, accountMap);
            },
          ),
        );
      },
    );
  }

  Widget _buildPocketCard(Pocket pocket, double expenses, Map accountMap) {
    final formatCurrency = NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final limit = pocket.budgetedAmount;
    final remaining = limit - expenses;
    double progress = limit > 0 ? (expenses / limit) : 0.0;
    if (progress > 1.0) progress = 1.0;

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
                      'Sumber: ${accountMap[pocket.accountId]?.name ?? "Akun"}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    onPressed: () => _showEditPocketModal(pocket),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(pocket),
                    tooltip: 'Hapus',
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),

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
        content: const Text("Data budget akan dihapus."),
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
          Text("Belum ada anggaran dibuat", style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 8),
          Text("Tekan (+) untuk mulai budgeting", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }
}