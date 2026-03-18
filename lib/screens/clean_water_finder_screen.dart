import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/water_viewmodel.dart';
import '../utils/constants.dart';
import '../widgets/app_footer.dart';

class CleanWaterFinderScreen extends StatelessWidget {
  const CleanWaterFinderScreen({super.key});

  // Fungsi Navigasi
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
    // 1. MENDENGARKAN DATA DARI VIEWMODEL (STATE-BASED)
    // watch akan mendeteksi perubahan data di ViewModel secara otomatis
    final waterVM = context.watch<WaterViewModel>();
    final cleanPoints = waterVM.cleanWaterList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Pusat Air Bersih",
          style: AppStyles.h2.copyWith(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // 2. LOGIKA TAMPILAN TANPA STREAMBUILDER (ANT-STUCK)
      body: waterVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cleanPoints.isEmpty
          ? _buildEmptyStateWithFooter()
          : _buildListView(cleanPoints),
    );
  }

  // Tampilan jika data kosong (Termasuk Footer)
  Widget _buildEmptyStateWithFooter() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 100),
          _buildEmptyIllustration(),
          const SizedBox(height: 100),
          const AppFooter(),
        ],
      ),
    );
  }

  // Tampilan Daftar Lokasi (Termasuk Footer di akhir list)
  Widget _buildListView(List<dynamic> cleanPoints) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      itemCount: cleanPoints.length + 1,
      itemBuilder: (context, index) {
        if (index == cleanPoints.length) {
          return const AppFooter();
        }
        return _buildLocationCard(cleanPoints[index]);
      },
    );
  }

  Widget _buildEmptyIllustration() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.not_listed_location_rounded,
              size: 80,
              color: AppColors.accentBlue.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text("Tidak Ada Lokasi Aman", style: AppStyles.h2),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              "Belum ditemukan sumber air dengan status AMAN di sekitar area ini.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.radiusL,
        boxShadow: AppStyles.softShadow,
        border: Border.all(color: AppColors.success.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      "Titik Air Terverifikasi",
                      style: AppStyles.h2.copyWith(fontSize: 15),
                    ),
                    Text(
                      "Kualitas Layak Konsumsi (WQI: ${item.result.score})",
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "KOORDINAT GPS",
                      style: AppStyles.caption.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item.measure.latitude.toStringAsFixed(4)}, ${item.measure.longitude.toStringAsFixed(4)}",
                      style: AppStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _openNavigation(
                    item.measure.latitude,
                    item.measure.longitude,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.near_me_rounded, size: 16),
                  label: const Text(
                    "NAVIGASI",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
