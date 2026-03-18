import 'dart:async';
import 'package:flutter/material.dart';
import '../models/water_measure.dart';
import '../models/analysis_result.dart';
import '../services/history_service.dart';

class WaterViewModel extends ChangeNotifier {
  List<HistoryItem> _history = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _subscription;

  // Getters
  List<HistoryItem> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filter untuk menu Air Bersih
  List<HistoryItem> get cleanWaterList =>
      _history.where((item) => item.result.status == "AMAN").toList();

  WaterViewModel() {
    _initDataStream();
  }

  void _initDataStream() {
    _subscription = HistoryService.getHistoryStream().listen(
      (data) {
        _history = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = "Koneksi cloud terputus";
        notifyListeners();
      },
    );
  }

  Future<bool> saveMeasure(WaterMeasure measure, AnalysisResult result) async {
    try {
      await HistoryService.addHistory(measure, result);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteData(int id) async {
    await HistoryService.deleteHistory(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
