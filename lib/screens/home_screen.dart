import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;
import 'package:provider/provider.dart'; // Import Provider
import '../viewmodels/water_viewmodel.dart'; // Import ViewModel
import 'clean_water_finder_screen.dart';
import 'full_map_screen.dart';
import '../utils/constants.dart';
import '../services/history_service.dart';
import '../widgets/app_footer.dart'; // Import Footer
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
    // Akses ViewModel (Source of Truth)
    final waterVM = context.watch<WaterViewModel>();
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerHeight = 110.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 1. HEADER TETAP (FIXED) - Tidak Bergeser
          _buildFixedHeader(statusBarHeight + headerHeight),

          // 2. AREA SCROLLABLE
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MENGGUNAKAN DATA DARI VIEWMODEL (Anti-Spam Error)
                  StreamBuilder<List<HistoryItem>>(
                    stream: waterVM.waterStream,
                    builder: (context, snapshot) {
                      final history = snapshot.data ?? [];
                      final lastData = history.isNotEmpty
                          ? history.first
                          : null;
                      final color =
                          lastData?.result.color ?? AppColors.accentBlue;

                      return Column(
                        children: [
                          _buildMainStatusCard(lastData, color),
                          const SizedBox(height: 16),
                          _buildMapPreview(history),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                  Text(
                    "Layanan Utama",
                    style: AppStyles.h2.copyWith(
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuGrid(),

                  const SizedBox(height: 20),
                  // 3. FOOTER IDENTITAS
                  const AppFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HEADER LOGO & JUDUL (Symmetrical)
  Widget _buildFixedHeader(double totalHeight) {
    return Container(
      width: double.infinity,
      height: totalHeight,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                Text(
                  "SIPABERSIH",
                  style: AppStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              "Industrial Monitoring Dashboard",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // KARTU STATUS (Compact & Consistent)
  Widget _buildMainStatusCard(HistoryItem? lastData, Color color) {
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
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
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
          Text(
            lastData?.result.status ?? "BELUM ADA DATA",
            style: AppStyles.h1.copyWith(
              fontSize: 22,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
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
  }

  // MAP PREVIEW (Consistent & Safe)
  Widget _buildMapPreview(List<HistoryItem> history) {
    ll.LatLng center = history.isNotEmpty
        ? ll.LatLng(
            history.first.measure.latitude,
            history.first.measure.longitude,
          )
        : const ll.LatLng(-6.2000, 106.8166);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FullMapScreen()),
      ),
      borderRadius: AppStyles.radiusL,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppStyles.radiusL,
          boxShadow: AppStyles.softShadow,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ClipRRect(
          borderRadius: AppStyles.radiusL,
          child: Stack(
            children: [
              IgnorePointer(
                child: fm.FlutterMap(
                  options: fm.MapOptions(
                    initialCenter: center,
                    initialZoom: 10,
                    interactionOptions: const fm.InteractionOptions(
                      flags: fm.InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    fm.TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'id.sipabersih.pro',
                    ),
                    fm.MarkerLayer(
                      markers: history.map((item) {
                        return fm.Marker(
                          point: ll.LatLng(
                            item.measure.latitude,
                            item.measure.longitude,
                          ),
                          width: 30,
                          height: 30,
                          child: Icon(
                            Icons.location_on,
                            color: item.result.status == "AMAN"
                                ? Colors.green
                                : Colors.red,
                            size: 20,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              _buildMapOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET PENDUKUNG (GRID & PILLS) ---

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _menuCard(
          "Input Data",
          Icons.add_chart_rounded,
          AppColors.accentBlue,
          const InputDataScreen(),
        ),
        _menuCard(
          "Lokasi Air",
          Icons.local_drink_rounded,
          AppColors.success,
          const CleanWaterFinderScreen(),
        ),
        _menuCard(
          "Riwayat",
          Icons.history_edu_rounded,
          Colors.orange,
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
        _menuCard(
          "Panduan",
          Icons.menu_book_rounded,
          Colors.teal,
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

  Widget _miniPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
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

  Widget _buildMapOverlay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.4), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.map_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 8),
              Text(
                "SEBARAN TITIK AIR",
                style: AppStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Icon(Icons.fullscreen_rounded, color: Colors.white70, size: 18),
        ],
      ),
    );
  }
}
