import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // 1. Primary Palette (Biru Mewah & Profesional)
  static const Color primaryDark = Color(
    0xFF0D47A1,
  ); // Deep Navy Blue (Warna Utama)
  static const Color accentBlue = Color(0xFF1976D2); // Royal Blue (Warna Aksi)
  static const Color lightBlue = Color(0xFFE3F2FD); // Soft Water Blue

  // 2. Status Colors (Emerald, Amber, Rose)
  static const Color success = Color(0xFF2E7D32); // Deep Green
  static const Color warning = Color(0xFFFFA000); // Amber
  static const Color danger = Color(0xFFD32F2F); // Red

  // 3. Neutral Palette (Background Bersih)
  static const Color background = Color(
    0xFFF5F7FA,
  ); // Slate 50 (Abu-abu sangat muda)
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1A237E); // Indigo Dark (Teks Utama)
  static const Color textLight = Color(0xFF757575); // Gray (Teks Sekunder)

  // Gradasi Premium Biru (Efek Air yang Elegan)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppStyles {
  // Shadow Ultra Soft (Kunci Desain Premium)
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(
        0xFF0D47A1,
      ).withOpacity(0.06), // Bayangan sedikit kebiruan
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static BorderRadius radiusL = BorderRadius.circular(24);
  static BorderRadius radiusM = BorderRadius.circular(16);

  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle body = GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.textLight,
    height: 1.5,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
  );
}

class AppTime {
  /// Mendapatkan label zona waktu (WIB/WITA/WIT) berdasarkan offset perangkat
  static String getZoneLabel(DateTime dt) {
    int offset = dt.timeZoneOffset.inHours;
    switch (offset) {
      case 7:
        return "WIB";
      case 8:
        return "WITA";
      case 9:
        return "WIT";
      default:
        return "UTC+${offset}";
    }
  }

  /// Format Jam:Menit + Label Zona Waktu
  static String formatTimeWithZone(DateTime dt) {
    String hour = dt.hour.toString().padLeft(2, '0');
    String minute = dt.minute.toString().padLeft(2, '0');
    return "$hour:$minute ${getZoneLabel(dt)}";
  }
}
