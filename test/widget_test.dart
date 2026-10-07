import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sleeploock/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: '1:1234567890:ios:testapp',
        messagingSenderId: '1234567890',
        projectId: 'sleeploock-test',
      ),
    );
  });

  testWidgets('app starts without crashing on initial route', (tester) async {
    await tester.pumpWidget(const SleepLockApp());
    await tester.pumpAndSettle();

    expect(find.byType(SleepLockApp), findsOneWidget);
  });
}
