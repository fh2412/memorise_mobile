class MemoriseLocation {
  final double latitude;
  final double longitude;
  final String country;
  final String countryCode;
  final String? city;
  final int locationId;

  MemoriseLocation({
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.countryCode,
    this.city,
    required this.locationId,
  });

  // Factory method to create an instance from JSON
  factory MemoriseLocation.fromJson(Map<String, dynamic> json) {
    return MemoriseLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String,
      countryCode: json['countryCode'] as String,
      city: json['city'] as String?,
      locationId: json['location_id'] as int,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'countryCode': countryCode,
      'city': city,
      'location_id': locationId,
    };
  }
}

class CreateLocationResponse {
  final String message;
  final int locationId;

  CreateLocationResponse({required this.message, required this.locationId});

  factory CreateLocationResponse.fromJson(Map<String, dynamic> json) {
    return CreateLocationResponse(
      message: json['message'] as String,
      locationId: json['locationId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'locationId': locationId};
  }
}
