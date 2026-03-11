class MemoryPhoto {
  final String url;
  final double width;
  final double height;
  final bool isStarred;
  final String userId;
  final String? timeCreated;
  final int? size;

  MemoryPhoto({
    required this.url,
    required this.width,
    required this.height,
    required this.userId,
    this.isStarred = false,
    this.timeCreated,
    this.size,
  });

  double get aspectRatio => (width > 0 && height > 0) ? width / height : 1.0;
}
