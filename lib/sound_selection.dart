import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/background_audio_service.dart';
import 'main.dart';
import 'screens/story_list_screen.dart';

class SoundSelectionScreen extends StatefulWidget {
  const SoundSelectionScreen({super.key});

  @override
  State<SoundSelectionScreen> createState() => _SoundSelectionScreenState();
}

class _SoundSelectionScreenState extends State<SoundSelectionScreen> {
  final BackgroundAudioService _audioService = BackgroundAudioService.instance;

  final List<Map<String, String>> sounds = [
    {"name": "Rain", "file": "sounds/rain.mp3"},
    {"name": "Ocean", "file": "sounds/ocean.mp3"},
    {"name": "Piano", "file": "sounds/piano.mp3"},
    {"name": "Forest", "file": "sounds/forest.mp3"},
  ];

  String? _savedSoundPath;

  @override
  void initState() {
    super.initState();
    _loadSavedSound();
  }

  Future<void> _loadSavedSound() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _savedSoundPath = prefs.getString('lastSound');
    });
  }

  Future<void> _startSleepMode() async {
    final prefs = await SharedPreferences.getInstance();
    final soundPath = prefs.getString('lastSound') ?? 'sounds/rain.mp3';
    final minutes = prefs.getInt('sleepDurationMinutes') ?? 30;

    // Avoid layering preview audio with sleep mode audio.
    await _audioService.stop();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SleepModeScreen(soundPath: soundPath, minutes: minutes),
      ),
    );
  }

  Future<void> _togglePreview(String soundPath) async {
    final isCurrentSound = _audioService.isCurrent(
      soundPath,
      BackgroundAudioType.sound,
    );

    if (isCurrentSound && _audioService.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.playSound(soundPath);
    }

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Sleep Sound')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: sounds.length,
              itemBuilder: (context, index) {
                final soundPath = sounds[index]['file']!;
                final isSelected = soundPath == _savedSoundPath;
                final isPreviewPlaying =
                    _audioService.isCurrent(
                      soundPath,
                      BackgroundAudioType.sound,
                    ) &&
                    _audioService.isPlaying;
                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(sounds[index]['name']!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _togglePreview(soundPath),
                        icon: Icon(
                          isPreviewPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('lastSound', soundPath);

                    if (!mounted) return;

                    setState(() {
                      _savedSoundPath = soundPath;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${sounds[index]['name']} selected'),
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
                  'Duration is now managed in Sleep Timer.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _startSleepMode,
                  child: const Text('Start Sleep Mode'),
                ),
                const SizedBox(height: 12),
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
