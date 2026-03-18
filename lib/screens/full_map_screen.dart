import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../viewmodels/map_viewmodel.dart';
import '../viewmodels/water_viewmodel.dart';
import '../utils/constants.dart';
import '../widgets/app_footer.dart';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    // 1. MENDENGARKAN VIEWMODEL (State-Based)
    final waterVM = context.watch<WaterViewModel>();
    final mapVM = context.watch<MapViewModel>();

    final historyData = waterVM.history;
    const LatLng defaultCenter = LatLng(-6.2000, 106.8166);

    // 2. TRIGGER GENERATE MARKER (Hanya jika data berubah)
    // Kita gunakan postFrameCallback agar tidak mengganggu proses build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (historyData.isNotEmpty) {
        mapVM.generateMarkers(historyData);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Peta Monitoring Nasional",
          style: AppStyles.h2.copyWith(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // AREA PETA
          Expanded(
            child: waterVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      // LAYER PETA DASAR
                      FlutterMap(
                        mapController: _mapController,
                        options: const MapOptions(
                          initialCenter: defaultCenter,
                          initialZoom: 12,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                            subdomains: const ['a', 'b', 'c', 'd'],
                            userAgentPackageName: 'id.sipabersih.pro.fullmap',
                          ),
                          // Marker diambil dari MapViewModel
                          MarkerLayer(markers: mapVM.markers),
                        ],
                      ),

                      // OVERLAY: PANEL INFO ATAS
                      _buildTopPanel(mapVM.markers.length),

                      // OVERLAY: LEGENDA KIRI BAWAH
                      _buildMapLegend(),

                      // OVERLAY: TOMBOL ZOOM TERPISAH (KANAN TENGAH)
                      _buildZoomControls(),

                      // OVERLAY: TOMBOL LOKASI BENCANA (KANAN BAWAH)
                      _buildMainAction(historyData),
                    ],
                  ),
          ),

          // FOOTER IDENTITAS
          const AppFooter(),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildTopPanel(int count) {
    return Positioned(
      top: 15,
      left: 15,
      right: 15,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: AppStyles.softShadow,
          border: Border.all(color: AppColors.primaryDark.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.sensors_rounded,
              color: AppColors.accentBlue,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              "Terdeteksi $count titik pemantauan aktif",
              style: AppStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapLegend() {
    return Positioned(
      bottom: 20,
      left: 15,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: AppStyles.radiusM,
          boxShadow: AppStyles.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "LEGENDA",
              style: AppStyles.caption.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 8,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            _legendRow(AppColors.success, "Air Bersih"),
            const SizedBox(height: 6),
            _legendRow(AppColors.warning, "Perlu Filter"),
            const SizedBox(height: 6),
            _legendRow(AppColors.danger, "Tidak Layak"),
          ],
        ),
      ),
    );
  }

  Widget _legendRow(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppStyles.body.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      right: 15,
      // Dikunci di posisi kanan tengah agar tidak nabrak tombol di bawah
      top: MediaQuery.of(context).size.height * 0.25,
      child: Column(
        children: [
          FloatingActionButton.small(
            heroTag: "zoom_in",
            backgroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.add, color: AppColors.primaryDark),
            onPressed: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: "zoom_out",
            backgroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.remove, color: AppColors.primaryDark),
            onPressed: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAction(List<dynamic> data) {
    return Positioned(
      bottom: 20,
      right: 15,
      child: FloatingActionButton.extended(
        heroTag: "focus_disaster",
        backgroundColor: AppColors.primaryDark,
        elevation: 6,
        icon: const Icon(
          Icons.gps_fixed_rounded,
          color: Colors.white,
          size: 18,
        ),
        label: const Text(
          "LOKASI BENCANA",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        onPressed: () {
          if (data.isNotEmpty) {
            final latest = LatLng(
              data.first.measure.latitude,
              data.first.measure.longitude,
            );
            _mapController.move(latest, 15.0);
            _showSnackBar("Fokus ke koordinat terbaru");
          }
        },
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 12)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.fromLTRB(60, 0, 60, 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
