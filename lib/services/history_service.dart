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

  // 1. SIMPAN DATA KE CLOUD SUPABASE
  static Future<void> addHistory(
    WaterMeasure measure,
    AnalysisResult result,
  ) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('water_measures').insert({
      'petugas_id': user.id, // Ambil dari auth.currentUser!.id
      'ph': measure.ph,
      'tds': measure.tds,
      'turbidity': measure.turbidity,
      'temperature': measure.temperature,
      'status': result.status,
      'score': result.score,
      // created_at tidak perlu diisi karena sudah default now() di DB
    });
  }

  // 2. AMBIL SEMUA DATA DARI CLOUD (Urutkan dari yang terbaru)
  static Future<List<HistoryItem>> getHistory() async {
    final response = await _supabase
        .from('water_measures')
        .select()
        .order('created_at', ascending: true);

    final List data = response as List;

    return data.map((item) {
      // Mapping dari JSON Supabase kembali ke Model
      final measure = WaterMeasure(
        id: item['id'],
        ph: item['ph'].toDouble(),
        tds: item['tds'].toDouble(),
        turbidity: item['turbidity'].toDouble(),
        temperature: item['temperature'].toDouble(),
        timestamp: DateTime.parse(item['created_at']),
      );

      // Re-generate result untuk UI (warna & rekomendasi)
      final analysisResult = AnalysisService.calculateQuality(measure);

      return HistoryItem(measure: measure, result: analysisResult);
    }).toList();
  }

  // 3. AMBIL DATA TERAKHIR UNTUK DASHBOARD
  static Future<HistoryItem?> getLastData() async {
    final history = await getHistory();
    return history.isNotEmpty ? history.first : null;
  }

  // 4. HAPUS DATA DI CLOUD
  static Future<void> deleteHistory(int id) async {
    await _supabase.from('water_measures').delete().eq('id', id);
  }

  static Stream<List<HistoryItem>> getHistoryStream() {
    return _supabase
        .from('water_measures')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) {
          return data
              .map((item) {
                final measure = WaterMeasure(
                  id: item['id'],
                  ph: item['ph'].toDouble(),
                  tds: item['tds'].toDouble(),
                  turbidity: item['turbidity'].toDouble(),
                  temperature: item['temperature'].toDouble(),
                  timestamp: DateTime.parse(item['created_at']),
                );
                final analysisResult = AnalysisService.calculateQuality(
                  measure,
                );
                return HistoryItem(measure: measure, result: analysisResult);
              })
              .toList()
              .reversed
              .toList(); // Urutkan yang terbaru di atas
        });
  }
}
