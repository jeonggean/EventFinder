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

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  EventController() {
    loadEvents(); 
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); 

    try {
      String? latLong;
      try {
        latLong = await _locationService.getCurrentLocation();
      } catch (e) {
        _errorMessage = e.toString();
      }

      _events = await _eventService.fetchEvents(latLong: latLong);

    } catch (e) {
      _errorMessage = e.toString();
      
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}