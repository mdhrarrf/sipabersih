import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/water_viewmodel.dart';
import '../services/history_service.dart';
import '../widgets/water_chart.dart';
import '../utils/constants.dart';
import '../models/water_measure.dart';
import '../widgets/app_footer.dart'; // IMPORT FOOTER

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Akses ViewModel
    final waterVM = context.read<WaterViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Header Dinamis Ramping
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "Tren Kualitas Air",
                style: AppStyles.h2.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),

          // 2. Konten Statistik Real-time
          SliverToBoxAdapter(
            child: StreamBuilder<List<HistoryItem>>(
              stream: waterVM.waterStream, // Ambil dari ViewModel (MVVM)
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

                // Jika data kurang dari 2, tampilkan Empty State + Footer
                if (history.length < 2) {
                  return Column(
                    children: [
                      const SizedBox(height: 80),
                      _buildEmptyState(),
                      const SizedBox(height: 80),
                      const AppFooter(),
                    ],
                  );
                }

                final measures = history.map((e) => e.measure).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            "Visualisasi Real-time TDS (ppm)",
                          ),
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
                          _buildInsightCard(),
                        ],
                      ),
                    ),

                    // 3. FOOTER IDENTITAS (SINKRON DENGAN HALAMAN LAIN)
                    const AppFooter(),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_graph_rounded,
              size: 80,
              color: AppColors.accentBlue.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text("Data Minim", style: AppStyles.h2),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              "Dibutuhkan minimal 2 data pengukuran untuk menampilkan tren statistik.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppStyles.h2.copyWith(color: AppColors.primaryDark, fontSize: 15),
    );
  }

  Widget _buildSummaryGrid(List<WaterMeasure> data) {
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
                color: color.withOpacity(0.1),
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
            Text(title, style: AppStyles.caption.copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
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
                "Analisis Cerdas",
                style: AppStyles.h2.copyWith(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Sistem memantau tren TDS secara real-time. Penurunan garis grafik menunjukkan keberhasilan proses filtrasi di lokasi bencana.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
