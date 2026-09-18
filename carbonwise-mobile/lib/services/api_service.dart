import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;
  final bool isNetworkError;
  final bool isTimeout;

  ApiException({
    this.statusCode,
    required this.message,
    this.data,
    this.isNetworkError = false,
    this.isTimeout = false,
  });

  @override
  String toString() => message;
}

class ApiService {
  late final Dio _dio;

  ApiService({String? customBaseUrl}) {
    final effectiveBase = _normalizeBaseUrl(customBaseUrl ?? AppConstants.baseUrl);
    _dio = Dio(BaseOptions(
      baseUrl: effectiveBase,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
      sendTimeout: const Duration(seconds: 45),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  static String _normalizeBaseUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  String _resolvePath(String path) {
    final cleanPath = path.trim();
    final baseUrl = _dio.options.baseUrl;
    
    // If baseUrl already ends with /api, and path starts with /api/, strip one /api
    if (baseUrl.endsWith('/api') && cleanPath.startsWith('/api/')) {
      return cleanPath.substring(4); // returns /auth/login, etc.
    }
    if (baseUrl.endsWith('/api') && cleanPath.startsWith('api/')) {
      return '/${cleanPath.substring(4)}';
    }
    if (!cleanPath.startsWith('/')) {
      return '/$cleanPath';
    }
    return cleanPath;
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestPath = err.requestOptions.path;
    final isAuthEndpoint = requestPath.contains('/auth/login') ||
        requestPath.contains('/auth/register') ||
        requestPath.contains('/auth/refresh');

    // Attempt token refresh on 401 for protected endpoints only
    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(AppConstants.refreshTokenKey);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshPath = _resolvePath('/api/auth/refresh');
          final response = await _dio.post(refreshPath, data: {
            'refreshToken': refreshToken,
          });
          final newToken = response.data['token'];
          if (newToken != null) {
            await prefs.setString(AppConstants.tokenKey, newToken.toString());
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await _dio.fetch(err.requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          await prefs.remove(AppConstants.tokenKey);
          await prefs.remove(AppConstants.refreshTokenKey);
        }
      }
    }
    handler.next(err);
  }

  ApiException _handleDioException(dynamic error) {
    if (error is ApiException) return error;

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;

      // Extract server error message if available
      String? serverMessage;
      if (responseData is Map) {
        serverMessage = responseData['message']?.toString() ??
            responseData['error']?.toString();
      } else if (responseData is String && responseData.isNotEmpty) {
        serverMessage = responseData;
      }

      if (statusCode == 401) {
        return ApiException(
          statusCode: 401,
          message: serverMessage ?? 'Invalid email or password.',
          data: responseData,
        );
      }

      if (statusCode == 409) {
        return ApiException(
          statusCode: 409,
          message: serverMessage ?? 'An account with this email already exists. Please login.',
          data: responseData,
        );
      }

      if (statusCode == 403) {
        return ApiException(
          statusCode: 403,
          message: serverMessage ?? 'Access denied. You do not have permission.',
          data: responseData,
        );
      }

      if (statusCode == 400) {
        return ApiException(
          statusCode: 400,
          message: serverMessage ?? 'Invalid request. Please check your inputs.',
          data: responseData,
        );
      }

      if (statusCode == 404) {
        return ApiException(
          statusCode: 404,
          message: serverMessage ?? 'The requested resource was not found.',
          data: responseData,
        );
      }

      if (statusCode != null && statusCode >= 500) {
        return ApiException(
          statusCode: statusCode,
          message: 'CarbonWise server error. Please try again later.',
          data: responseData,
        );
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return ApiException(
          statusCode: statusCode,
          message: 'Server is taking too long to respond. Please try again.',
          isTimeout: true,
        );
      }

      if (error.type == DioExceptionType.connectionError) {
        return ApiException(
          statusCode: statusCode,
          message: 'Unable to connect to CarbonWise server. Please check your connection.',
          isNetworkError: true,
        );
      }

      return ApiException(
        statusCode: statusCode,
        message: serverMessage ?? 'Unable to connect to CarbonWise server.',
        isNetworkError: true,
      );
    }

    return ApiException(
      message: error.toString(),
      isNetworkError: true,
    );
  }

  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final targetPath = _resolvePath(path);
      return await _dio.get(targetPath, queryParameters: queryParameters);
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      final targetPath = _resolvePath(path);
      return await _dio.post(targetPath, data: data);
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      final targetPath = _resolvePath(path);
      return await _dio.put(targetPath, data: data);
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  // DELETE request
  Future<Response> delete(String path) async {
    try {
      final targetPath = _resolvePath(path);
      return await _dio.delete(targetPath);
    } catch (e) {
      throw _handleDioException(e);
    }
  }
}

