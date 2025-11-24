// lib/pages/graph/graph_page.dart
// (REDESIGN: Bar Chart Analysis)

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testflutter/main.dart';
import 'package:testflutter/models/account.dart';
import 'package:testflutter/models/transaction.dart';
import 'package:testflutter/services/account_repository.dart';
import 'package:testflutter/services/transaction_repository.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  bool _isLoading = true;
  List<Account> _accounts = [];

  // Data untuk Grafik: Key = Account ID, Value = {income: 0.0, expense: 0.0}
  Map<String, Map<String, double>> _chartData = {};

  final _trxRepo = TransactionRepository();
  final _accRepo = AccountRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    try {
      final results = await Future.wait([
        _accRepo.getAllAccounts(),
        _trxRepo.getAllTransactions(),
      ]);

      final accounts = results[0] as List<Account>;
      final transactions = results[1] as List<Transaction>;

      // Proses Data untuk Bar Chart
      Map<String, Map<String, double>> data = {};

      // Inisialisasi semua akun dengan 0
      for (var acc in accounts) {
        data[acc.id] = {'income': 0.0, 'expense': 0.0};
      }

      // Isi data
      for (var t in transactions) {
        if (data.containsKey(t.accountId)) {
          if (t.type == 'income') {
            data[t.accountId]!['income'] = (data[t.accountId]!['income'] ?? 0) + t.amount;
          } else if (t.type == 'expense') {
            data[t.accountId]!['expense'] = (data[t.accountId]!['expense'] ?? 0) + t.amount;
          }
        }
      }

      if (mounted) {
        setState(() {
          _accounts = accounts;
          _chartData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Analysis')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
          ? const Center(child: Text('Belum ada data akun.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Judul Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(kDangerColor, 'Expense'),
                const SizedBox(width: 20),
                _buildLegend(kSuccessColor, 'Income'),
              ],
            ),
            const SizedBox(height: 40),

            // Bar Chart
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxY(),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _bottomTitles,
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _generateGroups(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget untuk judul sumbu bawah (Nama Akun)
  Widget _bottomTitles(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= _accounts.length) return const SizedBox.shrink();

    // Ambil nama akun, ambil 4 huruf pertama saja agar muat
    String name = _accounts[index].name;
    if (name.length > 4) name = name.substring(0, 4);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(name, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    );
  }

  List<BarChartGroupData> _generateGroups() {
    List<BarChartGroupData> groups = [];
    for (int i = 0; i < _accounts.length; i++) {
      final accId = _accounts[i].id;
      final income = _chartData[accId]?['income'] ?? 0.0;
      final expense = _chartData[accId]?['expense'] ?? 0.0;

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: expense, color: kDangerColor, width: 12, borderRadius: BorderRadius.circular(4)),
            BarChartRodData(toY: income, color: kSuccessColor, width: 12, borderRadius: BorderRadius.circular(4)),
          ],
        ),
      );
    }
    return groups;
  }

  double _calculateMaxY() {
    double maxVal = 0;
    _chartData.forEach((key, value) {
      if (value['income']! > maxVal) maxVal = value['income']!;
      if (value['expense']! > maxVal) maxVal = value['expense']!;
    });
    return maxVal == 0 ? 1000 : maxVal * 1.2; // Tambah buffer 20%
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
      ],
    );
  }
}