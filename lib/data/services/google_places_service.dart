import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacePrediction {
  final String description;
  final String placeId;
  final String mainText;

  PlacePrediction({
    required this.description,
    required this.placeId,
    required this.mainText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      description: json['description'],
      placeId: json['place_id'],
      mainText: json['structured_formatting']?['main_text'] ?? '',
    );
  }
}

class GooglePlacesService {
  final String apiKey;
  GooglePlacesService(this.apiKey);

  Future<List<PlacePrediction>> getAutocomplete(String input) async {
    if (input.isEmpty) return [];

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List predictions = data['predictions'];
      return predictions.map((p) => PlacePrediction.fromJson(p)).toList();
    } else {
      throw Exception('Failed to fetch predictions');
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['result']; // Contains geometry.location.lat/lng
    } else {
      throw Exception('Failed to fetch details');
    }
  }
}
