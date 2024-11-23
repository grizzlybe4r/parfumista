// services/api_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:parfumista/models/perfume.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'ApiException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
}

class PerfumeApiService {
  static const String _baseUrl = 'https://fragrancefinder-api.p.rapidapi.com';
  static const Map<String, String> _headers = {
    'X-RapidAPI-Key': 'f7f2f7b6b9msh06545cc3c2651b2p1e18b3jsnfaeaebe5c8bb',
    'X-RapidAPI-Host': 'fragrancefinder-api.p.rapidapi.com',
  };

  final http.Client _client;

  // Dependency injection untuk memudahkan testing
  PerfumeApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Perfume>> searchPerfumes(String query) async {
    try {
      // Sanitasi query
      final sanitizedQuery = Uri.encodeComponent(query.trim());
      final url = Uri.parse('$_baseUrl/perfumes/search?q=$sanitizedQuery');

      // Tambahkan timeout
      final response = await _client
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final String responseBody = response.body;
        if (responseBody.isEmpty) {
          return [];
        }

        try {
          final List<dynamic> jsonResponse = jsonDecode(responseBody);
          final List<Perfume> perfumes = [];

          for (var item in jsonResponse) {
            try {
              if (item is Map<String, dynamic>) {
                perfumes.add(Perfume.fromJson(item));
              }
            } catch (e) {
              print('Error parsing perfume: $e');
              // Lanjutkan ke item berikutnya jika ada error pada satu item
              continue;
            }
          }

          return perfumes;
        } on FormatException catch (e) {
          throw ApiException('Failed to parse response: ${e.message}');
        }
      } else if (response.statusCode == 429) {
        throw ApiException('Rate limit exceeded. Please try again later.',
            response.statusCode);
      } else if (response.statusCode >= 500) {
        throw ApiException(
            'Server error. Please try again later.', response.statusCode);
      } else {
        throw ApiException(
            'Failed to load perfumes: ${response.statusCode} ${response.body}',
            response.statusCode);
      }
    } on TimeoutException {
      throw ApiException(
          'Request timed out. Please check your internet connection.');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  // Bersihkan resources
  void dispose() {
    _client.close();
  }

  // Method untuk mencoba koneksi API
  Future<bool> testConnection() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/perfumes/search?q=test'), headers: _headers)
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
