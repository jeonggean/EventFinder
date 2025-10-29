import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../../../core/services/location_service.dart';

enum EventListMode { nearby, popular }

class EventController extends ChangeNotifier {
  final EventService _eventService = EventService();
  final LocationService _locationService = LocationService();

  List<EventModel> _nearbyEvents = [];
  List<EventModel> _popularEventsUS = [];
  bool _isLoadingNearby = true;
  bool _isLoadingPopular = false;
  String _errorMessage = '';
  String? _currentLatLong;
  EventListMode _currentMode = EventListMode.nearby;
  bool _hasTriedLoadingPopular = false;
  bool _disposed = false;

  List<EventModel> get eventsToShow =>
      _currentMode == EventListMode.nearby ? _nearbyEvents : _popularEventsUS;
  bool get isLoading =>
      _currentMode == EventListMode.nearby ? _isLoadingNearby : _isLoadingPopular;
  String get errorMessage => _errorMessage;
  EventListMode get currentMode => _currentMode;

  EventController() {
    loadNearbyEvents();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> _getInitialLocation() async {
    if (_currentLatLong == null) {
      try {
        _currentLatLong = await _locationService.getCurrentLocation();
        if (_disposed) return;
        _errorMessage = '';
        _safeNotifyListeners();
      } catch (e) {
         if (_disposed) return;
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _currentLatLong = null;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> loadNearbyEvents({String? keyword}) async {
    _isLoadingNearby = true;
    if (keyword == null) _errorMessage = '';
    _safeNotifyListeners();

    await _getInitialLocation();
    if (_disposed) return;

    if (_currentLatLong == null) {
        _nearbyEvents = [];
        _isLoadingNearby = false;
        _safeNotifyListeners();
        return;
    }

    try {
      _nearbyEvents = await _eventService.fetchEvents(
        latLong: _currentLatLong,
        keyword: keyword,
      );
      if (_disposed) return;
       if (_errorMessage.contains('lokasi')) _errorMessage = '';
    } catch (e) {
      if (_disposed) return;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _nearbyEvents = [];
    }

    _isLoadingNearby = false;
    _safeNotifyListeners();
  }

  Future<void> loadPopularEventsUS({String? keyword}) async {
    if (!_hasTriedLoadingPopular || keyword != null) {
      _isLoadingPopular = true;
       if (keyword == null) _errorMessage = '';
      _safeNotifyListeners();

      try {
        _popularEventsUS = await _eventService.fetchEvents(
          countryCode: "US",
          keyword: keyword,
        );
         if (_disposed) return;
         _hasTriedLoadingPopular = true;
         _errorMessage = '';
      } catch (e) {
         if (_disposed) return;
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _popularEventsUS = [];
      }

      _isLoadingPopular = false;
      _safeNotifyListeners();
    }
  }

  Future<void> searchEvents(String keyword) async {
    if (_currentMode == EventListMode.nearby) {
      await loadNearbyEvents(keyword: keyword);
    } else {
      await loadPopularEventsUS(keyword: keyword);
    }
  }

  void changeMode(EventListMode newMode) {
    if (_currentMode != newMode) {
      _currentMode = newMode;
      if (!(_currentMode == EventListMode.nearby && _errorMessage.contains('lokasi'))) {
           _errorMessage = '';
      }
      if (newMode == EventListMode.popular && !_hasTriedLoadingPopular) {
        loadPopularEventsUS();
      } else {
        _safeNotifyListeners();
      }
    }
  }
}