import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/water_measure.dart';
import '../models/analysis_result.dart';
import 'analysis_service.dart';

class HistoryItem {
  final WaterMeasure measure;
  final AnalysisResult result;
  HistoryItem({required this.measure, required this.result});
}

class HistoryService {
  static final _supabase = Supabase.instance.client;

  // 1. FUNGSI SIMPAN (Tetap Sama)
  static Future<void> addHistory(
    WaterMeasure measure,
    AnalysisResult result,
  ) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('water_measures').insert({
      'petugas_id': user.id,
      'ph': measure.ph,
      'tds': measure.tds,
      'turbidity': measure.turbidity,
      'temperature': measure.temperature,
      'latitude': measure.latitude,
      'longitude': measure.longitude,
      'status': result.status,
      'score': result.score,
    });
  }

  // 2. AMBIL DATA (Fungsi Pengurutan Manual Paling Akurat)
  static Future<List<HistoryItem>> getHistory() async {
    final response = await _supabase.from('water_measures').select();
    final List data = response as List;

    final List<HistoryItem> items = data.map((item) {
      final measure = WaterMeasure.fromMap(item);
      final analysisResult = AnalysisService.calculateQuality(measure);
      return HistoryItem(measure: measure, result: analysisResult);
    }).toList();

    // --- KUNCI: URUTKAN MANUAL DI SINI ---
    // Membandingkan waktu: Jika waktu b lebih baru dari a, maka b di atas.
    items.sort((a, b) => b.measure.timestamp.compareTo(a.measure.timestamp));

    return items;
  }

  static Future<HistoryItem?> getLastData() async {
    final history = await getHistory();
    return history.isNotEmpty ? history.first : null;
  }

  static Future<void> deleteHistory(int id) async {
    await _supabase.from('water_measures').delete().eq('id', id);
  }

  // 3. STREAM DATA (Pengurutan Manual Real-time)
  static Stream<List<HistoryItem>> getHistoryStream() {
    return _supabase.from('water_measures').stream(primaryKey: ['id']).map((
      data,
    ) {
      final List<HistoryItem> items = data.map((item) {
        final measure = WaterMeasure.fromMap(item);
        final analysisResult = AnalysisService.calculateQuality(measure);
        return HistoryItem(measure: measure, result: analysisResult);
      }).toList();

      // --- KUNCI: URUTKAN MANUAL DI DALAM STREAM ---
      // Memastikan data terbaru yang baru masuk cloud langsung loncat ke urutan teratas
      items.sort((a, b) => b.measure.timestamp.compareTo(a.measure.timestamp));

      return items;
    });
  }
}
