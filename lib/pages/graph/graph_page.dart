// lib/pages/graph/graph_page.dart
// (100% Siap Pakai - Menggantikan file lama dengan Pie Chart fungsional)

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Pastikan fl_chart ada di pubspec.yaml
import 'package:testflutter/models/category.dart' as model;
import 'package:testflutter/models/transaction.dart' as model;
import 'package:testflutter/services/category_repository.dart';
import 'package:testflutter/services/transaction_repository.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  // === 1. State ===
  bool _isLoading = true;
  int _touchedIndex = -1; // Untuk interaksi chart

  // Data yang sudah diproses untuk chart
  Map<String, double> _expenseData = {};
  // Peta untuk menyimpan nama kategori (ID -> Nama)
  Map<String, model.Category> _categoryMap = {};

  // === 2. Repositories ===
  final TransactionRepository _transactionRepo = TransactionRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  // === 3. Colors ===
  // Daftar warna default untuk chart agar "Gen Z"
  final List<Color> _chartColors = [
    Colors.purple[400]!,
    Colors.blue[400]!,
    Colors.green[400]!,
    Colors.orange[400]!,
    Colors.red[400]!,
    Colors.teal[400]!,
    Colors.pink[400]!,
    Colors.indigo[400]!,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // === 4. Data Loading & Processing ===
  Future<void> _loadData() async {
    setState(() { _isLoading = true; });

    try {
      // 1. Ambil semua data
      final transactions = await _transactionRepo.getAllTransactions();
      final categories = await _categoryRepo.getCategoriesByType('expense');

      // 2. Buat "Peta" Kategori
      final catMap = { for (var c in categories) c.id : c };

      // 3. Agregasi (Proses) Data
      // Kita akan menjumlahkan total pengeluaran per kategori
      final aggData = <String, double>{};
      for (final trx in transactions) {
        // Hanya proses 'expense' yang memiliki kategori
        if (trx.type == 'expense' && trx.categoryId != null) {
          // Jika kategori sudah ada di map, tambahkan. Jika tidak, buat baru.
          aggData[trx.categoryId!] = (aggData[trx.categoryId!] ?? 0) + trx.amount;
        }
      }

      // 4. Update State
      if (mounted) {
        setState(() {
          _expenseData = aggData;
          _categoryMap = catMap;
          _isLoading = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data grafik: $e')),
        );
      }
    }
  }

  // === 5. Build Method ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grafik Pengeluaran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_expenseData.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada data pengeluaran untuk ditampilkan.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    
    // Ubah data Map menjadi List<PieChartSectionData>
    final List<PieChartSectionData> sections = _buildChartSections();

    return SingleChildScrollView(
      child: Column(
        children: [
          // === Pie Chart ===
          AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2, // Jarak antar irisan
                centerSpaceRadius: 40, // Lubang di tengah
                sections: sections,
              ),
            ),
          ),
          
          // === Legenda Chart ===
          _buildLegend(),
        ],
      ),
    );
  }

  /// Helper untuk membuat irisan Pie Chart dari data
  List<PieChartSectionData> _buildChartSections() {
    final List<PieChartSectionData> sections = [];
    int index = 0;
    
    // Hitung total untuk kalkulasi persentase
    final double totalValue = _expenseData.values.fold(0, (prev, e) => prev + e);

    for (final entry in _expenseData.entries) {
      final isTouched = (index == _touchedIndex);
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final percentage = (entry.value / totalValue) * 100;
      
      final categoryName = _categoryMap[entry.key]?.name ?? 'Lainnya';
      final color = _chartColors[index % _chartColors.length]; // Ambil warna
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: entry.value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
      );
      index++;
    }
    return sections;
  }
  
  /// Helper untuk membuat legenda di bawah chart
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        children: _expenseData.entries.map((entry) {
          final index = _expenseData.keys.toList().indexOf(entry.key);
          final color = _chartColors[index % _chartColors.length];
          final name = _categoryMap[entry.key]?.name ?? 'Lainnya';
          final value = entry.value;

          return _Indicator(
            color: color,
            text: '$name (Rp ${value.toStringAsFixed(0)})',
            isSquare: false,
          );
        }).toList(),
      ),
    );
  }
}

/// Widget kecil untuk item legenda (diambil dari contoh fl_chart)
class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}