class WaterMeasure {
  final int? id;
  final double ph;
  final double tds;
  final double turbidity;
  final double temperature;
  final double latitude; // Koordinat Lintang
  final double longitude; // Koordinat Bujur
  final DateTime timestamp;

  WaterMeasure({
    this.id,
    required this.ph,
    required this.tds,
    required this.turbidity,
    required this.temperature,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  // Untuk menyimpan ke Database (Supabase / SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ph': ph,
      'tds': tds,
      'turbidity': turbidity,
      'temperature': temperature,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // PERBAIKAN: Menarik data koordinat dari Database kembali ke objek Flutter
  factory WaterMeasure.fromMap(Map<String, dynamic> map) {
    return WaterMeasure(
      id: map['id'],
      // Gunakan .toDouble() untuk keamanan tipe data num dari database
      ph: (map['ph'] as num).toDouble(),
      tds: (map['tds'] as num).toDouble(),
      turbidity: (map['turbidity'] as num).toDouble(),
      temperature: (map['temperature'] as num).toDouble(),
      latitude: (map['latitude'] as num).toDouble(), // TAMBAHKAN INI
      longitude: (map['longitude'] as num).toDouble(), // TAMBAHKAN INI
      timestamp: DateTime.parse(map['timestamp'] ?? map['created_at']),
    );
  }
}
