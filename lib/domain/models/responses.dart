class InsertStandardResult {
  final String message;

  InsertStandardResult({required this.message});

  factory InsertStandardResult.fromJson(Map<String, dynamic> json) {
    return InsertStandardResult(message: json['message']);
  }
}
