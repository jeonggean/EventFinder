import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/utils/constants.dart';
import '../models/event_model.dart';

class EventService {
  final String _apiKey = Constants.ticketMasterApiKey;
  final String _baseUrl = "https://app.ticketmaster.com/discovery/v2";

  Future<List<EventModel>> fetchEvents({
    String? latLong,
    String? countryCode,
    String? keyword,
  }) async {
    Map<String, dynamic> params = {
      'apikey': _apiKey,
      'size': '40',
      'sort': 'date,asc',
      'classificationName': 'Music,Sports,Arts & Theatre',
    };

    if (keyword != null && keyword.isNotEmpty) {
      params['keyword'] = keyword;
    }

    if (latLong != null) {
      params['latlong'] = latLong;
      params['radius'] = '5000';
      params['unit'] = 'km';
    }

    if (countryCode != null) {
      params['countryCode'] = countryCode;
    }

    final Uri uri =
        Uri.parse("$_baseUrl/events.json").replace(queryParameters: params);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('_embedded') && data['_embedded'] != null) {
          final List<dynamic> eventList = data['_embedded']['events'];
          return eventList
              .map((json) => EventModel.fromJson(json))
              .toList();
        }
        return [];
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('HTTP Body: ${response.body}');
        throw Exception(
            'Gagal memuat data event (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Gagal memuat data event. Cek koneksi internet.');
    }
  }
}