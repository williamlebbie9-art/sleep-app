import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class SleepTimerScreen extends StatefulWidget {
  const SleepTimerScreen({super.key});

  @override
  State<SleepTimerScreen> createState() => _SleepTimerScreenState();
}

class _SleepTimerScreenState extends State<SleepTimerScreen> {
  final List<int> _durations = [30, 60, 120, 180, 240, 360, 480];
  int _selectedMinutes = 30;

  @override
  void initState() {
    super.initState();
    _loadSavedDuration();
  }

  Future<void> _loadSavedDuration() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _selectedMinutes = prefs.getInt('sleepDurationMinutes') ?? 30;
    });
  }

  Future<void> _saveDuration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sleepDurationMinutes', _selectedMinutes);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sleep timer saved.')));
  }

  Future<void> _startSleepMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sleepDurationMinutes', _selectedMinutes);

    final soundPath = prefs.getString('lastSound') ?? 'sounds/rain.mp3';

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SleepModeScreen(soundPath: soundPath, minutes: _selectedMinutes),
      ),
    );
  }

  String _durationLabel(int minute) {
    switch (minute) {
      case 30:
        return '30m';
      case 60:
        return '1hr';
      case 120:
        return '2hr';
      case 180:
        return '3hr';
      case 240:
        return '4hr';
      case 360:
        return '6hr';
      case 480:
        return '8hr';
      default:
        return '$minute';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Timer')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Sleep Duration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _durations.map((minute) {
                final isSelected = minute == _selectedMinutes;
                return ChoiceChip(
                  label: Text(_durationLabel(minute)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedMinutes = minute;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveDuration,
              child: const Text('Save Timer'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _startSleepMode,
              child: const Text('Start Sleep Mode'),
            ),
          ],
        ),
      ),
    );
  }
}
