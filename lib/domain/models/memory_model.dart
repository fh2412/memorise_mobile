class Memory {
  final int memoryId;
  final String userId;
  final String imageUrl;
  final double? latitude;
  final double? longitude;
  final int locationId;
  final DateTime memoryDate;
  final DateTime memoryEndDate;
  final int pictureCount;
  final String text;
  final String title;
  final String titlePic;
  final String username;
  final int activityId;
  final String? shareToken;

  Memory({
    required this.memoryId,
    required this.userId,
    required this.imageUrl,
    this.latitude,
    this.longitude,
    required this.locationId,
    required this.memoryDate,
    required this.memoryEndDate,
    required this.pictureCount,
    required this.text,
    required this.title,
    required this.titlePic,
    required this.username,
    required this.activityId,
    this.shareToken,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      memoryId: json['memory_id'],
      userId: json['user_id'],
      imageUrl: json['image_url'] ?? '',
      // Parsing strings to doubles safely
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      locationId: json['location_id'] ?? 0,
      // Parsing dates
      memoryDate: DateTime.parse(
        json['memory_date'] ?? DateTime.now().toIso8601String(),
      ),
      memoryEndDate: DateTime.parse(
        json['memory_end_date'] ?? DateTime.now().toIso8601String(),
      ),
      pictureCount: json['picture_count'] ?? 0,
      text: json['text'] ?? '',
      title: json['title'] ?? 'Untitled Memory',
      titlePic: json['title_pic'] ?? '',
      username: json['username'] ?? 'Unknown User',
      activityId: json['activity_id'] ?? 0,
      shareToken: json['share_token'],
    );
  }
}

enum MemoryFilter { all, created, added }
