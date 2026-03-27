import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('highestStreak', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load leaderboard.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No users yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final username = _usernameFromData(data);
              final currentStreak = _toInt(data['currentStreak']);
              final rank = (data['rank'] as String?) ?? 'Beginner';
              final badge = (data['badge'] as String?) ?? 'None';
              final highestStreak = _toInt(data['highestStreak']);

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF232038),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF7C6CFF),
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    username,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Streak: $currentStreak | Rank: $rank | Badge: $badge',
                  ),
                  trailing: Text(
                    'Best $highestStreak',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _usernameFromData(Map<String, dynamic> data) {
    final username = (data['username'] as String?)?.trim();
    if (username != null && username.isNotEmpty) {
      return username;
    }
    final displayName = (data['displayName'] as String?)?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final email = (data['email'] as String?)?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'Anonymous';
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
