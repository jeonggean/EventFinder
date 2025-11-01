import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/notification_service.dart';
import '../../1_event/models/event_model.dart';
import '../../2_auth/services/auth_service.dart';

class FavoritesService {
  final AuthService _authService = AuthService();
  Future<Database> get _db async => await DatabaseService.instance.database;

  Future<int?> _getCurrentUserId() async {
    return await _authService.getCurrentUserId();
  }

  Future<List<EventModel>> getFavorites() async {
    final userId = await _getCurrentUserId();
    if (userId == null) return [];

    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC', // Tampilkan yang terbaru di atas
    );

    if (maps.isEmpty) {
      return [];
    }

    return maps.map((map) {
      final String eventJson = map['eventJson'];
      return EventModel.fromJson(jsonDecode(eventJson));
    }).toList();
  }

  Future<void> addFavorite(EventModel event) async {
    final userId = await _getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");

    final db = await _db;
    final String eventJson = jsonEncode(event.toJson());

    // Show notification when adding to favorites
    await NotificationService.showNotification(
      "Event Ditambahkan ke Favorit",
      "Event '${event.name}' telah ditambahkan ke daftar favorit Anda"
    );

    try {
      await db.insert(
        'favorites',
        {
          'userId': userId,
          'eventId': event.id,
          'eventJson': eventJson,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore, // Abaikan jika sudah ada
      );
    } catch (e) {
      print("Error adding favorite: $e");
    }
  }

  Future<void> removeFavorite(EventModel event) async {
    final userId = await _getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");

    final db = await _db;
    try {
      await db.delete(
        'favorites',
        where: 'userId = ? AND eventId = ?',
        whereArgs: [userId, event.id],
      );
    } catch (e) {
      print("Error removing favorite: $e");
    }
  }

  Future<bool> isFavorite(EventModel event) async {
    final userId = await _getCurrentUserId();
    if (userId == null) return false;

    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'userId = ? AND eventId = ?',
      whereArgs: [userId, event.id],
    );

    return maps.isNotEmpty;
  }
}