import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // --- STATE ---
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userProfile;
  int _totalMeasures = 0;

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userProfile => _userProfile;
  int get totalMeasures => _totalMeasures;

  // 1. Logika Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.login(email, password);
      await fetchFullProfile(); // Ambil profil setelah login sukses
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Gagal Masuk: Periksa kembali email dan kata sandi Anda.";
      _setLoading(false);
      return false;
    }
  }

  // 2. Logika Registrasi Petugas Baru
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String petugasId,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        petugasId: petugasId,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      if (e.toString().contains("429")) {
        _errorMessage =
            "Terlalu banyak permintaan. Silakan tunggu beberapa saat.";
      } else if (e.toString().contains("already registered")) {
        _errorMessage = "Email ini sudah terdaftar sebagai petugas.";
      } else {
        _errorMessage = "Terjadi kesalahan sistem saat mendaftar.";
      }
      _setLoading(false);
      return false;
    }
  }

  // 3. Logika Ambil Profil & Statistik (Data Nyata)
  Future<void> fetchFullProfile() async {
    // Jika sudah loading, jangan jalankan lagi (mencegah loop)
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Beritahu UI untuk tampilkan spinner

    try {
      // Berikan batas waktu 10 detik agar tidak loading selamanya
      final results = await Future.wait([
        _authService.getProfile(),
        _authService.getTotalMeasures(),
      ]).timeout(const Duration(seconds: 10));

      _userProfile = results[0] as Map<String, dynamic>?;
      _totalMeasures = results[1] as int;
    } catch (e) {
      _errorMessage = "Gagal sinkronisasi data pusat.";
      debugPrint("Error Fetch: $e");
    } finally {
      // KUNCI: Apapun yang terjadi (Error/Sukses), loading HARUS dimatikan
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Logika Update Nama Profil
  Future<void> updateName(String newName) async {
    _setLoading(true);
    try {
      await _authService.updateProfileName(newName);
      await fetchFullProfile(); // Refresh data otomatis setelah update
    } catch (e) {
      _errorMessage = "Gagal memperbarui nama.";
    }
    _setLoading(false);
  }

  // 5. Logika Reset Kata Sandi
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Gagal mengirim permintaan reset password.";
      _setLoading(false);
      return false;
    }
  }

  // 6. Logika Logout
  Future<void> logout() async {
    await _authService.signOut();
    _userProfile = null;
    _totalMeasures = 0;
    notifyListeners();
  }

  // Helper internal untuk mengelola state loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
