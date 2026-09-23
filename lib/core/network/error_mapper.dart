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
    _ => _mapStatus(error.response?.statusCode),
  };
}

BankError _mapStatus(int? statusCode) {
  return switch (statusCode) {
    401 => const UnauthorizedBankError(),
    403 => const ForbiddenBankError(),
    404 => const NotFoundBankError(),
    409 => const ConflictBankError(),
    422 => const ValidationBankError(),
    final statusCode? when statusCode >= 500 => const ServerBankError(),
    _ => const UnknownBankError(),
  };
}
