// lib/services/analysis_service.dart
import 'package:flutter/material.dart';
import '../models/water_measure.dart';
import '../models/analysis_result.dart';

class AnalysisService {
  static AnalysisResult calculateQuality(WaterMeasure data) {
    int score = 100;
    List<String> recommendations = [];

    // 1. Cek pH (Normal 6.5 - 8.5)
    if (data.ph < 6.5 || data.ph > 8.5) {
      score -= 30;
      recommendations.add("Gunakan kapur/tawas untuk menyeimbangkan pH");
    }

    // 2. Cek TDS (Normal < 300 ppm)
    if (data.tds > 300) {
      score -= 40;
      recommendations.add("Gunakan filter Reverse Osmosis (RO) atau distilasi");
    }

    // 3. Cek Turbidity (Normal < 5 NTU)
    if (data.turbidity > 5) {
      score -= 30;
      recommendations.add("Lakukan filtrasi dengan pasir/karbon aktif");
    }

    // Tentukan Status Akhir
    String status;
    Color color;

    if (score >= 80) {
      status = "AMAN";
      color = Colors.green;
      recommendations.add("Air layak digunakan langsung.");
    } else if (score >= 50) {
      status = "PERLU FILTRASI";
      color = Colors.orange;
      recommendations.add("Rebus air hingga mendidih sebelum diminum.");
    } else {
      status = "TIDAK LAYAK";
      color = Colors.red;
    }

    return AnalysisResult(
      status: status,
      score: score < 0 ? 0 : score,
      color: color,
      recommendations: recommendations,
    );
  }
}
