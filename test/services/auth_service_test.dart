import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/services/auth_service.dart';

void main() {
  group('AuthService.validateUsername', () {
    // Like [Theory] with [InlineData] in xUnit
    const validNames = ['kalle', 'Kalle_99', 'abc'];
    for (final name in validNames) {
      test('accepts "$name"', () {
        expect(AuthService.validateUsername(name), isNull);
      });
    }

    final invalidNames = <String?>[
      null,
      '',
      'ab',              // too short
      'a' * 21,          // too long
      'kålle',           // å/ä/ö are not valid in an email address
      'kalle anka',      // spaces are not allowed
    ];
    for (final name in invalidNames) {
      test('rejects "$name"', () {
        expect(AuthService.validateUsername(name), isNotNull);
      });
    }
  });
}