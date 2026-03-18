class WaterMeasure {
  final int? id; // Tambahkan ID untuk primary key database
  final double ph;
  final double tds;
  final double turbidity;
  final double temperature;
  final DateTime timestamp;

  WaterMeasure({
    this.id, // ID boleh null saat pertama kali dibuat
    required this.ph,
    required this.tds,
    required this.turbidity,
    required this.temperature,
    required this.timestamp,
  });

  // Mengubah objek ke Map (untuk disimpan ke Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ph': ph,
      'tds': tds,
      'turbidity': turbidity,
      'temperature': temperature,
      'timestamp': timestamp.toIso8601String(), // Simpan tgl dalam bentuk teks
    };
  }

  // Mengubah Map dari Database kembali ke objek WaterMeasure
  factory WaterMeasure.fromMap(Map<String, dynamic> map) {
    return WaterMeasure(
      id: map['id'],
      ph: map['ph'],
      tds: map['tds'],
      turbidity: map['turbidity'],
      temperature: map['temperature'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
