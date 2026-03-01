import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/sleep_ai_service.dart';

class BedtimeSettingsScreen extends StatefulWidget {
  const BedtimeSettingsScreen({super.key});

  @override
  State<BedtimeSettingsScreen> createState() => _BedtimeSettingsScreenState();
}

class _BedtimeSettingsScreenState extends State<BedtimeSettingsScreen> {
  bool _bedtimeEnabled = false;
  bool _aiEnabled = false;
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bedtimeEnabled = prefs.getBool('bedtime_enabled') ?? false;
      _aiEnabled = prefs.getBool('ai_recommendations_enabled') ?? false;
      final hour = prefs.getInt('bedtime_hour') ?? 22;
      final minute = prefs.getInt('bedtime_minute') ?? 0;
      _bedtime = TimeOfDay(hour: hour, minute: minute);
      _loading = false;
    });
  }

  Future<void> _toggleBedtime(bool enabled) async {
    setState(() => _bedtimeEnabled = enabled);

    if (enabled) {
      await NotificationService().requestPermissions();
      await NotificationService().scheduleBedtimeReminder(
        _bedtime.hour,
        _bedtime.minute,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bedtime reminder scheduled!')),
      );
    } else {
      await NotificationService().cancelBedtimeReminder();
    }
  }

  Future<void> _toggleAI(bool enabled) async {
    setState(() => _aiEnabled = enabled);
    await SleepAIService.enableAI(enabled);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? 'AI will learn your sleep patterns'
              : 'AI recommendations disabled',
        ),
      ),
    );
  }

  Future<void> _selectBedtime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _bedtime,
      builder: (context, child) {
        return Theme(data: ThemeData.dark(), child: child!);
      },
    );

    if (picked != null) {
      setState(() => _bedtime = picked);
      if (_bedtimeEnabled) {
        await NotificationService().scheduleBedtimeReminder(
          picked.hour,
          picked.minute,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bedtime updated!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bedtime Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.bedtime, size: 64, color: Colors.deepPurple),
          const SizedBox(height: 24),
          const Text(
            'Sleep Reminders',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Get notified when it\'s time to activate Sleep Lock',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Card(
            child: SwitchListTile(
              title: const Text('Daily Bedtime Reminder'),
              subtitle: Text('Remind me at ${_bedtime.format(context)}'),
              value: _bedtimeEnabled,
              onChanged: _toggleBedtime,
              secondary: const Icon(Icons.notification_important),
            ),
          ),
          if (_bedtimeEnabled) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('Set Bedtime'),
                subtitle: Text(_bedtime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: _selectBedtime,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Card(
            child: SwitchListTile(
              title: const Text('AI Sleep Recommendations'),
              subtitle: const Text(
                'Learn from your patterns and suggest optimal sleep times',
              ),
              value: _aiEnabled,
              onChanged: _toggleAI,
              secondary: const Icon(Icons.psychology),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How it works',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  '• Set a daily bedtime reminder\n'
                  '• Enable AI to learn your sleep patterns\n'
                  '• Get smart suggestions based on your streak\n'
                  '• Tap notifications to activate Sleep Lock instantly',
                  style: TextStyle(color: Colors.white70, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
