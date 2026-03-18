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
      appBar: AppBar(
        title: const Text("Hasil Analisis"),
        // Menghilangkan tombol back otomatis jika ingin paksa user pakai tombol di bawah
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreHeader(),
            const SizedBox(height: 25),
            const Text(
              "Detail Parameter:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildDetailGrid(),
            const SizedBox(height: 25),
            const Text(
              "Rekomendasi Tindakan:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildRecommendationList(),
            const SizedBox(height: 30),

            // Tombol Kembali
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "KEMBALI KE BERANDA",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: result.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: result.color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            result.status,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: result.color,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: CircularProgressIndicator(
                  value: result.score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade200,
                  color: result.color,
                ),
              ),
              Text(
                "${result.score}",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Skor Kualitas Air",
            style: TextStyle(color: AppColors.textLight),
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
      childAspectRatio: 2.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildInfoTile("pH", measure.ph.toStringAsFixed(1), "pH"),
        _buildInfoTile("TDS", "${measure.tds.toInt()}", "ppm"),
        _buildInfoTile(
          "Turbidity",
          measure.turbidity.toStringAsFixed(1),
          "NTU",
        ),
        _buildInfoTile("Suhu", "${measure.temperature.toInt()}", "°C"),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
          Text(
            "$value $unit",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationList() {
    return Column(
      children: result.recommendations
          .map(
            (rec) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: Icon(Icons.check_circle_outline, color: result.color),
                title: Text(rec, style: const TextStyle(fontSize: 14)),
              ),
            ),
          )
          .toList(),
    );
  }
}
