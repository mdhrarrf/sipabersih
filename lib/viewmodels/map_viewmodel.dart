import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/history_service.dart';
import '../utils/constants.dart';

class MapViewModel extends ChangeNotifier {
  List<Marker> _markers = [];
  List<Marker> get markers => _markers;

  void generateMarkers(List<HistoryItem> history) {
    _markers = history.map((item) {
      final measure = item.measure;
      final result = item.result;

      // Logika Label & Warna yang Manusiawi
      String statusLabel;
      IconData statusIcon;
      Color statusColor;

      if (result.status == "AMAN") {
        statusLabel = "AIR BERSIH";
        statusIcon = Icons.check_circle_rounded;
        statusColor = AppColors.success;
      } else if (result.status == "PERLU FILTRASI") {
        statusLabel = "PERLU FILTER";
        statusIcon = Icons.filter_alt_rounded;
        statusColor = AppColors.warning;
      } else {
        statusLabel = "AIR KOTOR";
        statusIcon = Icons.warning_rounded;
        statusColor = AppColors.danger;
      }

      return Marker(
        point: LatLng(measure.latitude, measure.longitude),
        width: 100, // Dilebarin agar muat tulisan
        height: 60,
        child: GestureDetector(
          onTap: () => print("Detail: ${result.status}"),
          child: Column(
            children: [
              // BUBBLE INFO (Penjelasan Teks)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // EKOR PIN (Segitiga kecil bawah)
              Icon(Icons.arrow_drop_down_rounded, color: statusColor, size: 20),
            ],
          ),
        ),
      );
    }).toList();

    notifyListeners();
  }
}
