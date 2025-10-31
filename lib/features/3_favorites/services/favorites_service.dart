import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/services/notification_service.dart';
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
    print(
      'DEBUG FAVORITES SERVICE: Getting raw favorites for $username from Hive',
    );
    print('DEBUG FAVORITES SERVICE: Raw data type: ${dynamicList.runtimeType}');
    print('DEBUG FAVORITES SERVICE: Raw data: $dynamicList');
    final result = List<Map>.from(dynamicList);
    print(
      'DEBUG FAVORITES SERVICE: Converted to List<Map>, count: ${result.length}',
    );
    return result;
  }

  List<EventModel> getFavorites() {
    final user = _getCurrentUser();
    final favListMap = _getUserFavorites(user);

    print('DEBUG FAVORITES: Getting favorites for user $user');
    print('DEBUG FAVORITES: Found ${favListMap.length} favorites');

    return favListMap
        .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite(EventModel event) async {
    final user = _getCurrentUser();
    print('DEBUG FAVORITES: Current user: $user');

    final favList = _getUserFavorites(user);
    print(
      'DEBUG FAVORITES: Current favorites count before add: ${favList.length}',
    );

    favList.add(event.toJson());
    print('DEBUG FAVORITES: Favorites count after add: ${favList.length}');

    await _favoritesBox.put(user, favList);
    print('DEBUG FAVORITES: Saved to Hive for user: $user');

    // Verify saved data
    final verify = _favoritesBox.get(user);
    print(
      'DEBUG FAVORITES: Verification - data in Hive: ${verify?.length ?? 0} items',
    );

    print('DEBUG FAVORITES: Added ${event.name} for user $user');
    print('DEBUG FAVORITES: Total favorites now: ${favList.length}');

    // Show instant notification when adding to favorites
    await NotificationService.showNotification(
      '⭐ Event ditambahkan ke favorit!',
      '${event.name} berhasil ditambahkan ke daftar favorit Anda.',
    );
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
