import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parfumista/models/perfume.dart'; // Import Perfume class from perfume.dart

class PerfumeApiService {
  static const String _baseUrl = 'https://fragrancefinder-api.p.rapidapi.com';
  static const Map<String, String> _headers = {
    'X-RapidAPI-Key':
        '74fd05ac82msh276ec402feda502p160167jsn207bcda42e6d', // Use a secure method to store your API key
    'X-RapidAPI-Host': 'fragrancefinder-api.p.rapidapi.com',
  };

  Future<List<Perfume>> searchPerfumes(String query) async {
    final url = Uri.parse('$_baseUrl/perfumes/search?q=$query');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Perfume.fromJson(data)).toList();
    } else {
      throw Exception(
          'Failed to load perfumes: ${response.statusCode} ${response.body}');
    }
  }
}
