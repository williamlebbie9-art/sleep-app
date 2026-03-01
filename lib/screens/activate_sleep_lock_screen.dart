import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivateSleepLockResult {
  final DateTime unlockTime;
  final bool playSound;
  final String? soundPath;

  const ActivateSleepLockResult({
    required this.unlockTime,
    required this.playSound,
    required this.soundPath,
  });
}

class ActivateSleepLockScreen extends StatefulWidget {
  const ActivateSleepLockScreen({super.key});

  @override
  State<ActivateSleepLockScreen> createState() =>
      _ActivateSleepLockScreenState();
}

class _ActivateSleepLockScreenState extends State<ActivateSleepLockScreen> {
  static const MethodChannel _permissionChannel = MethodChannel(
    'sleeploock/lock_permissions',
  );

  final List<Map<String, String>> sounds = [
    {'name': 'Rain', 'file': 'sounds/rain.mp3'},
    {'name': 'Ocean', 'file': 'sounds/ocean.mp3'},
    {'name': 'Piano', 'file': 'sounds/piano.mp3'},
    {'name': 'Forest', 'file': 'sounds/forest.mp3'},
  ];

  final List<int> durations = [180, 240, 360, 480];
  int selectedMinutes = 480;
  bool useExactEndTime = false;
  DateTime selectedEndTime = DateTime.now().add(const Duration(hours: 8));
  bool playSound = true;
  String? selectedSoundPath;
  bool hasUsageAccessPermission = false;
  bool hasOverlayPermission = false;

  @override
  void initState() {
    super.initState();
    _refreshPermissionState();
  }

  DateTime get _calculatedUnlockTime {
    if (useExactEndTime) {
      return selectedEndTime;
    }
    return DateTime.now().add(Duration(minutes: selectedMinutes));
  }

  Future<void> _refreshPermissionState() async {
    if (!Platform.isAndroid) return;
    try {
      final usage = await _permissionChannel.invokeMethod<bool>(
        'checkUsageAccessPermission',
      );
      final overlay = await _permissionChannel.invokeMethod<bool>(
        'checkOverlayPermission',
      );
      if (!mounted) return;
      setState(() {
        hasUsageAccessPermission = usage ?? false;
        hasOverlayPermission = overlay ?? false;
      });
    } catch (_) {}
  }

  Future<void> _openUsageAccessSettings() async {
    try {
      await _permissionChannel.invokeMethod('openUsageAccessSettings');
      await Future.delayed(const Duration(milliseconds: 600));
      await _refreshPermissionState();
    } catch (_) {}
  }

  Future<void> _openOverlaySettings() async {
    try {
      await _permissionChannel.invokeMethod('openOverlaySettings');
      await Future.delayed(const Duration(milliseconds: 600));
      await _refreshPermissionState();
    } catch (_) {}
  }

  Future<void> _openIosAppSettings() async {
    final uri = Uri.parse('app-settings:');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _pickExactEndTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedEndTime,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedEndTime),
    );
    if (pickedTime == null || !mounted) return;

    final candidate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (candidate.isBefore(now.add(const Duration(minutes: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a future end time.')),
      );
      return;
    }

    setState(() {
      selectedEndTime = candidate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activate Sleep Lock')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPermissionState,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (Platform.isAndroid) ...[
                const Text(
                  'Required Permissions for App Blocking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    title: const Text('Usage Access Permission'),
                    subtitle: Text(
                      hasUsageAccessPermission
                          ? 'Granted'
                          : 'Needed to monitor and enforce lock behavior.',
                    ),
                    trailing: ElevatedButton(
                      onPressed: _openUsageAccessSettings,
                      child: Text(hasUsageAccessPermission ? 'Open' : 'Grant'),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Display Over Other Apps'),
                    subtitle: Text(
                      hasOverlayPermission
                          ? 'Granted'
                          : 'Recommended for stronger blocking screen.',
                    ),
                    trailing: ElevatedButton(
                      onPressed: _openOverlaySettings,
                      child: Text(hasOverlayPermission ? 'Open' : 'Grant'),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ] else if (Platform.isIOS) ...[
                const Text(
                  'iOS Sleep Lock Setup',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Card(
                  child: ListTile(
                    title: Text('How lock works on iPhone'),
                    subtitle: Text(
                      'SleepLock will keep your session active until your timer or end-time completes. '
                      'For system-wide app restrictions, use iOS Screen Time settings.',
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('Open iOS App Settings'),
                    subtitle: const Text(
                      'Allow notifications and background behavior for best reliability.',
                    ),
                    trailing: ElevatedButton(
                      onPressed: _openIosAppSettings,
                      child: const Text('Open'),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              SwitchListTile(
                title: const Text('Play sound while sleeping'),
                value: playSound,
                onChanged: (value) {
                  setState(() {
                    playSound = value;
                    if (!playSound) selectedSoundPath = null;
                  });
                },
              ),
              if (playSound)
                ...sounds.map((soundItem) {
                  final path = soundItem['file']!;
                  final isSelected = selectedSoundPath == path;
                  return ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(soundItem['name']!),
                    trailing: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                    ),
                    onTap: () {
                      setState(() {
                        selectedSoundPath = path;
                      });
                    },
                  );
                }),
              const SizedBox(height: 12),
              const Text(
                'Lock Schedule',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('Lock for duration'),
                    selected: !useExactEndTime,
                    onSelected: (_) {
                      setState(() {
                        useExactEndTime = false;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Unlock at exact date & time'),
                    selected: useExactEndTime,
                    onSelected: (_) {
                      setState(() {
                        useExactEndTime = true;
                      });
                    },
                  ),
                ],
              ),
              if (!useExactEndTime)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: durations.map((minute) {
                    final isSelected = minute == selectedMinutes;
                    final label = '${minute ~/ 60} Hours';
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedMinutes = minute;
                        });
                      },
                    );
                  }).toList(),
                ),
              if (useExactEndTime)
                ListTile(
                  title: const Text('Selected End Time'),
                  subtitle: Text(selectedEndTime.toLocal().toString()),
                  trailing: ElevatedButton(
                    onPressed: _pickExactEndTime,
                    child: const Text('Change'),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Lock ends automatically at: ${_calculatedUnlockTime.toLocal()}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (Platform.isAndroid && !hasUsageAccessPermission) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Grant Usage Access permission first in Settings.',
                        ),
                      ),
                    );
                    return;
                  }
                  if (playSound && selectedSoundPath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pick a sound or disable sound.'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(
                    context,
                    ActivateSleepLockResult(
                      unlockTime: _calculatedUnlockTime,
                      playSound: playSound,
                      soundPath: selectedSoundPath,
                    ),
                  );
                },
                child: const Text('Activate Sleep Lock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
