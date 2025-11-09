// lib/pages/saving_goals/saving_goals_page.dart
// (100% Siap Pakai - Kode ini SUDAH BENAR)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testflutter/models/saving_goal.dart';
import 'package:testflutter/services/saving_goal_repository.dart';

// Impor ini sudah benar
import 'package:testflutter/pages/saving_goals/saving_goal_form_modal.dart';
import 'package:testflutter/pages/saving_goals/saving_goal_fund_modal.dart';

/// Halaman untuk menampilkan daftar "Tujuan Nabung" (Saving Goals).
class SavingGoalsPage extends StatefulWidget {
  const SavingGoalsPage({super.key});

  @override
  State<SavingGoalsPage> createState() => _SavingGoalsPageState();
}

class _SavingGoalsPageState extends State<SavingGoalsPage> {
  // === 1. State & Repository ===
  bool _isLoading = true;
  List<SavingGoal> _goals = [];
  final _goalRepo = SavingGoalRepository();

  // === 2. Lifecycle ===
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // === 3. Data Loading ===
  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    try {
      final goals = await _goalRepo.getAllGoals();
      if (mounted) {
        setState(() {
          _goals = goals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat tujuan nabung: $e')),
        );
      }
    }
  }

  // === 4. Modal Helpers ===
  
  /// Menampilkan modal untuk menambah tujuan baru
  void _showAddGoalModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        // 'SavingGoalFormModal' sekarang sudah dikenali
        return SavingGoalFormModal(
          onSaveSuccess: _loadData, // Callback untuk me-refresh halaman ini
        );
      },
    );
  }

  /// Menampilkan modal untuk menambah dana ke tujuan
  void _showAddFundsModal(SavingGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SavingGoalFundModal(
          goal: goal,
          onSaveSuccess: _loadData,
        );
      },
    );
  }

  // === 5. Build Method ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tujuan Nabung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildGoalList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalModal, // Memanggil fungsi yang benar
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Helper untuk membangun daftar tujuan
  Widget _buildGoalList() {
    if (_goals.isEmpty) {
      return const Center(
        child: Text(
          'Kamu belum punya tujuan nabung.\nKlik tombol (+) untuk memulai! 🚀',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _goals.length,
      itemBuilder: (context, index) {
        final goal = _goals[index];
        
        double progress = 0.0;
        if (goal.targetAmount > 0) {
          progress = goal.currentAmount / goal.targetAmount;
        }
        if (progress > 1.0) progress = 1.0;

        final formatCurrency = NumberFormat.compactCurrency(
          locale: 'id_ID',
          symbol: 'Rp',
          decimalDigits: 0,
        );
        final current = formatCurrency.format(goal.currentAmount);
        final target = formatCurrency.format(goal.targetAmount);
        
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Dana'),
                      onPressed: () => _showAddFundsModal(goal),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.deepPurple),
                        foregroundColor: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$current / $target',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Text(
                      '(${(progress * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

SavingGoalFormModal({required Future<void> Function() onSaveSuccess}) {
}