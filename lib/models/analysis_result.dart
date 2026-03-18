import 'package:flutter/material.dart';

class AnalysisResult {
  final String status; // AMAN, PERLU FILTRASI, TIDAK LAYAK
  final int score; // 0 - 100
  final Color color; // Hijau, Kuning, Merah
  final List<String> recommendations;

  AnalysisResult({
    required this.status,
    required this.score,
    required this.color,
    required this.recommendations,
  });
}
