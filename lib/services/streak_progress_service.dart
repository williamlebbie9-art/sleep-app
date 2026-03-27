import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakProgressService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const List<MapEntry<int, String>> _badgeMilestones = [
    MapEntry(15, 'Bronze Badge'),
    MapEntry(30, 'Silver Badge'),
    MapEntry(45, 'Gold Badge'),
    MapEntry(60, 'Diamond Badge'),
    MapEntry(75, 'Legendary Badge'),
  ];

  static const String _noBadge = 'None';

  static String rankForStreak(int streak) {
    if (streak >= 75) return 'Legend';
    if (streak >= 60) return 'Master';
    if (streak >= 45) return 'Champion';
    if (streak >= 30) return 'Warrior';
    if (streak >= 15) return 'Disciple';
    return 'Beginner';
  }

  static String badgeForStreak(int streak) {
    String badge = _noBadge;
    for (final milestone in _badgeMilestones) {
      if (streak >= milestone.key) {
        badge = milestone.value;
      }
    }
    return badge;
  }

  static List<String> badgesEarnedForStreak(int streak) {
    return _badgeMilestones
        .where((milestone) => streak >= milestone.key)
        .map((milestone) => milestone.value)
        .toList(growable: false);
  }

  static Future<void> syncCurrentUserProgress({required int streak}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();
    final data = doc.data() ?? <String, dynamic>{};

    final previousHighest = _toInt(data['highestStreak']);
    final highestStreak = streak > previousHighest ? streak : previousHighest;

    final existingBadges = ((data['badges'] as List<dynamic>?) ?? const [])
        .whereType<String>()
        .toSet();
    existingBadges.addAll(badgesEarnedForStreak(streak));

    await userRef.set({
      'currentStreak': streak,
      'highestStreak': highestStreak,
      'rank': rankForStreak(streak),
      'badge': badgeForStreak(streak),
      'badges': existingBadges.toList(),
      'updatedAt': FieldValue.serverTimestamp(),
      'streakUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
