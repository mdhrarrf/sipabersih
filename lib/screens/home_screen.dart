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
    // Menghitung status bar agar lengkungan tidak tergeser notch HP
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double fixedContentHeight = 150.0; // TINGGI TETAP AREA BIRU

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. BACKGROUND TETAP (Lengkungan Terkunci di Sini)
          _buildHeroBackground(statusBarHeight + fixedContentHeight),

          // 2. KONTEN SCROLLABLE
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // AppBar Ramping & Simetris
                _buildSliverAppBar(),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildMainStatusCard(), // Kartu Status Utama
                        const SizedBox(height: 32),
                        Text(
                          "Layanan Utama",
                          style: AppStyles.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        _buildMenuGrid(),
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

  // LENGKUNGAN SIMETRIS & TERKUNCI
  Widget _buildHeroBackground(double totalHeight) {
    return Container(
      height: totalHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32), // Nilai lengkungan simetris kiri-kanan
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: true, // Judul selalu di tengah
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      title: Text(
        "SIPABERSIH",
        style: AppStyles.h1.copyWith(
          color: Colors.white,
          fontSize: 18,
          letterSpacing: 2,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatusCard() {
    // Kita gunakan StreamBuilder agar Real-time dan konsisten
    return StreamBuilder<List<HistoryItem>>(
      stream: HistoryService.getHistoryStream(),
      builder: (context, snapshot) {
        final history = snapshot.data ?? [];
        final lastData = history.isNotEmpty ? history.first : null;

        // Jika kosong gunakan Biru, jika ada gunakan warna status (Hijau/Kuning/Merah)
        final color = lastData?.result.color ?? AppColors.accentBlue;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppStyles.radiusL,
            boxShadow: AppStyles.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BARIS 1: Header & Skor
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.water_drop_rounded, color: color, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "STATUS TERAKHIR",
                        style: AppStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  // Skor selalu tampil (jika null tampilkan --)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lastData != null
                          ? "Skor: ${lastData.result.score}"
                          : "Skor: --",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // BARIS 2: Teks Status (Ukurannya dikunci agar tidak berubah)
              Text(
                lastData?.result.status ?? "BELUM ADA DATA",
                style: AppStyles.h1.copyWith(
                  fontSize: 22,
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 16),

              // BARIS 3: Quick Stats (SEKARANG SELALU TAMPIL AGAR UKURAN TETAP)
              Row(
                children: [
                  _miniPill(
                    lastData != null ? "pH ${lastData.measure.ph}" : "pH --",
                    color,
                  ),
                  const SizedBox(width: 8),
                  _miniPill(
                    lastData != null
                        ? "${lastData.measure.tds.toInt()} ppm"
                        : "-- ppm",
                    color,
                  ),
                  const SizedBox(width: 8),
                  _miniPill(
                    lastData != null
                        ? "${lastData.measure.turbidity.toInt()} NTU"
                        : "-- NTU",
                    color,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi pembantu Pill dengan warna dinamis
  Widget _miniPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        // Jika data kosong, gunakan warna background standar
        color: label.contains("--")
            ? AppColors.background
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppStyles.caption.copyWith(
          color: label.contains("--") ? AppColors.textLight : color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
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
          Icons.analytics_rounded,
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
        setState(() {});
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
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppStyles.h2.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
