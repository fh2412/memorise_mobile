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
