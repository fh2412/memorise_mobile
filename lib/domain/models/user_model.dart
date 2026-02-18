enum AccountType { FREE, PRO, UNLIMITED }

class MemoriseUser {
  final String userId;
  final AccountType accountType;
  final String username;
  final String name;
  final String email;
  final String bio;
  final String country;
  final String countryCca2;
  final String gender;
  final String dob;
  final String instagram;
  final int locationId;
  final String profilePic;
  final int companyId;

  MemoriseUser({
    required this.userId,
    required this.accountType,
    required this.username,
    required this.name,
    required this.email,
    required this.bio,
    required this.country,
    required this.countryCca2,
    required this.gender,
    required this.dob,
    required this.instagram,
    required this.locationId,
    required this.profilePic,
    required this.companyId,
  });

  // This is the "Mapper" logic
  factory MemoriseUser.fromJson(Map<String, dynamic> json) {
    return MemoriseUser(
      userId: json['user_id'],
      accountType: AccountType.values.byName(json['account_type']),
      username: json['username'] ?? 'No username set',
      name: json['name'] ?? 'No name set',
      email: json['email'],
      bio: json['bio'] ?? 'No bio set',
      country: json['country'] ?? 'No country ser',
      countryCca2: json['country_cca2'] ?? 'XX',
      gender: json['gender'] ?? 'n.a.',
      dob: json['dob'] ?? '01-01-1001',
      instagram: json['instagram'] ?? '',
      locationId: json['location_id'] ?? 0,
      profilePic: json['profilepic'] ?? '',
      companyId: json['company_id'] ?? 0,
    );
  }
}

class Friend {
  final String userId;
  final String name;
  final String email;
  final String dob;
  final String gender;
  final String profilePic;

  Friend({
    required this.userId,
    required this.name,
    required this.email,
    required this.dob,
    required this.gender,
    required this.profilePic,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      userId: json['user_id'],
      name: json['name'] ?? 'No name set',
      email: json['email'],
      gender: json['gender'] ?? 'n.a.',
      dob: json['dob'] ?? '01-01-1001',
      profilePic: json['profilepic'] ?? '',
    );
  }
}
