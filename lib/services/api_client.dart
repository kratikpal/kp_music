import 'package:dio/dio.dart';
import 'package:kp_music/services/api_url.dart';
import 'package:kp_music/services/secure_storage_service.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorageService _storageService = SecureStorageService();

  ApiClient({String? baseUrl})
      : _dio = Dio(BaseOptions(
            baseUrl: baseUrl ?? ApiUrls.baseUrl,
            connectTimeout: const Duration(seconds: 120),
            receiveTimeout: const Duration(seconds: 120))) {
    _dio.interceptors
        .add(LogInterceptor(responseBody: true, requestBody: true));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storageService.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        // Check if the error is related to an expired token
        if (e.response?.statusCode == 401) {
          // Attempt to refresh the token
          final refreshTokenResponse = await _refreshToken();
          if (refreshTokenResponse != null) {
            // If refresh is successful, retry the original request
            String? newToken = await _storageService.read(key: 'token');
            if (newToken != null) {
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              // Retry the request with the new token
              final retryResponse = await _dio.fetch(e.requestOptions);
              return handler.resolve(retryResponse);
            }
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {Map<String, dynamic>? data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {Map<String, dynamic>? data}) {
    return _dio.delete(path, data: data);
  }

  Future<Response?> _refreshToken() async {
    String? refreshToken = await _storageService.read(key: 'refresh_token');

    if (refreshToken == null) {
      return null;
    }

    try {
      // Make a request to refresh the token
      final response = await _dio
          .post(ApiUrls.refreshToken, data: {'refreshToken': refreshToken});

      // Save the new token and return the response
      if (response.statusCode == 200) {
        print('Token refreshed successfully');
        await _storageService.write(
            key: 'token', value: response.data['token']);
        await _storageService.write(
            key: 'refreshToken', value: response.data['refreshToken']);
        return response;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }

    return null;
  }
}
