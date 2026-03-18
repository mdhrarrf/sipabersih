import 'package:flutter/material.dart';
import '../models/water_measure.dart';
import '../models/analysis_result.dart';
import '../utils/constants.dart';

class AnalysisService {
  /// Fungsi utama untuk menghitung Water Quality Index (WQI)
  static AnalysisResult calculateQuality(WaterMeasure data) {
    int score = 100;
    List<String> recommendations = [];

    // 1. Analisis pH (Standar Nasional: 6.5 - 8.5)
    if (data.ph < 6.5) {
      score -= 30;
      recommendations.add(
        "Air bersifat asam. Tambahkan zat penetral alkali atau kapur tohor.",
      );
    } else if (data.ph > 8.5) {
      score -= 30;
      recommendations.add(
        "Air bersifat basa. Gunakan sistem filtrasi karbon atau penetral asam.",
      );
    }

    // 2. Analisis TDS (Standar: < 300 ppm untuk air minum)
    if (data.tds > 300) {
      score -= 40;
      recommendations.add(
        "Zat terlarut tinggi. Lakukan filtrasi membran (Reverse Osmosis) segera.",
      );
    }

    // 3. Analisis Turbidity / Kekeruhan (Standar: < 5 NTU)
    if (data.turbidity > 5) {
      score -= 30;
      recommendations.add(
        "Kekeruhan tinggi. Lakukan pengendapan (sedimentasi) dan filtrasi pasir.",
      );
    }

    // Penentuan Status Berdasarkan Ambang Batas WQI
    String status;
    Color color;

    if (score >= 80) {
      status = "AMAN";
      color = AppColors.success;
      recommendations.add(
        "Kualitas air optimal. Layak digunakan untuk sanitasi dan konsumsi.",
      );
    } else if (score >= 50) {
      status = "PERLU FILTRASI";
      color = AppColors.warning;
      recommendations.add(
        "Kualitas air menurun. Wajib melalui proses filtrasi fisik sebelum digunakan.",
      );
    } else {
      status = "TIDAK LAYAK";
      color = AppColors.danger;
      recommendations.add(
        "Bahaya kontaminasi tinggi. Cari sumber air alternatif atau lakukan pemurnian total.",
      );
    }

    return AnalysisResult(
      status: status,
      score: score < 0 ? 0 : score,
      color: color,
      recommendations: recommendations,
    );
  }
}
