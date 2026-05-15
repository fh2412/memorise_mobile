class MemoriseLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String country;
  final String countryCode;
  final String? city;
  final int locationId;

  MemoriseLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.country,
    required this.countryCode,
    this.city,
    required this.locationId,
  });

  // Factory method to create an instance from JSON
  factory MemoriseLocation.fromJson(Map<String, dynamic> json) {
    return MemoriseLocation(
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      address: json['address'] as String? ?? 'Unknown Address',
      country: json['country'] as String? ?? '',
      countryCode: json['alpha_2_codes'] as String? ?? '',
      city: json['locality'] as String?,
      locationId: json['location_id'] as int,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
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
