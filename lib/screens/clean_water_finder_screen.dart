import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/water_viewmodel.dart';
import '../services/history_service.dart';
import '../utils/constants.dart';

class CleanWaterFinderScreen extends StatelessWidget {
  const CleanWaterFinderScreen({super.key});

  // FUNGSI INTI: Membuka Google Maps untuk Navigasi
  Future<void> _openNavigation(double lat, double lng) async {
    final Uri url = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    final Uri fallbackUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Gagal membuka peta: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final waterVM = context.read<WaterViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Pusat Air Bersih",
          style: AppStyles.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<HistoryItem>>(
        stream: waterVM.cleanWaterStream, // Hanya ambil yang AMAN
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cleanPoints = snapshot.data ?? [];

          if (cleanPoints.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: cleanPoints.length,
            itemBuilder: (context, index) {
              final item = cleanPoints[index];
              return _buildLocationCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.not_listed_location_rounded,
            size: 80,
            color: AppColors.accentBlue.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text("Tidak Ada Lokasi Aman", style: AppStyles.h2),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Belum ditemukan sumber air dengan status AMAN di sekitar area ini.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(HistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.radiusL,
        boxShadow: AppStyles.softShadow,
        border: Border.all(color: AppColors.success.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_drink_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Titik Air Layak Konsumsi",
                      style: AppStyles.h2.copyWith(fontSize: 14),
                    ),
                    Text(
                      "Kualitas Sangat Baik (Skor: ${item.result.score})",
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("KOORDINAT LOKASI", style: AppStyles.caption),
                  Text(
                    "${item.measure.latitude.toStringAsFixed(4)}, ${item.measure.longitude.toStringAsFixed(4)}",
                    style: AppStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              // TOMBOL GO - NAVIGASI
              ElevatedButton.icon(
                onPressed: () => _openNavigation(
                  item.measure.latitude,
                  item.measure.longitude,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.near_me_rounded, size: 18),
                label: const Text(
                  "NAVIGASI",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
