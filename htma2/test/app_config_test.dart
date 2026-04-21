import 'package:flutter_test/flutter_test.dart';
import 'package:htmarevived/core/config/app_config.dart';

void main() {
  test('accepts firebaseio endpoint URL', () {
    final url = AppConfig.validateFirebaseDatabaseUrl(
      'https://shopsfirebase-a92b0-default-rtdb.firebaseio.com/',
    );
    expect(url, 'https://shopsfirebase-a92b0-default-rtdb.firebaseio.com/');
  });

  test('accepts firebasedatabase.app endpoint URL', () {
    final url = AppConfig.validateFirebaseDatabaseUrl(
      'https://shopsfirebase-a92b0-default-rtdb.firebasedatabase.app/',
    );
    expect(url, 'https://shopsfirebase-a92b0-default-rtdb.firebasedatabase.app/');
  });

  test('rejects firebase console URL', () {
    expect(
      () => AppConfig.validateFirebaseDatabaseUrl(
        'https://console.firebase.google.com/project/shopsfirebase-a92b0/database',
      ),
      throwsA(isA<AppConfigException>()),
    );
  });
}
