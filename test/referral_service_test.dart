import 'package:flutter_test/flutter_test.dart';
import 'package:sleeploock/services/referral_service.dart';

void main() {
  late ReferralService service;

  setUp(() {
    service = ReferralService();
  });

  test('extracts creator codes from deep links and query params', () {
    expect(service.extractCreatorCodeFromUri(Uri.parse('https://sleeplock.app/r/creator123')), 'CREATOR123');
    expect(service.extractCreatorCodeFromUri(Uri.parse('https://sleeplock.app/?ref=creator456')), 'CREATOR456');
    expect(service.extractCreatorCodeFromUri(Uri.parse('https://sleeplock.app/?code=creator789')), 'CREATOR789');
  });

  test('buildReferralLink formats a creator link', () {
    expect(service.buildReferralLink('creator123'), 'https://sleeplock.app/r/CREATOR123');
  });
}
