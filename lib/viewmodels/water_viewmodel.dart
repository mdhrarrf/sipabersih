import 'package:flutter/material.dart';
import '../models/water_measure.dart';
import '../models/analysis_result.dart';
import '../services/history_service.dart';

class WaterViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. Ambil Stream Data (Real-time untuk UI)
  Stream<List<HistoryItem>> get waterStream =>
      HistoryService.getHistoryStream();

  // 2. Logika Menambah Data ke Cloud
  Future<bool> saveMeasure(WaterMeasure measure, AnalysisResult result) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await HistoryService.addHistory(measure, result);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Gagal menyimpan data ke pusat.";
      _setLoading(false);
      return false;
    }
  }

  // 3. Logika Hapus Data
  Future<void> deleteData(int id) async {
    try {
      await HistoryService.deleteHistory(id);
    } catch (e) {
      _errorMessage = "Gagal menghapus data.";
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Stream<List<HistoryItem>> get cleanWaterStream =>
      HistoryService.getHistoryStream().map(
        (list) => list.where((item) => item.result.status == "AMAN").toList(),
      );
}
