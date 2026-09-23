import 'package:dio/dio.dart';

import '../errors/bank_error.dart';
import '../security/secure_session_store.dart';
import 'api_config.dart';
import 'error_mapper.dart';

class ApiClient {
  ApiClient({required ApiConfig config, required this._sessionStore, Dio? dio})
    : dio = dio ?? Dio(BaseOptions(baseUrl: config.baseUrl)) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionStore.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _sessionStore.clear();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
  final SessionStore _sessionStore;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {Object? data}) {
    return dio.post<T>(path, data: data);
  }

  Future<Response<T>> patch<T>(String path, {Object? data}) {
    return dio.patch<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {Object? data}) {
    return dio.put<T>(path, data: data);
  }

  BankError mapError(Object error) => mapDioError(error);
}
