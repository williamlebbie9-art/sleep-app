import 'package:flutter/material.dart';

import '../models/story.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/background_audio_service.dart';
import 'paywall_screen.dart';

class StoryReaderScreen extends StatefulWidget {
  final Story sleepstory;

  const StoryReaderScreen({super.key, required this.sleepstory});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  final BackgroundAudioService _audioService = BackgroundAudioService.instance;
  final ScrollController _storyScrollController = ScrollController();
  late bool _audioAvailable;
  bool _hasProEntitlement = false;
  bool _showingStoryPaywall = false;

  @override
  void initState() {
    super.initState();
    _audioAvailable = widget.sleepstory.audioPath.trim().isNotEmpty;
    _storyScrollController.addListener(_handleStoryScroll);
    _loadEntitlement();

    // Save last played story to SharedPreferences
    _saveLastStory();
  }

  @override
  void dispose() {
    _storyScrollController
      ..removeListener(_handleStoryScroll)
      ..dispose();
    super.dispose();
  }

  bool get _shouldGateAtMidpoint => !_hasProEntitlement;

  Future<void> _loadEntitlement() async {
    try {
      final hasEntitlement = await PaywallScreen.hasProEntitlement();
      if (!mounted) return;
      setState(() {
        _hasProEntitlement = hasEntitlement;
      });
    } catch (_) {}
  }

  void _handleStoryScroll() {
    if (!_shouldGateAtMidpoint || _showingStoryPaywall) return;
    if (!_storyScrollController.hasClients) return;

    final maxScrollExtent = _storyScrollController.position.maxScrollExtent;
    if (maxScrollExtent <= 0) return;

    final maxFreeOffset = maxScrollExtent * 0.5;
    if (_storyScrollController.offset <= maxFreeOffset) {
      return;
    }

    _storyScrollController.jumpTo(maxFreeOffset);
    _showStoryMidpointPaywall();
  }

  Future<void> _showStoryMidpointPaywall() async {
    if (_showingStoryPaywall) return;

    _showingStoryPaywall = true;
    await PaywallScreen.show(
      context: context,
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          _hasProEntitlement = true;
        });
      },
    );
    await _loadEntitlement();

    if (mounted && !_hasProEntitlement) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Free users can read up to the middle of stories. Upgrade to continue.',
          ),
        ),
      );
    }
    _showingStoryPaywall = false;
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
                controller: _storyScrollController,
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.sleepstory.content,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            if (_shouldGateAtMidpoint)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.amber.withOpacity(0.12),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: Colors.amber),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Story continues after midpoint for Premium members.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: _showStoryMidpointPaywall,
                      child: const Text('Unlock'),
                    ),
                  ],
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
