import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/event_model.dart';

class EventService {
  final String _apiKey = "SYZLziH8NliWAS0sfXMnprtbFzTtNGsR";
  final String _baseUrl = "https://app.ticketmaster.com/discovery/v2/events.json";

  Future<List<EventModel>> fetchEvents({
    String? latLong,
    String? keyword,
    String? countryCode,
  }) async {
    String url = "$_baseUrl?apikey=$_apiKey";

    if (latLong != null && latLong.isNotEmpty) {
      url += "&latlong=$latLong";
    }
    else if (countryCode != null && countryCode.isNotEmpty) {
       url += "&countryCode=$countryCode";
    }


    if (keyword != null && keyword.isNotEmpty) {
      url += "&keyword=${Uri.encodeComponent(keyword)}";
    }

    print("Memanggil API (Strict LBS): $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['_embedded'] == null) return [];
        final List eventsJsonList = data['_embedded']['events'];
        List<EventModel> events = [];
        for (var eventJson in eventsJsonList) {
          events.add(EventModel.fromJson(eventJson));
        }
        return events;
      } else {
        throw Exception("Gagal memuat data event: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Terjadi error saat memanggil API: $e");
    }
  }
}