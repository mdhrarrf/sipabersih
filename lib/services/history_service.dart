import '../models/water_measure.dart';
import '../models/analysis_result.dart';
import 'analysis_service.dart';
import 'database_helper.dart';

class HistoryItem {
  final WaterMeasure measure;
  final AnalysisResult result;

  HistoryItem({required this.measure, required this.result});
}

class HistoryService {
  // Fungsi Simpan (Async)
  // Tetap menerima (measure, result) agar InputDataScreen Anda tidak error,
  // tapi yang kita simpan ke DB hanya 'measure' agar hemat memori.
  static Future<void> addHistory(
    WaterMeasure measure,
    AnalysisResult result,
  ) async {
    await DatabaseHelper.instance.create(measure);
  }

  // Fungsi Ambil Data (Sekarang jadi Future/Async)
  static Future<List<HistoryItem>> getHistory() async {
    // 1. Ambil data mentah dari Database
    final List<WaterMeasure> rawData = await DatabaseHelper.instance
        .readAllMeasures();

    // 2. Ubah data mentah menjadi HistoryItem (dihitung ulang statusnya otomatis)
    return rawData.map((measure) {
      final analysisResult = AnalysisService.calculateQuality(measure);
      return HistoryItem(measure: measure, result: analysisResult);
    }).toList();
  }

  // Fungsi Ambil Data Terakhir untuk Dashboard
  static Future<HistoryItem?> getLastData() async {
    final history = await getHistory();
    return history.isNotEmpty ? history.first : null;
  }

  static Future<void> deleteHistory(int id) async {
    await DatabaseHelper.instance.delete(id);
  }
}
