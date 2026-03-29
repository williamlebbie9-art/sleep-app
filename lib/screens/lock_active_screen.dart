import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/streak_manager.dart';
import '../utils/rating_dialog.dart';

class LockActiveScreen extends StatefulWidget {
  final DateTime unlockTime;
  final int streak;
  final String? soundPath;
  final bool playSound;

  const LockActiveScreen({
    super.key,
    required this.unlockTime,
    required this.streak,
    this.soundPath,
    this.playSound = false,
  });

  @override
  State<LockActiveScreen> createState() => _LockActiveScreenState();
}

class _LockActiveScreenState extends State<LockActiveScreen> {
  late Timer _timer;
  Duration remaining = Duration.zero;
  AudioPlayer? _player;
  AudioPlayer? _alarmPlayer;
  bool _hasShownRatingDialog = false;
  bool _alarmPlaying = false;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _startAudioIfNeeded();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() async {
    final diff = widget.unlockTime.difference(DateTime.now());
    setState(() {
      remaining = diff.isNegative ? Duration.zero : diff;
    });
    // If lock just ended, complete the streak, play alarm, and show rating dialog
    if (diff.inSeconds <= 0 && remaining == Duration.zero && !_alarmPlaying) {
      await StreakManager.completeNight();
      await _playAlarm();
      if (!_hasShownRatingDialog && mounted) {
        _hasShownRatingDialog = true;
        // Wait a moment before showing dialog
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          await RatingDialog.show(context);
        }
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopAudio();
    _stopAlarm();
    super.dispose();
  }

  Future<void> _startAudioIfNeeded() async {
    if (!widget.playSound || widget.soundPath == null) {
      return;
    }
    _player = AudioPlayer();
    try {
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.play(AssetSource(widget.soundPath!));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio file not found or is empty.')),
        );
      }
    }
  }

  Future<void> _stopAudio() async {
    await _player?.stop();
    await _player?.dispose();
    _player = null;
  }

  Future<void> _playAlarm() async {
    if (_alarmPlaying) return;
    setState(() => _alarmPlaying = true);

    _alarmPlayer = AudioPlayer();
    try {
      // Play alarm in loop
      await _alarmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _alarmPlayer!.play(AssetSource('alarm'));

      // Stop after 30 seconds
      await Future.delayed(const Duration(seconds: 30));
      await _stopAlarm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Alarm sound not found: \$e')));
      }
    }
  }

  Future<void> _stopAlarm() async {
    await _alarmPlayer?.stop();
    await _alarmPlayer?.dispose();
    _alarmPlayer = null;
    if (mounted) {
      setState(() => _alarmPlaying = false);
    }
  }

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  Future<void> _showEndSleep() async {
    final ended = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EndSleepScreen(waitSeconds: remaining == Duration.zero ? 0 : 600),
      ),
    );
    if (ended == true) {
      await _endSleep();
    }
  }

  Future<void> _endSleep() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('unlockTime');
    await prefs.remove('lockSoundPath');
    await prefs.remove('lockBlockedApps');
    await prefs.setBool('lockPlaySound', false);
    await StreakManager.breakStreak();
    await _stopAudio();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Use End Sleep to exit.')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  "Sleep Lock Active",
                  style: TextStyle(color: Colors.white, fontSize: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  _format(remaining),
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Your sleep is protected.\nStay the course.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _showEndSleep,
                  child: const Text('End Sleep'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EndSleepScreen extends StatefulWidget {
  final int waitSeconds;

  const EndSleepScreen({super.key, required this.waitSeconds});

  @override
  State<EndSleepScreen> createState() => _EndSleepScreenState();
}

class _EndSleepScreenState extends State<EndSleepScreen> {
  static const String _instantExitProductId = 'instant_exit_1usd';
  Timer? timer;
  late int remainingSeconds;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.waitSeconds;
    if (remainingSeconds > 0) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          if (remainingSeconds > 0) {
            remainingSeconds--;
          }
        });
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String _formatSeconds(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$remainder";
  }

  Future<void> _confirmInstantExit() async {
    if (_isPurchasing) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Sleep Now'),
        content: const Text('Pay \$1 to end sleep immediately?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pay \$1 Now'),
          ),
        ],
      ),
    );
    if (result == true) {
      await _purchaseInstantExit();
    }
  }

  Future<void> _purchaseInstantExit() async {
    if (!mounted) return;
    setState(() => _isPurchasing = true);
    try {
      final products = await Purchases.getProducts([_instantExitProductId]);
      if (products.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Instant exit product not found.')),
        );
        return;
      }
      await Purchases.purchaseStoreProduct(products.first);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (!mounted) return;
      final message = errorCode == PurchasesErrorCode.purchaseCancelledError
          ? 'Purchase cancelled.'
          : 'Purchase failed. Please try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEnd = remainingSeconds == 0;
    return Scaffold(
      appBar: AppBar(title: const Text('End Sleep')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nightlight_round, size: 64),
            const SizedBox(height: 20),
            Text(
              canEnd
                  ? 'You can end sleep now.'
                  : 'Wait 10 minutes to end sleep.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (!canEnd)
              Text(
                _formatSeconds(remainingSeconds),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: canEnd ? () => Navigator.pop(context, true) : null,
              child: const Text('End Sleep'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isPurchasing ? null : _confirmInstantExit,
              child: Text(
                _isPurchasing ? 'Processing...' : 'End Sleep Now (\$1)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
