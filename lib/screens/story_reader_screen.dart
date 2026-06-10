import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
  StreamSubscription<Duration>? _positionSubscription;
  Duration? _audioDuration;
  bool _audioStoppedAtMidpoint = false;

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
    _positionSubscription?.cancel();
    _storyScrollController
      ..removeListener(_handleStoryScroll)
      ..dispose();
    super.dispose();
  }

  bool get _shouldGateAtMidpoint => !_hasProEntitlement;

  /// Returns the character index where the midpoint of the story is.
  int get _storyMidpointIndex {
    final content = widget.sleepstory.content;
    if (content.isEmpty) return 0;
    return (content.length * 0.5).round();
  }

  /// Returns the first half of the story text.
  String get _firstHalfContent {
    return widget.sleepstory.content.substring(0, _storyMidpointIndex);
  }

  /// Returns the second half of the story text.
  String get _secondHalfContent {
    return widget.sleepstory.content.substring(_storyMidpointIndex);
  }

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

    // Stop audio if playing
    if (_audioService.isPlaying) {
      await _audioService.stop();
      _audioStoppedAtMidpoint = true;
      if (mounted) setState(() {});
    }

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

    // Reset the stopped-at-midpoint flag on new play
    _audioStoppedAtMidpoint = false;

    try {
      await _audioService.playStory(widget.sleepstory.audioPath);
      if (!mounted) return;
      setState(() {});

      // Subscribe to position to stop at halfway point
      _startMidpointAudioTracking();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio file not found or is empty.')),
      );
    }
  }

  void _startMidpointAudioTracking() {
    _positionSubscription?.cancel();

    final player = _audioService.getAudioPlayer();

    // Get audio duration
    player.onDurationChanged.listen((duration) {
      _audioDuration = duration;
    });

    // Track position
    _positionSubscription = player.onPositionChanged.listen((position) {
      if (!_shouldGateAtMidpoint || _audioDuration == null) return;
      if (_audioStoppedAtMidpoint) return;

      final midPoint = _audioDuration! * 0.5;
      if (position >= midPoint) {
        // Stop the audio and show paywall
        _audioService.stop();
        _audioStoppedAtMidpoint = true;
        if (mounted) setState(() {});
        _showStoryMidpointPaywall();
      }
    });
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First half - always visible
                    Text(
                      _firstHalfContent,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    // Second half - hidden for free users
                    if (!_hasProEntitlement) ...[
                      const SizedBox(height: 24),
                      _buildMidpointPaywallOverlay(),
                    ] else ...[
                      Text(
                        _secondHalfContent,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ],
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
                        if (_audioStoppedAtMidpoint && !_hasProEntitlement)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Audio stopped at midpoint. Upgrade to continue listening.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.amber.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
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

  Widget _buildMidpointPaywallOverlay() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, size: 48, color: Colors.amber.shade300),
          const SizedBox(height: 16),
          const Text(
            'Story Continues Here',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The rest of this story is for Premium members.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showStoryMidpointPaywall,
              icon: const Icon(Icons.star, color: Colors.white),
              label: const Text(
                'Unlock Full Story',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
