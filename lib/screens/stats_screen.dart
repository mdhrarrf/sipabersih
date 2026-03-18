import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../widgets/water_chart.dart';
import '../utils/constants.dart';
import '../models/water_measure.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Header Dinamis (Konsisten dengan Home)
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Tren Kualitas Air",
                style: AppStyles.h2.copyWith(color: Colors.white, fontSize: 18),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),

          // 2. Konten Statistik
          SliverToBoxAdapter(
            child: FutureBuilder<List<HistoryItem>>(
              future: HistoryService.getHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentBlue,
                      ),
                    ),
                  );
                }

                final history = snapshot.data ?? [];
                if (history.length < 2) return _buildEmptyState();

                final measures = history.map((e) => e.measure).toList();

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Grafik TDS (ppm)"),
                      const SizedBox(height: 16),

                      // Kartu Grafik Premium
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppStyles.radiusL,
                          boxShadow: AppStyles.softShadow,
                        ),
                        child: WaterChart(data: measures),
                      ),

                      const SizedBox(height: 32),
                      _buildSectionHeader("Ringkasan Analitik"),
                      const SizedBox(height: 16),
                      _buildSummaryGrid(measures),

                      const SizedBox(height: 32),
                      _buildInsightCard(), // Kartu Edukasi Data
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.only(top: 100),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_graph_rounded,
              size: 80,
              color: AppColors.accentBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text("Data Tidak Cukup", style: AppStyles.h2),
          const SizedBox(height: 8),
          Text(
            "Input minimal 2 data sensor untuk melihat grafik tren perkembangan kualitas air.",
            style: AppStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppStyles.h2.copyWith(color: AppColors.primaryDark, fontSize: 16),
    );
  }

  Widget _buildSummaryGrid(List<WaterMeasure> data) {
    // Logika Analitik Rata-rata
    double sumTds = 0;
    double sumPh = 0;
    for (var m in data) {
      sumTds += m.tds;
      sumPh += m.ph;
    }
    double avgTds = sumTds / data.length;
    double avgPh = sumPh / data.length;

    return Row(
      children: [
        _buildStatCard(
          "Rerata TDS",
          "${avgTds.toInt()}",
          "ppm",
          Icons.analytics_rounded,
          AppColors.accentBlue,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          "Rerata pH",
          avgPh.toStringAsFixed(1),
          "pH",
          Icons.science_rounded,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppStyles.radiusM,
          boxShadow: AppStyles.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppStyles.h1.copyWith(
                    fontSize: 22,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: AppStyles.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppStyles.caption.copyWith(
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient, // Gunakan gradasi biru mewah
        borderRadius: AppStyles.radiusL,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                "Interpretasi Data",
                style: AppStyles.h2.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Grafik menunjukkan kestabilan zat terlarut dalam air. Jika Anda mendeteksi lonjakan tajam pada grafik TDS, segera lakukan pembersihan pada filter karbon aktif dan sensor.",
            style: AppStyles.body.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
