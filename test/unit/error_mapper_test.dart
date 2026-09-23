import 'package:cardvault/core/errors/bank_error.dart';
import 'package:cardvault/core/network/error_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('does not leak HTML or stack traces', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/cards'),
      response: Response(
        requestOptions: RequestOptions(path: '/cards'),
        statusCode: 500,
        data: '<html>Exception stack</html>',
      ),
    );

    final mapped = mapDioError(error);
    expect(mapped, isA<ServerBankError>());
    expect(mapped.message.contains('html'), isFalse);
    expect(mapped.message.contains('Exception'), isFalse);
  });
}
