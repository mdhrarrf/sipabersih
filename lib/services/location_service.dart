import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Cek apakah GPS Aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('GPS Anda mati, harap aktifkan lokasi.');
    }

    // 2. Cek Izin saat ini
    permission = await Geolocator.checkPermission();

    // 3. JIKA IZIN DITOLAK, MINTA IZIN (Munculkan Pop-up)
    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission(); // INI YANG MEMUNCULKAN POP-UP
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Izin lokasi ditolak permanen, harap aktifkan di pengaturan HP.',
      );
    }

    // 4. Ambil Lokasi
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
