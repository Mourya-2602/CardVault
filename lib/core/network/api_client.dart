import 'package:dio/dio.dart';

import '../errors/bank_error.dart';
import '../security/secure_session_store.dart';
import 'api_config.dart';
import 'error_mapper.dart';

class ApiClient {
  ApiClient({required ApiConfig config, required this.sessionStore, Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: config.baseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              sendTimeout: const Duration(seconds: 8),
            ),
          ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await sessionStore.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await sessionStore.clear();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
  final SessionStore sessionStore;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? headers,
  }) {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    String? idempotencyKey,
    Map<String, Object?>? headers,
  }) {
    return dio.post<T>(
      path,
      data: data,
      options: Options(
        headers: {
          ...?headers,
          if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
        },
      ),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, Object?>? headers,
  }) {
    return dio.patch<T>(
      path,
      data: data,
      options: Options(headers: headers),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, Object?>? headers,
  }) {
    return dio.put<T>(
      path,
      data: data,
      options: Options(headers: headers),
    );
  }

  BankError mapError(Object error) => mapDioError(error);
}

Future<T> runApi<T>(ApiClient client, Future<T> Function() action) async {
  try {
    return await action();
  } catch (error) {
    throw client.mapError(error);
  }
}
