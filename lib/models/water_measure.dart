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
    // Ambil teks tanggal dari 'created_at' (format Supabase)
    String dateStr =
        map['created_at'] ??
        map['timestamp'] ??
        DateTime.now().toIso8601String();

    // Konversi teks ke DateTime
    DateTime utcTime = DateTime.parse(dateStr);

    return WaterMeasure(
      id: map['id'],
      ph: (map['ph'] ?? 0.0 as num).toDouble(),
      tds: (map['tds'] ?? 0.0 as num).toDouble(),
      turbidity: (map['turbidity'] ?? 0.0 as num).toDouble(),
      temperature: (map['temperature'] ?? 0.0 as num).toDouble(),
      latitude: (map['latitude'] ?? 0.0 as num).toDouble(),
      longitude: (map['longitude'] ?? 0.0 as num).toDouble(),
      // KUNCI: Paksa konversi dari UTC ke waktu Lokal HP Anda
      timestamp: utcTime.toLocal(),
    );
  }
}
