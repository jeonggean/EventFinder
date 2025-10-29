import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyService {
  final String _apiKey = "a9eb08984412a4358456322b"; 
  final String _baseUrl = "https://v6.exchangerate-api.com/v6";

  Future<Map<String, dynamic>> getRates() async {
    final String url = "$_baseUrl/$_apiKey/latest/USD";
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'success') {
          return data['conversion_rates'];
        } else {
          throw Exception('Gagal memuat data kurs: ${data['error-type']}');
        }
      } else {
        throw Exception('Gagal memanggil API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}