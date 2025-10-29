import 'package:hive_flutter/hive_flutter.dart';
import '../../1_event/models/event_model.dart';
import '../../2_auth/services/auth_service.dart';

class FavoritesService {
  final Box _favoritesBox = Hive.box('favorites');
  final AuthService _authService = AuthService();

  String _getCurrentUser() {
    final user = _authService.getCurrentUser();
    if (user == null) {
      throw Exception("User tidak login");
    }
    return user;
  }

  List<Map> _getUserFavorites(String username) {
    final dynamicList = _favoritesBox.get(username) ?? [];
    return List<Map>.from(dynamicList);
  }

  List<EventModel> getFavorites() {
    final user = _getCurrentUser();
    final favListMap = _getUserFavorites(user);

    return favListMap
        .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite(EventModel event) async {
    final user = _getCurrentUser();
    final favList = _getUserFavorites(user);
    
    favList.add(event.toJson());
    await _favoritesBox.put(user, favList);
  }

  Future<void> removeFavorite(EventModel event) async {
    final user = _getCurrentUser();
    final favList = _getUserFavorites(user);

    favList.removeWhere((item) => item['id'] == event.id);
    await _favoritesBox.put(user, favList);
  }

  bool isFavorite(EventModel event) {
    try {
      final user = _getCurrentUser();
      final favList = _getUserFavorites(user);
      return favList.any((item) => item['id'] == event.id);
    } catch (e) {
      return false;
    }
  }
}