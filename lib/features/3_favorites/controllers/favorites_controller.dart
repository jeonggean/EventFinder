import 'package:flutter/foundation.dart';
import '../../1_event/models/event_model.dart';
import '../services/favorites_service.dart';

class FavoritesController extends ChangeNotifier {
  final FavoritesService _service = FavoritesService();

  List<EventModel> _favorites = [];
  bool _isLoading = false;

  List<EventModel> get favorites => _favorites;
  bool get isLoading => _isLoading;

  void loadFavorites() {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = _service.getFavorites();
    } catch (e) {
      _favorites = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
