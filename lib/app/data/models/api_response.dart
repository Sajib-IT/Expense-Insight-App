class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final PaginationMeta? meta;
  final List<ApiErrorMessage>? errorMessages;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.meta,
    this.errorMessages,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromJsonT,
  }) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'])
          : null,
      errorMessages: json['errorMessages'] != null
          ? (json['errorMessages'] as List)
              .map((e) => ApiErrorMessage.fromJson(e))
              .toList()
          : null,
    );
  }
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class ApiErrorMessage {
  final String? path;
  final String? message;

  ApiErrorMessage({this.path, this.message});

  factory ApiErrorMessage.fromJson(Map<String, dynamic> json) {
    return ApiErrorMessage(
      path: json['path'],
      message: json['message'],
    );
  }
}
