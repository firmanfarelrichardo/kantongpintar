import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart'; // Pastikan import ini benar
import '../../utils/currency_format.dart';   // Pastikan import ini benar

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  int touchedIndex = -1; // Untuk animasi saat disentuh

  @override
  Widget build(BuildContext context) {
    // Mengambil data dari HomeProvider yang sudah kita buat
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        // Filter hanya transaksi Pengeluaran (Expense)
        final expenseTrx = provider.recentTransactions.where((tx) => tx.type == 'expense').toList();

        // Hitung total per kategori
        Map<String, double> categoryTotals = {};
        double totalExpense = 0;

        for (var tx in expenseTrx) {
          categoryTotals[tx.categoryName] = (categoryTotals[tx.categoryName] ?? 0) + tx.amount;
          totalExpense += tx.amount;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE), // Background abu terang
          appBar: AppBar(
            title: const Text('Analisis Pengeluaran'),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 18),
          ),
          body: expenseTrx.isEmpty
              ? _buildEmptyState()
              : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 1. CONTAINER GRAFIK
              Container(
                height: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Komposisi Pengeluaran",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _generateSections(categoryTotals, totalExpense),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. LIST KETERANGAN (LEGEND)
              const Text(
                "Detail Kategori",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...categoryTotals.entries.map((entry) {
                final percentage = (entry.value / totalExpense * 100).toStringAsFixed(1);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12, height: 12,
                            decoration: BoxDecoration(
                              color: _getColor(entry.key), // Warna dinamis
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "$percentage%",
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CurrencyFormat.toIDR(entry.value),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _generateSections(Map<String, double> data, double total) {
    int i = 0;
    return data.entries.map((entry) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 18.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final percentage = (entry.value / total * 100);

      final section = PieChartSectionData(
        color: _getColor(entry.key),
        value: percentage,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
      i++;
      return section;
    }).toList();
  }

  // Fungsi sederhana untuk generate warna berdasarkan nama kategori (agar konsisten)
  Color _getColor(String text) {
    final colors = [
      const Color(0xFF2A2A72), // Biru Tua
      const Color(0xFF009FFD), // Biru Muda
      const Color(0xFFFF6B6B), // Merah Soft
      const Color(0xFF4ECDC4), // Tosca
      const Color(0xFFFFD93D), // Kuning
      const Color(0xFF95A5A6), // Abu
    ];
    return colors[text.length % colors.length];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Belum ada data pengeluaran", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}