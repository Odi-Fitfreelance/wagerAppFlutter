import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'https://friendlywagerbackend.robservices.de/api';
  static const Duration timeout = Duration(seconds: 30);

  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Inject JWT token from secure storage
          try {
            if (kDebugMode) {
              print('🔐 [API] Reading token from secure storage for ${options.path}...');
            }
            final token = await _secureStorage.read(key: 'auth_token');
            if (token != null) {
              if (kDebugMode) {
                print('✅ [API] Token found, injecting into Authorization header');
              }
              options.headers['Authorization'] = 'Bearer $token';
            } else {
              if (kDebugMode) {
                print('⚠️ [API] No token found in secure storage');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('❌ [API] CRITICAL: Failed to read token from secure storage: $e');
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Handle 401 Unauthorized - clear token
          if (error.response?.statusCode == 401) {
            await _secureStorage.delete(key: 'auth_token');
            await _secureStorage.delete(key: 'user_data');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // Helper method to handle API responses
  Future<T> handleResponse<T>(
    Future<Response> Function() request,
    T Function(dynamic) parser,
  ) async {
    try {
      final response = await request();
      return parser(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Helper method to handle errors
  ApiException _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (kDebugMode) {
        print('🔴 API Error Response: $data');
      }

      String message;
      if (data is Map<String, dynamic>) {
        // Try to extract detailed error message
        message = data['message'] ??
                  data['error'] ??
                  data['details'] ??
                  'An error occurred';

        // If there's additional error info, log it
        if (data['errors'] != null) {
          if (kDebugMode) {
            print('🔴 Validation errors: ${data['errors']}');
          }
          message = '$message: ${data['errors']}';
        }
      } else {
        message = 'An error occurred';
      }

      return ApiException(
        message: message,
        statusCode: error.response!.statusCode,
      );
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Connection timeout. Please check your internet connection.',
      );
    } else if (error.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'No internet connection. Please check your network.',
      );
    } else {
      return ApiException(
        message: error.message ?? 'An unexpected error occurred',
      );
    }
  }

  // GET request
  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(String endpoint, {dynamic data}) async {
    try {
      return await _dio.delete(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(String endpoint, {dynamic data}) async {
    try {
      return await _dio.patch(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file with multipart
  Future<Response> uploadFile(
    String endpoint,
    String fieldName,
    String filePath, {
    Map<String, dynamic>? additionalData,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      if (additionalData != null) ...additionalData,
    });

    return await _dio.post(
      endpoint,
      data: formData,
      onSendProgress: onSendProgress,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}
