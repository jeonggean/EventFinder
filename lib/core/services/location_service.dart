import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi tidak aktif.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen, buka pengaturan HP.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> getCurrentLocation() async {
    Position position = await _getPosition();
    return "${position.latitude},${position.longitude}";
  }

  Future<Placemark> _getPlacemark() async {
    try {
      Position position = await _getPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks[0];
      }
      throw Exception("Tidak ada placemark ditemukan.");
    } catch (e) {
      print('Error di _getPlacemark: $e');
      throw Exception('Gagal mendapatkan info lokasi.');
    }
  }

  Future<String?> getCityName() async {
    try {
      Placemark place = await _getPlacemark();
      return place.locality ?? place.subAdministrativeArea ?? "Lokasi";
    } catch (e) {
      return "Gagal dapat lokasi";
    }
  }

  Future<String?> getCountryCode() async {
    try {
      Placemark place = await _getPlacemark();
      return place.isoCountryCode;
    } catch (e) {
      return null;
    }
  }
}