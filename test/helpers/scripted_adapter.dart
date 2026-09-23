import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this._handler);

  final Future<ResponseSpec> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final spec = await _handler(options);
    if (spec.delay != null) {
      await Future<void>.delayed(spec.delay!);
    }
    if (spec.connectionError) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'connection',
      );
    }
    if (spec.timeout) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.receiveTimeout,
      );
    }
    return ResponseBody.fromString(
      spec.body is String ? spec.body as String : jsonEncode(spec.body),
      spec.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class ResponseSpec {
  const ResponseSpec({
    required this.statusCode,
    required this.body,
    this.timeout = false,
    this.connectionError = false,
    this.delay,
  });

  final int statusCode;
  final Object body;
  final bool timeout;
  final bool connectionError;
  final Duration? delay;
}
