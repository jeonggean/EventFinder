import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../../../core/services/location_service.dart';

enum EventListMode { asean, popular }

class EventController extends ChangeNotifier {
  final EventService _eventService = EventService();

  List<EventModel> _aseanEvents = [];
  List<EventModel> _popularEventsGlobal = [];
  bool _isLoadingAsean = true;
  bool _isLoadingPopular = false;
  String _errorMessage = '';
  EventListMode _currentMode = EventListMode.asean;
  bool _hasTriedLoadingPopular = false;
  bool _disposed = false;

  List<EventModel> get eventsToShow =>
      _currentMode == EventListMode.asean ? _aseanEvents : _popularEventsGlobal;
  bool get isLoading => _currentMode == EventListMode.asean
      ? _isLoadingAsean
      : _isLoadingPopular;
  String get errorMessage => _errorMessage;
  EventListMode get currentMode => _currentMode;

  EventController() {
    loadAseanEvents();
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

  Future<void> loadAseanEvents({String? keyword}) async {
    _isLoadingAsean = true;
    if (keyword == null) _errorMessage = '';
    _safeNotifyListeners();

    try {
      _aseanEvents = await _eventService.fetchEvents(
        countryCode: "ID,SG,MY,TH,PH,VN",
        keyword: keyword,
      );
      if (_disposed) return;
      _errorMessage = '';
    } catch (e) {
      if (_disposed) return;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _aseanEvents = [];
    }

    _isLoadingAsean = false;
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
    if (_currentMode == EventListMode.asean) {
      await loadAseanEvents(keyword: keyword);
    } else {
      await loadPopularGlobalEvents(keyword: keyword);
    }
  }

  void changeMode(EventListMode newMode) {
    if (_currentMode != newMode) {
      _currentMode = newMode;
      _errorMessage = '';
      if (newMode == EventListMode.popular && !_hasTriedLoadingPopular) {
        loadPopularGlobalEvents();
      } else {
        _safeNotifyListeners();
      }
    }
  }
}