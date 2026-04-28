import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferralService {
  static const _pendingReferralCodeKey = 'pending_referral_code';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String friendlyErrorMessage(
    Object error, {
    String action = 'complete this action',
  }) {
    if (error is FirebaseException) {
      final message = (error.message ?? '').toLowerCase();

      if (error.code == 'permission-denied') {
        return 'Firebase rules are blocking the Creator Program. Deploy the Firestore rules and try again.';
      }

      if (error.code == 'failed-precondition' && message.contains('index')) {
        return 'Firebase still needs the Creator Program indexes. Deploy the Firestore indexes and reopen this page.';
      }

      if (error.code == 'unavailable') {
        return 'Firebase is temporarily unavailable. Please try again in a moment.';
      }
    }

    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (raw.isNotEmpty && raw != 'Exception') {
      return raw;
    }

    return 'Could not $action right now. Please try again.';
  }

  Future<Map<String, dynamic>?> getMyCreatorProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection('creators')
        .doc(user.uid)
        .get();
    if (!snapshot.exists) return null;
    return snapshot.data();
  }

  Stream<Map<String, dynamic>?> streamMyCreatorProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<Map<String, dynamic>?>.value(null);
    }

    return _firestore.collection('creators').doc(user.uid).snapshots().map((
      doc,
    ) {
      if (!doc.exists) {
        return null;
      }
      return doc.data();
    });
  }

  Stream<List<Map<String, dynamic>>> streamMyRecentCommissions({
    int limit = 20,
  }) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<List<Map<String, dynamic>>>.value(const []);
    }

    return _firestore
        .collection('commissions')
        .where('creatorUid', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (query) =>
              query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> streamMyPayoutRequests({int limit = 20}) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream<List<Map<String, dynamic>>>.value(const []);
    }

    return _firestore
        .collection('payout_requests')
        .where('creatorUid', isEqualTo: user.uid)
        .orderBy('requestedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (query) =>
              query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
        );
  }

  Future<bool> creatorCodeExists(String code) async {
    final normalized = _normalizeCode(code);
    if (normalized.isEmpty) return false;
    final codeDoc = await _firestore
        .collection('creator_codes')
        .doc(normalized)
        .get();
    return codeDoc.exists;
  }

  String buildReferralLink(String code) {
    final normalized = _normalizeCode(code);
    return 'https://sleeplock.app/r/$normalized';
  }

  Future<String> ensureMyCreatorCode() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('You need to sign in first.');
      }

      final existingProfile = await _firestore
          .collection('creators')
          .doc(user.uid)
          .get();
      if (existingProfile.exists) {
        final existingCode = existingProfile.data()?['code'] as String?;
        if (existingCode != null && existingCode.trim().isNotEmpty) {
          return existingCode;
        }
      }

      final seed = (user.displayName ?? user.email ?? user.uid)
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
          .toUpperCase();
      final base = seed.isEmpty ? 'CREATOR' : seed;

      for (int attempt = 0; attempt < 20; attempt++) {
        final suffix = user.uid.substring(0, 4 + (attempt % 4)).toUpperCase();
        final head = base.substring(0, base.length > 8 ? 8 : base.length);
        final candidate = _normalizeCode('$head$suffix');

        final codeRef = _firestore.collection('creator_codes').doc(candidate);
        final creatorRef = _firestore.collection('creators').doc(user.uid);

        try {
          await _firestore.runTransaction((tx) async {
            final codeSnap = await tx.get(codeRef);
            if (codeSnap.exists) {
              throw StateError('collision');
            }

            tx.set(codeRef, {
              'creatorUid': user.uid,
              'code': candidate,
              'createdAt': FieldValue.serverTimestamp(),
            });

            tx.set(creatorRef, {
              'uid': user.uid,
              'code': candidate,
              'link': buildReferralLink(candidate),
              'status': 'active',
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          });

          return candidate;
        } on StateError {
          continue;
        }
      }

      throw Exception('Could not generate a unique creator code. Try again.');
    } on FirebaseException catch (error) {
      throw Exception(
        friendlyErrorMessage(error, action: 'save creator data in Firebase'),
      );
    }
  }

  Future<String?> resolveCreatorUidByCode(String code) async {
    final normalized = _normalizeCode(code);
    if (normalized.isEmpty) return null;

    final codeDoc = await _firestore
        .collection('creator_codes')
        .doc(normalized)
        .get();
    if (!codeDoc.exists) return null;
    return codeDoc.data()?['creatorUid'] as String?;
  }

  Future<void> setPendingReferralCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _normalizeCode(code);
    if (normalized.isEmpty) return;
    await prefs.setString(_pendingReferralCodeKey, normalized);
  }

  Future<String?> getPendingReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_pendingReferralCodeKey);
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return _normalizeCode(value);
  }

  Future<void> clearPendingReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingReferralCodeKey);
  }

  String? extractCreatorCodeFromUri(Uri uri) {
    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'r') {
      final fromPath = _normalizeCode(uri.pathSegments[1]);
      if (fromPath.isNotEmpty) {
        return fromPath;
      }
    }

    final fromQuery = uri.queryParameters['ref'] ?? uri.queryParameters['code'];
    if (fromQuery == null) {
      return null;
    }

    final normalized = _normalizeCode(fromQuery);
    return normalized.isEmpty ? null : normalized;
  }

  Future<bool> captureReferralFromUri(Uri uri) async {
    final code = extractCreatorCodeFromUri(uri);
    if (code == null) {
      return false;
    }
    await setPendingReferralCode(code);
    return true;
  }

  Future<void> createPayoutRequest({
    required double amountUsd,
    required String creatorCode,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('You must be signed in to request payout.');
      }

      if (amountUsd <= 0) {
        throw Exception('No available balance to request.');
      }

      final pendingQuery = await _firestore
          .collection('payout_requests')
          .where('creatorUid', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();
      if (pendingQuery.docs.isNotEmpty) {
        throw Exception('You already have a pending payout request.');
      }

      final requestRef = _firestore.collection('payout_requests').doc();
      await requestRef.set({
        'id': requestRef.id,
        'creatorUid': user.uid,
        'creatorCode': creatorCode,
        'amountUsd': double.parse(amountUsd.toStringAsFixed(2)),
        'currency': 'USD',
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'source': 'creator_dashboard',
      });
    } on FirebaseException catch (error) {
      throw Exception(
        friendlyErrorMessage(error, action: 'create a payout request'),
      );
    }
  }

  String _normalizeCode(String value) {
    return value.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }
}
