import 'package:dio/dio.dart';

/// Broad categories of network failure.
enum ApiErrorType {
  /// No connection: server offline, wrong URL or no internet.
  offline,
  timeout,

  /// The server replied with 4xx.
  client,

  /// The server replied with 5xx.
  server,
  cancelled,
  unknown,
}

/// A network error with a message that is safe to show users.
class ApiException implements Exception {
  const ApiException(this.message, {required this.type, this.statusCode});

  /// Converts any [DioException] into a friendly [ApiException].
  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiException(
          'The server is not responding. Check that it is running.',
          type: ApiErrorType.timeout,
        );
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'The server took too long to answer. Please try again.',
          type: ApiErrorType.timeout,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          "Can't reach the server. Check your internet connection and that "
          'the server is running.',
          type: ApiErrorType.offline,
        );
      case DioExceptionType.badResponse:
        return ApiException._fromResponse(error.response);
      case DioExceptionType.cancel:
        return const ApiException(
          'The request was cancelled.',
          type: ApiErrorType.cancelled,
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          "Couldn't establish a secure connection to the server.",
          type: ApiErrorType.unknown,
        );
      case DioExceptionType.unknown:
        // Socket failures on some platforms surface as "unknown".
        return const ApiException(
          'Something went wrong while contacting the server. '
          'Please try again.',
          type: ApiErrorType.unknown,
        );
      case DioExceptionType.transformTimeout:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  factory ApiException._fromResponse(Response<dynamic>? response) {
    final code = response?.statusCode ?? 0;
    final detail = _detailFrom(response?.data);

    if (code >= 500) {
      return ApiException(
        detail ?? 'The server had a problem ($code). Please try again later.',
        type: ApiErrorType.server,
        statusCode: code,
      );
    }
    return ApiException(
      detail ?? 'The request was rejected by the server ($code).',
      type: ApiErrorType.client,
      statusCode: code,
    );
  }

  final String message;
  final ApiErrorType type;

  /// HTTP status code when the server replied, otherwise null.
  final int? statusCode;

  bool get isNotFound => statusCode == 404;

  /// Reads the server's `detail` field. FastAPI sends either a string or a
  /// list of validation errors with a `msg` each.
  static String? _detailFrom(Object? data) {
    if (data is! Map) return null;
    final detail = data['detail'];
    if (detail is String && detail.trim().isNotEmpty) return detail;
    if (detail is List) {
      final messages = detail
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => e['msg'])
          .whereType<String>()
          .toList();
      if (messages.isNotEmpty) return messages.join('\n');
    }
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode, $type): $message';
}
