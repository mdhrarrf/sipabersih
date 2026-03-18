import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/history_service.dart';
import 'input_data_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';
import 'help_center_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Hero Header (Warna Biru Deep Navy)
          _buildHeroBackground(),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 2. AppBar Custom Transparan
                _buildSliverAppBar(),

                // 3. Konten Utama
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildMainStatusCard(), // Kartu Status Premium
                        const SizedBox(height: 35),
                        Text("Layanan Utama", style: AppStyles.h2),
                        const SizedBox(height: 16),
                        _buildMenuGrid(), // Grid Menu dengan Soft Shadow
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBackground() {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: AppColors.primaryDark, // Sekarang Biru Tua, bukan Hitam
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50)),
        gradient: AppColors.primaryGradient, // Memberikan efek kedalaman air
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: Text(
          "SIPABERSIH",
          style: AppStyles.h1.copyWith(
            color: Colors.white,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.15),
            child: const Icon(Icons.water_drop_outlined, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatusCard() {
    return FutureBuilder<HistoryItem?>(
      future: HistoryService.getLastData(),
      builder: (context, snapshot) {
        final lastData = snapshot.data;
        // Gunakan accentBlue jika belum ada data
        final color = lastData?.result.color ?? AppColors.accentBlue;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppStyles.radiusL,
            boxShadow: AppStyles.softShadow,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Kualitas Air Terakhir",
                    style: AppStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Text(
                lastData?.result.status ?? "TIDAK ADA DATA",
                style: AppStyles.h1.copyWith(
                  fontSize: 32,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              if (lastData != null) _buildQuickStats(lastData),
              if (lastData == null)
                Text(
                  "Input data pertama untuk melihat hasil",
                  style: AppStyles.caption,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(HistoryItem data) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _miniPill("pH ${data.measure.ph}"),
        _miniPill("${data.measure.tds.toInt()} ppm"),
        _miniPill("${data.measure.turbidity.toInt()} NTU"),
      ],
    );
  }

  Widget _miniPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppStyles.caption.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _menuCard(
          "Input Data",
          Icons.add_chart_rounded,
          AppColors.accentBlue,
          const InputDataScreen(),
        ),
        _menuCard(
          "Riwayat",
          Icons.history_edu_rounded,
          AppColors.success,
          const HistoryScreen(),
        ),
        _menuCard(
          "Statistik Air",
          Icons.auto_graph_rounded,
          Colors.indigo,
          const StatsScreen(),
        ),
        _menuCard(
          "Pusat Bantuan",
          Icons.support_agent_rounded,
          AppColors.danger,
          const HelpCenterScreen(),
        ),
      ],
    );
  }

  Widget _menuCard(
    String title,
    IconData icon,
    Color color,
    Widget destination,
  ) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
        setState(() {}); // Segarkan UI saat kembali
      },
      borderRadius: AppStyles.radiusM,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppStyles.radiusM,
          boxShadow: AppStyles.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppStyles.h2.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
