class WaterMeasure {
  final double ph;
  final double tds;
  final double turbidity;
  final double temperature;
  final DateTime timestamp;

  WaterMeasure({
    required this.ph,
    required this.tds,
    required this.turbidity,
    required this.temperature,
    required this.timestamp,
  });
}
