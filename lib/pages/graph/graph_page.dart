// lib/pages/graph/graph_page.dart

import 'package:flutter/material.dart';
import '../../main.dart';
import 'package:fl_chart/fl_chart.dart'; // Catatan: Anda perlu menambahkan paket fl_chart di pubspec.yaml

class GraphPage extends StatelessWidget {
  const GraphPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Header dengan bubble circle
    Widget header = Stack(
      children: [
        Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: kLightColor.withOpacity(0.5))),
        Positioned(top: -50, left: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.2), shape: BoxShape.circle))),
        Positioned(top: 30, left: 50, child: Container(width: 80, height: 80, decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.4), shape: BoxShape.circle))),
        
        const Padding(
          padding: EdgeInsets.only(top: 40, left: 16, right: 16),
          child: Text('Grafik', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextColor)),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            header,
            const SizedBox(height: 20),
            
            // Grafik Pendapatan
            _buildGraphCard(
              title: 'Pendapatan',
              color: kPrimaryColor,
              data: [100, 150, 120, 200, 500, 150, 180], // Data dummy
            ),
            const SizedBox(height: 20),
            
            // Grafik Pengeluaran
            _buildGraphCard(
              title: 'Pengeluaran',
              color: kDangerColor,
              data: [80, 100, 90, 150, 200, 100, 110], // Data dummy
            ),
            
            const SizedBox(height: 80), // Padding untuk Bottom Nav
          ],
        ),
      ),
    );
  }
  
  // Helper Widget untuk Kartu Grafik
  Widget _buildGraphCard({required String title, required Color color, required List<double> data}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor)),
              const SizedBox(height: 20),
              
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            // Label Tanggal Dummy: 1 Nov, 2 Nov, ...
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('${value.toInt() + 1} Nov', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            );
                          },
                          interval: 1,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                        isCurved: true,
                        color: color.withOpacity(0.7),
                        barWidth: 2,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            // Menyorot titik tertinggi (dummy)
                            if (index == data.indexOf(data.reduce((a, b) => a > b ? a : b))) {
                              return FlDotCirclePainter(radius: 6, color: color, strokeWidth: 3, strokeColor: Colors.white);
                            }
                            return FlDotCirclePainter(radius: 0);
                          },
                        ),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}