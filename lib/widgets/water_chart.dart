import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/water_measure.dart';
import '../utils/constants.dart';

class WaterChart extends StatelessWidget {
  final List<WaterMeasure> data;

  const WaterChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Kita balik data agar urutan waktu benar (dari lama ke baru di grafik)
    final reversedData = data.reversed.toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              // Mengambil nilai TDS sebagai sumbu Y
              spots: reversedData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.tds);
              }).toList(),
              isCurved: true,
              // PERBAIKAN: Menggunakan accentBlue sesuai constants.dart yang baru
              color: AppColors.accentBlue,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                // PERBAIKAN: Menggunakan accentBlue
                color: AppColors.accentBlue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
