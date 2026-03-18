import 'package:flutter/material.dart';
import '../models/water_measure.dart';
import '../models/analysis_result.dart';
import '../utils/constants.dart';

class ResultScreen extends StatelessWidget {
  final WaterMeasure measure;
  final AnalysisResult result;

  const ResultScreen({super.key, required this.measure, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Hasil Analisis",
          style: AppStyles.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Kartu Skor Utama (Mewah & Informatif)
            _buildScoreCard(),

            const SizedBox(height: 32),

            // 2. Grid Detail Parameter
            Text("Detail Parameter", style: AppStyles.h2),
            const SizedBox(height: 16),
            _buildDetailGrid(),

            const SizedBox(height: 32),

            // 3. Rekomendasi Tindakan
            Text("Rekomendasi Tindakan", style: AppStyles.h2),
            const SizedBox(height: 16),
            _buildRecommendationList(),

            const SizedBox(height: 40),

            // 4. Tombol Kembali (Aksi Utama)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppStyles.radiusM,
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primaryDark.withOpacity(0.3),
                ),
                child: Text(
                  "KEMBALI KE BERANDA",
                  style: AppStyles.h2.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.radiusL,
        boxShadow: AppStyles.softShadow,
      ),
      child: Column(
        children: [
          // Badge Status (Warna Dinamis)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: result.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: result.color.withOpacity(0.2)),
            ),
            child: Text(
              result.status,
              style: AppStyles.h2.copyWith(
                color: result.color,
                fontSize: 13,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 35),

          // Lingkaran Skor Progress Modern
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: CircularProgressIndicator(
                  value: result.score / 100,
                  strokeWidth: 14,
                  backgroundColor: AppColors.lightBlue,
                  color: result.color,
                  strokeCap: StrokeCap.round, // Efek bulat pada ujung progress
                ),
              ),
              Column(
                children: [
                  Text(
                    "${result.score}",
                    style: AppStyles.h1.copyWith(
                      fontSize: 58,
                      color: AppColors.textDark,
                      letterSpacing: -2,
                    ),
                  ),
                  Text(
                    "SKOR KUALITAS",
                    style: AppStyles.caption.copyWith(
                      letterSpacing: 2,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 35),
          Text(
            "Berdasarkan standar perhitungan Water Quality Index (WQI) nasional.",
            textAlign: TextAlign.center,
            style: AppStyles.body.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildInfoTile(
          "pH Air",
          measure.ph.toStringAsFixed(1),
          "pH",
          Icons.science_rounded,
        ),
        _buildInfoTile(
          "TDS",
          "${measure.tds.toInt()}",
          "ppm",
          Icons.opacity_rounded,
        ),
        _buildInfoTile(
          "Turbidity",
          measure.turbidity.toStringAsFixed(1),
          "NTU",
          Icons.waves_rounded,
        ),
        _buildInfoTile(
          "Suhu Air",
          "${measure.temperature.toInt()}",
          "°C",
          Icons.thermostat_rounded,
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppStyles.radiusM,
        boxShadow: AppStyles.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppStyles.caption.copyWith(fontSize: 10)),
                FittedBox(
                  child: Text(
                    "$value $unit",
                    style: AppStyles.h2.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationList() {
    return Column(
      children: result.recommendations
          .map(
            (rec) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppStyles.radiusM,
                border: Border.all(
                  color: result.color.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: result.color,
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      rec,
                      style: AppStyles.body.copyWith(
                        color: AppColors.textDark,
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
