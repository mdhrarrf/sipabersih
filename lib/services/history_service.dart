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

  // 1. SIMPAN DATA KE CLOUD SUPABASE (Sudah benar)
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
      'latitude': measure.latitude, // KIRIM KE CLOUD
      'longitude': measure.longitude, // KIRIM KE CLOUD
      'status': result.status,
      'score': result.score,
    });
  }

  // 2. AMBIL SEMUA DATA (Sinkronisasi Koordinat)
  static Future<List<HistoryItem>> getHistory() async {
    final response = await _supabase
        .from('water_measures')
        .select()
        .order('created_at', ascending: true);

    final List data = response as List;

    return data.map((item) {
      final measure = WaterMeasure(
        id: item['id'],
        ph: (item['ph'] as num).toDouble(),
        tds: (item['tds'] as num).toDouble(),
        turbidity: (item['turbidity'] as num).toDouble(),
        temperature: (item['temperature'] as num).toDouble(),
        latitude: (item['latitude'] as num).toDouble(), // AMBIL DARI CLOUD
        longitude: (item['longitude'] as num).toDouble(), // AMBIL DARI CLOUD
        timestamp: DateTime.parse(item['created_at']),
      );

      final analysisResult = AnalysisService.calculateQuality(measure);
      return HistoryItem(measure: measure, result: analysisResult);
    }).toList();
  }

  static Future<HistoryItem?> getLastData() async {
    final history = await getHistory();
    return history.isNotEmpty ? history.first : null;
  }

  static Future<void> deleteHistory(int id) async {
    await _supabase.from('water_measures').delete().eq('id', id);
  }

  // 3. STREAM DATA (Sinkronisasi Koordinat)
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
                  ph: (item['ph'] as num).toDouble(),
                  tds: (item['tds'] as num).toDouble(),
                  turbidity: (item['turbidity'] as num).toDouble(),
                  temperature: (item['temperature'] as num).toDouble(),
                  latitude: (item['latitude'] as num)
                      .toDouble(), // AMBIL DARI CLOUD
                  longitude: (item['longitude'] as num)
                      .toDouble(), // AMBIL DARI CLOUD
                  timestamp: DateTime.parse(item['created_at']),
                );
                final analysisResult = AnalysisService.calculateQuality(
                  measure,
                );
                return HistoryItem(measure: measure, result: analysisResult);
              })
              .toList()
              .reversed
              .toList();
        });
  }
}
