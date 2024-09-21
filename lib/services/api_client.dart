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
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      String? token = await _storageService.read(key: 'token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        print('Bearer $token');
      }
      return handler.next(options);
    }, onResponse: (response, handler) {
      return handler.next(response);
    }, onError: (DioException e, handler) {
      return handler.next(e);
    }));
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
}
