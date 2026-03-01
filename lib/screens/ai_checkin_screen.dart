import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'lock_active_screen.dart';

class AICheckInScreen extends StatefulWidget {
  const AICheckInScreen({super.key});

  @override
  State<AICheckInScreen> createState() => _AICheckInScreenState();
}

class _AICheckInScreenState extends State<AICheckInScreen> {
  File? _checkInPhoto;
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final today = DateTime.now();
      final fileName = 'checkin_${today.year}_${today.month}_${today.day}.jpg';
      final saved = await File(picked.path).copy('${appDir.path}/$fileName');
      setState(() => _checkInPhoto = saved);
    }
  }

  TimeOfDay? sleepTime;
  double tiredness = 3;

  String get aiMessage {
    if (tiredness >= 4) {
      return "You sound exhausted. Let’s protect tonight and recover.";
    } else if (tiredness <= 2) {
      return "Even if you feel okay now, tomorrow will thank you.";
    } else {
      return "A calm night leads to a stronger morning.";
    }
  }

  Future<void> saveCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (sleepTime != null) {
      prefs.setInt('sleepHour', sleepTime!.hour);
      prefs.setInt('sleepMinute', sleepTime!.minute);
    }
    prefs.setDouble('tiredness', tiredness);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Night Check-In")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "When do you want to sleep?",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: Text(
                sleepTime == null
                    ? "Pick sleep time"
                    : sleepTime!.format(context),
              ),
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() => sleepTime = picked);
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Check-In Photo'),
                  onPressed: _pickPhoto,
                ),
                const SizedBox(width: 12),
                if (_checkInPhoto != null)
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.file(_checkInPhoto!, fit: BoxFit.cover),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "How tired do you feel?",
              style: TextStyle(fontSize: 18),
            ),
            Slider(
              value: tiredness,
              min: 1,
              max: 5,
              divisions: 4,
              label: tiredness.round().toString(),
              onChanged: (v) => setState(() => tiredness = v),
            ),
            const SizedBox(height: 30),
            Text(
              aiMessage,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const Spacer(),
            ElevatedButton(
              child: const Text("Continue"),
              onPressed: () async {
                if (_checkInPhoto == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please take a check-in photo!'),
                    ),
                  );
                  return;
                }
                await saveCheckIn();
                // Save photo path for today
                final prefs = await SharedPreferences.getInstance();
                final today = DateTime.now();
                final key = 'photo_${today.year}_${today.month}_${today.day}';
                prefs.setString(key, _checkInPhoto!.path);
                // Auto-start lock after check-in
                final unlockTime = DateTime.now().add(const Duration(hours: 8));
                final streak = 0; // Or fetch from prefs if needed
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LockActiveScreen(
                      unlockTime: unlockTime,
                      streak: streak,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
