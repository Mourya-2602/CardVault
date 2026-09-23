sealed class BankError implements Exception {
  const BankError({required this.message, this.code, this.traceId});

  final String message;
  final String? code;
  final String? traceId;
}

final class NetworkBankError extends BankError {
  const NetworkBankError({super.message = 'Check your internet connection.'});
}

final class TimeoutBankError extends BankError {
  const TimeoutBankError({
    super.message = 'The request took too long. Try again.',
  });
}

final class UnauthorizedBankError extends BankError {
  const UnauthorizedBankError({super.message = 'Your session has expired.'});
}

final class ForbiddenBankError extends BankError {
  const ForbiddenBankError({super.message = 'You are not allowed to do that.'});
}

final class NotFoundBankError extends BankError {
  const NotFoundBankError({
    super.message = 'We could not find that information.',
  });
}

final class ConflictBankError extends BankError {
  const ConflictBankError({
    super.message = 'That information changed. Refresh and try again.',
  });
}

final class ValidationBankError extends BankError {
  const ValidationBankError({
    super.message = 'Check the information and try again.',
  });
}

final class ServerBankError extends BankError {
  const ServerBankError({
    super.message = 'The service is unavailable. Try again shortly.',
  });
}

final class UnknownBankError extends BankError {
  const UnknownBankError({super.message = 'Something went wrong. Try again.'});
}
