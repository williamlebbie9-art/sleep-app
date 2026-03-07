import 'package:flutter/material.dart';

import '../models/story.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/background_audio_service.dart';

class StoryReaderScreen extends StatefulWidget {
  final Story sleepstory;

  const StoryReaderScreen({super.key, required this.sleepstory});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  final BackgroundAudioService _audioService = BackgroundAudioService.instance;
  late bool _audioAvailable;

  @override
  void initState() {
    super.initState();
    _audioAvailable = widget.sleepstory.audioPath.trim().isNotEmpty;

    // Save last played story to SharedPreferences
    _saveLastStory();
  }

  Future<void> _saveLastStory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastStoryTitle', widget.sleepstory.title);
    await prefs.setString('lastStoryContent', widget.sleepstory.content);
    await prefs.setString('lastStoryAudio', widget.sleepstory.audioPath);
    await prefs.setBool('lastStoryPremium', widget.sleepstory.premium);
  }

  Future<void> _play() async {
    if (!_audioAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Audio coming soon.')));
      return;
    }
    try {
      await _audioService.playStory(widget.sleepstory.audioPath);
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio file not found or is empty.')),
      );
    }
  }

  Future<void> _pause() async {
    await _audioService.pause();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying =
        _audioService.isCurrent(
          widget.sleepstory.audioPath,
          BackgroundAudioType.story,
        ) &&
        _audioService.isPlaying;

    return Scaffold(
      appBar: AppBar(title: Text(widget.sleepstory.title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.sleepstory.content,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _audioAvailable
                  ? Column(
                      children: [
                        IconButton(
                          iconSize: 72,
                          icon: Icon(
                            isPlaying ? Icons.pause_circle : Icons.play_circle,
                          ),
                          onPressed: () {
                            isPlaying ? _pause() : _play();
                          },
                        ),
                        Text(isPlaying ? 'Pause Audio' : 'Play Audio'),
                      ],
                    )
                  : const Text('Audio coming soon.'),
            ),
          ],
        ),
      ),
    );
  }
}
