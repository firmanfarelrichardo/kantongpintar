import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../services/category_repository.dart';
import '../../utils/currency_format.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  int _touchedIndex = -1;
  String _selectedType = 'expense'; // 'income' atau 'expense'

  // Filter Tanggal
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)), // Default 30 hari terakhir
    end: DateTime.now(),
  );

  // Cache Kategori (ID -> Nama)
  Map<String, String> _categoryNames = {};
  bool _isLoadingCategories = true;

  // Warna Tema Utama
  final Color _primaryColor = const Color(0xFF2A2A72);

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final repo = CategoryRepository();
    final expenseCats = await repo.getCategoriesByType('expense');
    final incomeCats = await repo.getCategoriesByType('income');

    if (mounted) {
      setState(() {
        for (var cat in [...expenseCats, ...incomeCats]) {
          _categoryNames[cat.id] = cat.name;
        }
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: _primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        // === 1. FILTER DATA ===
        final filteredTrx = provider.allTransactions.where((tx) {
          if (tx.type != _selectedType) return false;
          final date = tx.transactionDate;
          return date.isAfter(_selectedDateRange.start.subtract(const Duration(seconds: 1))) &&
              date.isBefore(_selectedDateRange.end.add(const Duration(days: 1)));
        }).toList();

        // === 2. HITUNG TOTAL ===
        double totalAmount = filteredTrx.fold(0, (sum, item) => sum + item.amount);

        // === 3. GROUPING KATEGORI ===
        Map<String, double> categoryMap = {};
        for (var tx in filteredTrx) {
          String catId = tx.categoryId ?? 'unknown';
          categoryMap[catId] = (categoryMap[catId] ?? 0) + tx.amount;
        }

        // === 4. GROUPING HARIAN (BAR CHART) ===
        List<double> weeklyData = List.filled(7, 0.0);
        for (var tx in filteredTrx) {
          final diff = _selectedDateRange.end.difference(tx.transactionDate).inDays;
          if (diff < 7 && diff >= 0) {
            int dayIndex = tx.transactionDate.weekday - 1;
            weeklyData[dayIndex] += tx.amount;
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AppBar(
            title: const Text('Analisis Keuangan'),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 18),
            actions: [
              IconButton(
                icon: Icon(Icons.calendar_month_rounded, color: _primaryColor),
                onPressed: _pickDateRange,
                tooltip: 'Pilih Tanggal',
              ),
            ],
          ),
          body: _isLoadingCategories
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // === INFO TOTAL ===
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Text(
                      "${DateFormat('d MMM').format(_selectedDateRange.start)} - ${DateFormat('d MMM yyyy').format(_selectedDateRange.end)}",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormat.toIDR(totalAmount),
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _selectedType == 'expense' ? Colors.redAccent : Colors.green
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // === TOGGLE ===
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    _buildToggleBtn('Pengeluaran', 'expense'),
                    _buildToggleBtn('Pemasukan', 'income'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (totalAmount == 0)
                _buildEmptyState()
              else ...[
                // === BAR CHART ===
                const Text("Tren 7 Hari Terakhir", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  height: 220,
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _calculateMaxY(weeklyData),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => _primaryColor,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              CurrencyFormat.toIDR(rod.toY),
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: _bottomTitles,
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: _generateBarGroups(weeklyData),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // === PIE CHART ===
                const Text("Komposisi Kategori", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
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
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: _generatePieSections(categoryMap, totalAmount),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // LIST DETAIL KATEGORI
                      Column(
                        children: categoryMap.entries.map((entry) {
                          final catName = _categoryNames[entry.key] ?? 'Tanpa Kategori';
                          final percentage = (entry.value / totalAmount * 100).toStringAsFixed(1);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: _getColor(catName), // Warna Unik per Kategori
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(catName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("$percentage%", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                    const SizedBox(width: 8),
                                    Text(CurrencyFormat.toIDR(entry.value), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // === LOGIC WARNA BARU ===
  // Fungsi ini menghasilkan warna unik berdasarkan nama kategori
  Color _getColor(String categoryName) {
    // Palet warna yang cerah dan bervariasi
    final List<Color> colors = [
      const Color(0xFFFF6B6B), // Merah
      const Color(0xFF4D96FF), // Biru
      const Color(0xFF6BCB77), // Hijau
      const Color(0xFFFFD93D), // Kuning
      const Color(0xFF845EC2), // Ungu
      const Color(0xFF00C9A7), // Tosca
      const Color(0xFFF3C5FF), // Pink Soft
      const Color(0xFFFF9642), // Oranye
      const Color(0xFF2D4059), // Navy
      const Color(0xFF8D6E63), // Coklat
      const Color(0xFF00D2FC), // Cyan
      const Color(0xFFFFC75F), // Gold
    ];

    // Menggunakan hashCode agar nama yang sama selalu dapat warna yang sama
    // abs() untuk menghindari nilai negatif
    return colors[categoryName.hashCode.abs() % colors.length];
  }

  Widget _buildToggleBtn(String label, String type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(List<double> weeklyData) {
    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weeklyData[index],
            // Warna Bar Chart tetap Hijau/Merah agar jelas membedakan Income vs Expense
            color: _selectedType == 'expense' ? Colors.redAccent : Colors.green,
            width: 16,
            borderRadius: BorderRadius.circular(6),
            backDrawRodData: BackgroundBarChartRodData(show: true, toY: _calculateMaxY(weeklyData), color: Colors.grey[100]),
          ),
        ],
      );
    });
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    const days = ['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mg'];
    final index = value.toInt();
    if (index < 0 || index >= days.length) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(days[index], style: const TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }

  double _calculateMaxY(List<double> data) {
    double max = 0;
    for (var val in data) { if (val > max) max = val; }
    return max == 0 ? 1000 : max * 1.2;
  }

  List<PieChartSectionData> _generatePieSections(Map<String, double> data, double total) {
    int i = 0;
    return data.entries.map((entry) {
      final catName = _categoryNames[entry.key] ?? 'Lainnya';
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;
      final percentage = (entry.value / total * 100);

      final section = PieChartSectionData(
        color: _getColor(catName), // Warna dinamis dipanggil di sini
        value: percentage,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(fontSize: isTouched ? 14 : 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
      i++;
      return section;
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_selectedType == 'expense' ? Icons.money_off_rounded : Icons.attach_money_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Belum ada data $_selectedType", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}