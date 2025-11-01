import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../../../core/services/location_service.dart';

enum EventListMode { regional, popular }

class EventController extends ChangeNotifier {
  final EventService _eventService = EventService();
  final LocationService _locationService = LocationService();

  List<EventModel> _regionalEvents = [];
  List<EventModel> _popularEventsGlobal = [];
  bool _isLoadingRegional = true;
  bool _isLoadingPopular = false;
  String _errorMessage = '';
  String? _currentLatLong;
  EventListMode _currentMode = EventListMode.regional;
  bool _hasTriedLoadingPopular = false;
  bool _disposed = false;

  List<EventModel> get eventsToShow =>
      _currentMode == EventListMode.regional
          ? _regionalEvents
          : _popularEventsGlobal;
  bool get isLoading => _currentMode == EventListMode.regional
      ? _isLoadingRegional
      : _isLoadingPopular;
  String get errorMessage => _errorMessage;
  EventListMode get currentMode => _currentMode;

  EventController() {
    loadRegionalEvents();
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

  Future<void> loadRegionalEvents({String? keyword}) async {
    _isLoadingRegional = true;
    if (keyword == null) _errorMessage = '';
    _safeNotifyListeners();

    await _getInitialLocation();
    if (_disposed) return;

    if (_currentLatLong == null) {
      _regionalEvents = [];
      _isLoadingRegional = false;
      _safeNotifyListeners();
      return;
    }

    try {
      _regionalEvents = await _eventService.fetchEvents(
        latLong: _currentLatLong,
        radius: "2500",
        keyword: keyword,
      );
      if (_disposed) return;
      if (_errorMessage.contains('lokasi')) _errorMessage = '';
    } catch (e) {
      if (_disposed) return;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _regionalEvents = [];
    }

    _isLoadingRegional = false;
    _safeNotifyListeners();
  }

  Future<void> loadPopularGlobalEvents({String? keyword}) async {
    if (!_hasTriedLoadingPopular || keyword != null) {
      _isLoadingPopular = true;
      if (keyword == null) _errorMessage = '';
      _safeNotifyListeners();

      try {
        _popularEventsGlobal = await _eventService.fetchEvents(
          keyword: keyword,
        );
        if (_disposed) return;
        _hasTriedLoadingPopular = true;
        _errorMessage = '';
      } catch (e) {
        if (_disposed) return;
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _popularEventsGlobal = [];
      }

      _isLoadingPopular = false;
      _safeNotifyListeners();
    }
  }

  Future<void> searchEvents(String keyword) async {
    if (_currentMode == EventListMode.regional) {
      await loadRegionalEvents(keyword: keyword);
    } else {
      await loadPopularGlobalEvents(keyword: keyword);
    }
  }

  void changeMode(EventListMode newMode) {
    if (_currentMode != newMode) {
      _currentMode = newMode;
      if (!(_currentMode == EventListMode.regional &&
          _errorMessage.contains('lokasi'))) {
        _errorMessage = '';
      }
      if (newMode == EventListMode.popular && !_hasTriedLoadingPopular) {
        loadPopularGlobalEvents();
      } else {
        _safeNotifyListeners();
      }
    }
  }
}