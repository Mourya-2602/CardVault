import 'package:dio/dio.dart';

import '../errors/bank_error.dart';

BankError mapDioError(Object error) {
  if (error is BankError) {
    return error;
  }
  if (error is! DioException) {
    return const UnknownBankError();
  }

  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => const TimeoutBankError(),
    DioExceptionType.connectionError => const NetworkBankError(),
    _ => _mapResponse(error),
  };
}

BankError _mapResponse(DioException error) {
  final parsed = _parsedApiError(error.response?.data);
  final message = _safeMessage(parsed.message);
  final statusCode = error.response?.statusCode;

  return switch (statusCode) {
    400 || 422 => ValidationBankError(
      message: message ?? 'Check the information and try again.',
      code: parsed.code,
      traceId: parsed.traceId,
    ),
    401 => UnauthorizedBankError(
      message: message ?? 'Your session has expired.',
      code: parsed.code,
      traceId: parsed.traceId,
    ),
    403 => ForbiddenBankError(
      message: message ?? 'You are not allowed to do that.',
      code: parsed.code,
      traceId: parsed.traceId,
    ),
    404 => NotFoundBankError(
      message: message ?? 'We could not find that information.',
      code: parsed.code,
      traceId: parsed.traceId,
    ),
    409 => ConflictBankError(
      message: message ?? 'That information changed. Refresh and try again.',
      code: parsed.code,
      traceId: parsed.traceId,
    ),
    final status? when status >= 500 => ServerBankError(
      message: message ?? 'The service is unavailable. Try again shortly.',
      code: parsed.code,
      traceId: parsed.traceId,
    ),
    _ => UnknownBankError(
      message: message ?? 'Something went wrong. Try again.',
      code: parsed.code,
      traceId: parsed.traceId,
    ),
  };
}

({String? message, String? code, String? traceId}) _parsedApiError(
  Object? data,
) {
  if (data is! Map) {
    return (message: null, code: null, traceId: null);
  }
  final nested = data['error'];
  if (nested is! Map) {
    return (message: null, code: null, traceId: null);
  }
  return (
    message: nested['message'] as String?,
    code: nested['code'] as String?,
    traceId: nested['traceId'] as String?,
  );
}

String? _safeMessage(String? message) {
  if (message == null || message.trim().isEmpty) return null;
  final lower = message.toLowerCase();
  if (lower.contains('<html') ||
      lower.contains('exception') ||
      lower.contains('stack')) {
    return null;
  }
  return message;
}
