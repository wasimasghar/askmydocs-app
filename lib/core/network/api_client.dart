import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';
import 'api_exception.dart';

/// The app's single HTTP client.
///
/// Every method returns the decoded JSON body (`Map`, `List`, ...) and throws
/// [ApiException] on any failure, so callers never see a [DioException].
class ApiClient {
  ApiClient({String? baseUrl, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? ApiConfig.baseUrl,
                connectTimeout: ApiConfig.connectTimeout,
                receiveTimeout: ApiConfig.receiveTimeout,
                contentType: Headers.jsonContentType,
                responseType: ResponseType.json,
                headers: const {'Accept': 'application/json'},
              ),
            ) {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (line) => debugPrint(line.toString()),
        ),
      );
    }
  }

  final Dio _dio;

  /// GET [path] with optional query parameters.
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: query));

  /// POST [data] as JSON to [path].
  Future<dynamic> post(String path, {Object? data}) =>
      _send(() => _dio.post<dynamic>(path, data: data));

  /// DELETE [path].
  Future<dynamic> delete(String path) =>
      _send(() => _dio.delete<dynamic>(path));

  /// POST a file as multipart/form-data.
  ///
  /// Works from bytes (not a file path) so it runs on web too.
  /// [receiveTimeout] overrides the default 60s for slow server-side work.
  Future<dynamic> postMultipart(
    String path, {
    required String fileName,
    required List<int> bytes,
    String fieldName = 'file',
    DioMediaType? contentType,
    Map<String, dynamic>? fields,
    Duration? receiveTimeout,
    ProgressCallback? onSendProgress,
  }) {
    final formData = FormData.fromMap({
      ...?fields,
      fieldName: MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: contentType,
      ),
    });
    return _send(
      () => _dio.post<dynamic>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(receiveTimeout: receiveTimeout),
      ),
    );
  }

  /// Releases the underlying connections.
  void close() => _dio.close();

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
