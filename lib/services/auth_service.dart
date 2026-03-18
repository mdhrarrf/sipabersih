import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Fungsi Registrasi (Sinkron dengan Database Trigger)
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String petugasId,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'petugas_id': petugasId},
    );
  }

  // 2. Fungsi Login
  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 3. Fungsi Ambil Data Profil Petugas (Nama & ID Asli)
  Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;

    return await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }

  // 4. FUNGSI BARU: Hitung Total Pengukuran (Statistik Nyata)
  // FUNGSI: Hitung Total Pengukuran (Versi Supabase 2.x)
  // FUNGSI: Hitung Total Pengukuran (Versi Paling Stabil)
  Future<int> getTotalMeasures() async {
    final user = currentUser;
    if (user == null) return 0;

    try {
      // Kita mengambil kolom 'id' saja agar data yang diunduh sangat kecil/ringan,
      // lalu kita hitung jumlah item (length) dari list yang dikembalikan.
      final List<dynamic> response = await _supabase
          .from('water_measures')
          .select('id')
          .eq('petugas_id', user.id);

      return response.length;
    } catch (e) {
      print("Error hitung data: $e");
      return 0;
    }
  }

  // 5. FUNGSI BARU: Update Nama Petugas di Database
  Future<void> updateProfileName(String newName) async {
    final user = currentUser;
    if (user == null) return;

    await _supabase
        .from('profiles')
        .update({
          'full_name': newName,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', user.id);
  }

  // 6. Logout & Session Management
  Future<void> signOut() async => await _supabase.auth.signOut();
  User? get currentUser => _supabase.auth.currentUser;

  // Tambahkan ini di lib/services/auth_service.dart
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
