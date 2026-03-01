import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'screens/story_list_screen.dart';

class SoundSelectionScreen extends StatefulWidget {
  const SoundSelectionScreen({super.key});

  @override
  State<SoundSelectionScreen> createState() => _SoundSelectionScreenState();
}

class _SoundSelectionScreenState extends State<SoundSelectionScreen> {
  final List<Map<String, String>> sounds = [
    {"name": "Rain", "file": "sounds/rain.mp3"},
    {"name": "Ocean", "file": "sounds/ocean.mp3"},
    {"name": "Piano", "file": "sounds/piano.mp3"},
    {"name": "Forest", "file": "sounds/forest.mp3"},
  ];

  final List<int> durations = [30, 60, 120, 180, 240, 360, 480];
  int selectedMinutes = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose a Sleep Sound")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: sounds.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.music_note),
                  title: Text(sounds[index]["name"]!),
                  onTap: () async {
                    // Save selected sound
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('lastSound', sounds[index]["file"]!);

                    if (!mounted) return;

                    // Navigate to Sleep Mode
                    Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (_) => SleepModeScreen(
                          soundPath: sounds[index]["file"]!,
                          minutes: selectedMinutes,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  'Select Duration (minutes)',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: durations.map((minute) {
                    final isSelected = minute == selectedMinutes;
                    String label;
                    switch (minute) {
                      case 30:
                        label = "30m";
                        break;
                      case 60:
                        label = "1hr";
                        break;
                      case 120:
                        label = "2hr";
                        break;
                      case 180:
                        label = "3hr";
                        break;
                      case 240:
                        label = "4hr";
                        break;
                      case 360:
                        label = "6hr";
                        break;
                      case 480:
                        label = "8hr";
                        break;
                      default:
                        label = "$minute";
                    }
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedMinutes = minute;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StoryListScreen()),
                    );
                  },
                  child: const Text('Browse Stories'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
