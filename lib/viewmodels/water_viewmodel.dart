import 'package:flutter/material.dart';
import '../models/water_measure.dart';
import '../models/analysis_result.dart';
import '../services/history_service.dart';

class WaterViewModel extends ChangeNotifier {
  // 1. Simpan aliran data dalam variabel private
  late final Stream<List<HistoryItem>> _broadcastStream;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 2. Inisialisasi hanya SATU KALI saat aplikasi dijalankan
  WaterViewModel() {
    _broadcastStream = HistoryService.getHistoryStream().asBroadcastStream();
  }

  // 3. PERBAIKAN FATAL: Getter harus mengembalikan variabel yang sudah ada,
  // JANGAN memanggil HistoryService lagi di sini!
  Stream<List<HistoryItem>> get waterStream => _broadcastStream;

  // 4. Stream Filter (Juga memakai pipa yang sama)
  Stream<List<HistoryItem>> get cleanWaterStream => _broadcastStream.map(
    (list) => list.where((item) => item.result.status == "AMAN").toList(),
  );

  // Fungsi Save & Delete tetap sama...
  Future<bool> saveMeasure(WaterMeasure measure, AnalysisResult result) async {
    _setLoading(true);
    try {
      await HistoryService.addHistory(measure, result);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Gagal simpan data.";
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
