// lib/screens/full_map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../viewmodels/map_viewmodel.dart';
import '../viewmodels/water_viewmodel.dart';
import '../services/history_service.dart';
import '../utils/constants.dart';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  // ALAT KONTROL PETA (PENTING)
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final mapVM = context.watch<MapViewModel>();
    final waterVM = context.read<WaterViewModel>();
    const LatLng defaultCenter = LatLng(-6.2000, 106.8166);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Peta Sebaran Air",
          style: AppStyles.h2.copyWith(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<HistoryItem>>(
        stream: waterVM.waterStream,
        builder: (context, snapshot) {
          final historyData = snapshot.data ?? [];

          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              mapVM.generateMarkers(historyData);
            });
          }

          return Stack(
            children: [
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
                    userAgentPackageName: 'id.sipabersih.pro',
                  ),
                  MarkerLayer(markers: mapVM.markers),
                ],
              ),
              _buildInfoPanel(mapVM.markers.length),

              // TAMBAHKAN LEGENDA PETA DI KIRI BAWAH
              _buildLegend(),

              _buildFloatingControl(historyData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: 30,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppStyles.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _legendItem(AppColors.success, "Aman Diminum"),
            const SizedBox(height: 6),
            _legendItem(AppColors.warning, "Butuh Filtrasi"),
            const SizedBox(height: 6),
            _legendItem(AppColors.danger, "Tidak Layak"),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFloatingControl(List<HistoryItem> data) {
    return Positioned(
      bottom: 30,
      right: 20,
      child: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryDark,
        icon: const Icon(Icons.gps_fixed, color: Colors.white, size: 20),
        label: const Text(
          "LOKASI BENCANA",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        onPressed: () {
          if (data.isNotEmpty) {
            // TERBANG KE LOKASI TERBARU (Data Petugas Terakhir)
            final latestPos = LatLng(
              data.first.measure.latitude,
              data.first.measure.longitude,
            );
            _mapController.move(
              latestPos,
              15.0,
            ); // Pindah ke titik lokasi dengan zoom 15
            _showSnackBar("Fokus ke titik pengukuran terbaru");
          } else {
            _showSnackBar("Belum ada data lokasi");
          }
        },
      ),
    );
  }

  // Panel Info Atas
  Widget _buildInfoPanel(int totalMarkers) {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(15),
          boxShadow: AppStyles.softShadow,
        ),
        child: Row(
          children: [
            const Icon(Icons.map_outlined, color: AppColors.accentBlue),
            const SizedBox(width: 15),
            Text(
              "$totalMarkers Titik Terdeteksi",
              style: AppStyles.h2.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
