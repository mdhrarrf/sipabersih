import '../models/water_measure.dart';
import '../models/analysis_result.dart';

class HistoryItem {
  final WaterMeasure measure;
  final AnalysisResult result;

  HistoryItem({required this.measure, required this.result});
}

class HistoryService {
  // List statis untuk menyimpan riwayat selama aplikasi berjalan
  static final List<HistoryItem> _history = [];

  // Fungsi untuk menambah data ke urutan paling atas (index 0)
  static void addHistory(WaterMeasure measure, AnalysisResult result) {
    _history.insert(0, HistoryItem(measure: measure, result: result));
  }

  // Fungsi untuk mengambil semua list riwayat
  static List<HistoryItem> getHistory() {
    return _history;
  }

  // Fungsi untuk mengambil data terbaru saja untuk dashboard
  static HistoryItem? getLastData() {
    return _history.isNotEmpty ? _history.first : null;
  }
}
