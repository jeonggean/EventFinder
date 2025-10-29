import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../../../core/services/location_service.dart';

class EventController extends ChangeNotifier {
  
  final EventService _eventService = EventService();
  final LocationService _locationService = LocationService();

  List<EventModel> _events = [];
  bool _isLoading = true;
  String _errorMessage = '';
  // Simpan lokasi awal agar bisa dipakai ulang saat search
  String? _currentLatLong; 

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  EventController() {
    loadEvents(); 
  }

  // Fungsi helper untuk mendapatkan lokasi awal sekali saja
  Future<void> _getInitialLocation() async {
    // Hanya ambil lokasi jika belum ada
    if (_currentLatLong == null) {
      try {
        _currentLatLong = await _locationService.getCurrentLocation();
      } catch (e) {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _currentLatLong = null; // Set null jika gagal
      }
    }
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); 

    // Panggil helper untuk dapatkan lokasi awal
    await _getInitialLocation();
    
    try {
      // Panggil service dengan lokasi awal (atau null)
      _events = await _eventService.fetchEvents(latLong: _currentLatLong);
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _events = []; // Kosongkan list jika error
    } 
    
    _isLoading = false;
    notifyListeners();
  }

  // Fungsi baru untuk melakukan pencarian
  Future<void> searchEvents(String keyword) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Panggil service dengan lokasi yang sama, tapi tambahkan keyword
      _events = await _eventService.fetchEvents(
        latLong: _currentLatLong, // Pakai lokasi yang sudah disimpan
        keyword: keyword, // Tambahkan keyword dari search bar
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
       _events = []; // Kosongkan list jika error
    }

    _isLoading = false;
    notifyListeners();
  }
}