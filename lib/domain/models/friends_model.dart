class MemoryAttendee {
  final String userId;
  final String name;
  final DateTime? dob;
  final String? profilePic;
  final String? country;

  MemoryAttendee({
    required this.userId,
    required this.name,
    this.dob,
    this.profilePic,
    this.country,
  });

  // Factory constructor to create an instance from JSON
  factory MemoryAttendee.fromJson(Map<String, dynamic> json) {
    return MemoryAttendee(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      // Safely parsing the date of birth
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      profilePic: json['profilepic'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'dob': dob?.toIso8601String(),
      'profilepic': profilePic,
      'country': country,
    };
  }

  // Helper to get initials if there is no profile pic
  String get initials => name.isNotEmpty
      ? name
            .trim()
            .split(RegExp(' +'))
            .map((s) => s[0])
            .take(2)
            .join()
            .toUpperCase()
      : "";
}

class MemoryMissingFriend {
  final String userId;
  final String name;
  final String email;
  final String? profilePic;

  MemoryMissingFriend({
    required this.userId,
    required this.name,
    required this.email,
    this.profilePic,
  });

  // Factory constructor to create an instance from JSON
  factory MemoryMissingFriend.fromJson(Map<String, dynamic> json) {
    return MemoryMissingFriend(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePic: json['profilepic'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'profilepic': profilePic,
    };
  }
}
