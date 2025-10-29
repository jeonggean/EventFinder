import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/event_model.dart';

class EventService {
  final String _apiKey = "SYZLziH8NliWAS0sfXMnprtbFzTtNGsR";
  final String _baseUrl = "https://app.ticketmaster.com/discovery/v2/events.json";

  Future<List<EventModel>> fetchEvents({String? latLong}) async {
    String url = "$_baseUrl?apikey=$_apiKey";

    if (latLong != null && latLong.isNotEmpty) {
      url += "&latlong=$latLong";
    } else {
      url += "&countryCode=US";
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List eventsJsonList = data['_embedded']['events'];
        
        List<EventModel> events = [];
        for (var eventJson in eventsJsonList) {
          events.add(EventModel.fromJson(eventJson));
        }
        
        return events;
      } else {
        throw Exception("Gagal memuat data event");
      }
    } catch (e) {
      throw Exception("Terjadi error: $e");
    }
  }
}