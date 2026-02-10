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
  final String formattedDob;
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
    required this.formattedDob,
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
      accountType: AccountType.values.byName(
        json['account_type'],
      ), // Maps string to enum
      username: json['username'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'] ?? '', // Handle potential nulls
      country: json['country'],
      countryCca2: json['country_cca2'],
      gender: json['gender'],
      formattedDob: json['formatted_dob'],
      dob: json['dob'],
      instagram: json['instagram'] ?? '',
      locationId: json['location_id'] ?? 0,
      profilePic: json['profilepic'] ?? '',
      companyId: json['company_id'] ?? 0,
    );
  }
}
