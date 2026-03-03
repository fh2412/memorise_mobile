import 'package:memorise_mobile/domain/models/memory_model.dart';

class InsertStandardResult {
  final String message;

  InsertStandardResult({required this.message});

  factory InsertStandardResult.fromJson(Map<String, dynamic> json) {
    return InsertStandardResult(message: json['message']);
  }
}

class PaginatedMemoryResponse {
  final List<Memory> data;
  final int page;
  final int pageSize;
  final int total;

  PaginatedMemoryResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory PaginatedMemoryResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedMemoryResponse(
      // Here we map the 'data' list from the JSON to a list of Memory objects
      data: (json['data'] as List? ?? [])
          .map((m) => Memory.fromJson(m))
          .toList(),
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 9,
      total: json['total'] ?? 0,
    );
  }
}
