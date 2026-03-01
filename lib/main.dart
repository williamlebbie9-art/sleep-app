import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'sound_selection.dart';
import 'screens/activate_sleep_lock_screen.dart';
import 'screens/lock_active_screen.dart';
import 'screens/story_list_screen.dart';
import 'screens/ai_checkin_screen.dart';
import 'screens/ai_adviser_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/bedtime_settings_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/support_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/sleep_ai_service.dart';
import 'utils/streak_manager.dart';
import 'utils/rating_dialog.dart';
import 'models/story.dart';
import 'screens/story_reader_screen.dart';
import 'screens/streak_gallery_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Purchases.configure(
    PurchasesConfiguration('test_JKbvYVuKwWsjygXSVAOkpVmWjTa'),
  );
  await NotificationService().initialize();
  runApp(const SleepLockApp());
}

class SleepLockApp extends StatelessWidget {
  const SleepLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SleepLock',
      theme: ThemeData.dark(),
      home: const InitialRouteScreen(),
    );
  }
}

/// Handles the initial routing flow for first-time users:
/// 1. Sign-in screen (if not authenticated)
/// 2. Onboarding screen (if not completed)
/// 3. Paywall (optional, if user tries to access premium features)
/// 4. Home screen
class InitialRouteScreen extends StatefulWidget {
  const InitialRouteScreen({super.key});

  @override
  State<InitialRouteScreen> createState() => _InitialRouteScreenState();
}

class _InitialRouteScreenState extends State<InitialRouteScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _onboardingComplete = false;
  bool _paywallPromptCompleted = true;
  bool _isShowingPaywall = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndOnboarding();
  }

  Future<void> _checkAuthAndOnboarding() async {
    // Check authentication status
    final user = _authService.currentUser;
    final isAuth = user != null;

    // Check onboarding status
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_complete') ?? false;

    setState(() {
      _isAuthenticated = isAuth;
      _onboardingComplete = onboardingDone;
      _paywallPromptCompleted = isAuth;
      _isLoading = false;
    });
  }

  void _onSignInComplete() {
    setState(() {
      _isAuthenticated = true;
      _paywallPromptCompleted = false;
    });
  }

  void _onOnboardingComplete() {
    setState(() {
      _onboardingComplete = true;
    });
  }

  Future<void> _presentPostSignupPaywall() async {
    if (_isShowingPaywall || _paywallPromptCompleted || !_isAuthenticated) {
      return;
    }

    _isShowingPaywall = true;

    await PaywallScreen.show(
      context: context,
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          _paywallPromptCompleted = true;
        });
      },
    );

    if (mounted) {
      setState(() {
        _paywallPromptCompleted = true;
        _isShowingPaywall = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_onboardingComplete) {
      return OnboardingScreen(onComplete: _onOnboardingComplete);
    }

    if (!_isAuthenticated) {
      return SignUpScreen(onSignUpComplete: _onSignInComplete);
    }

    if (!_paywallPromptCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _presentPostSignupPaywall();
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int streak = 0;
  DateTime? unlockTime;
  bool lockActive = false;
  String? lockSoundPath;
  bool lockPlaySound = false;
  bool _hasProEntitlement = false;
  bool _entitlementLoading = true;

  Story? lastStory;

  @override
  void initState() {
    super.initState();
    _loadLockState();
    _loadLastStory();
    _loadEntitlement();
    _showRatingDialogIfNeeded();
  }

  Future<void> _showRatingDialogIfNeeded() async {
    // Wait a bit for the screen to fully load
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    await RatingDialog.show(context);
  }

  Future<void> _loadEntitlement() async {
    try {
      final hasEntitlement = await PaywallScreen.hasProEntitlement();
      if (!mounted) return;
      setState(() {
        _hasProEntitlement = hasEntitlement;
        _entitlementLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _entitlementLoading = false;
      });
    }
  }

  Future<void> _loadLastStory() async {
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString('lastStoryTitle');
    final content = prefs.getString('lastStoryContent');
    final audio = prefs.getString('lastStoryAudio');
    final premium = prefs.getBool('lastStoryPremium') ?? false;
    if (title != null && content != null && audio != null) {
      setState(() {
        lastStory = Story(
          title: title,
          content: content,
          audioPath: audio,
          premium: premium,
        );
      });
    }
  }

  Future<void> _loadLockState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      streak = prefs.getInt('streak') ?? 0;
      final unlockMillis = prefs.getInt('unlockTime');
      lockSoundPath = prefs.getString('lockSoundPath');
      lockPlaySound = prefs.getBool('lockPlaySound') ?? false;
      if (unlockMillis != null) {
        unlockTime = DateTime.fromMillisecondsSinceEpoch(unlockMillis);
        if (unlockTime!.isAfter(DateTime.now())) {
          lockActive = true;
        } else {
          lockActive = false;
        }
      } else {
        lockActive = false;
      }
    });
    // Auto-open lock screen if active
    if (lockActive && unlockTime != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LockActiveScreen(
              unlockTime: unlockTime!,
              streak: streak,
              soundPath: lockSoundPath,
              playSound: lockPlaySound,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SleepLock'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<int>(
              future: StreakManager.getStreak(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return Text(
                  "🔥 ${snapshot.data} night streak",
                  style: const TextStyle(fontSize: 18),
                );
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'Welcome to SleepLock 🌙',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.dashboard),
              label: const Text('Open Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C6CFF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SoundSelectionScreen(),
                  ),
                );
              },
              child: const Text('Start Sleep Mode'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AICheckInScreen(),
                  ),
                );
              },
              child: const Text('Night Check-In'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final keys = prefs.getKeys().where(
                  (k) => k.startsWith('photo_'),
                );
                final List<String> photoPaths = keys
                    .map((k) => prefs.getString(k))
                    .whereType<String>()
                    .toList();
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StreakGalleryScreen(photoPaths: photoPaths),
                  ),
                );
              },
              child: const Text('Streak Gallery'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final selection = await Navigator.push<ActivateSleepLockResult>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivateSleepLockScreen(),
                  ),
                );
                if (selection == null) {
                  return;
                }
                final prefs = await SharedPreferences.getInstance();
                final newUnlockTime = selection.unlockTime;
                final newStreak = streak + 1;
                await prefs.setInt('streak', newStreak);
                await prefs.setInt(
                  'unlockTime',
                  newUnlockTime.millisecondsSinceEpoch,
                );
                await prefs.setBool('lockPlaySound', selection.playSound);
                if (selection.soundPath != null) {
                  await prefs.setString('lockSoundPath', selection.soundPath!);
                } else {
                  await prefs.remove('lockSoundPath');
                }

                // Record sleep time for AI analysis
                await SleepAIService.recordSleepTime(DateTime.now());

                if (!context.mounted) return;

                setState(() {
                  streak = newStreak;
                  unlockTime = newUnlockTime;
                  lockActive = true;
                  lockPlaySound = selection.playSound;
                  lockSoundPath = selection.soundPath;
                });
                final lockFuture = Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LockActiveScreen(
                      unlockTime: newUnlockTime,
                      streak: newStreak,
                      soundPath: selection.soundPath,
                      playSound: selection.playSound,
                    ),
                  ),
                );
                if (lastStory != null && !lastStory!.premium) {
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) =>
                          StoryReaderScreen(sleepstory: lastStory!),
                    ),
                  );
                }
                final lockEnded = await lockFuture;
                if (lockEnded == true) {
                  await _loadLockState();
                }
              },
              child: const Text('Activate Sleep Lock'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => StoryListScreen(),
                  ),
                );
              },
              child: const Text('Browse Stories'),
            ),
            const SizedBox(height: 20),
            if (!_entitlementLoading && !_hasProEntitlement) ...[
              ElevatedButton(
                onPressed: () {
                  PaywallScreen.show(
                    context: context,
                    onSuccess: () {
                      Navigator.pop(context); // Close paywall
                      _loadEntitlement();
                    },
                  );
                },
                child: const Text('Present Paywall'),
              ),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIAdviserScreen(),
                  ),
                );
              },
              child: const Text('AI Sleep Adviser'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BedtimeSettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bedtime),
              label: const Text('Bedtime Reminders'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupportScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.help_outline),
              label: const Text('Help & Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder(
              stream: _authService.authStateChanges,
              builder: (context, snapshot) {
                final isSignedIn = snapshot.data != null;
                return ElevatedButton.icon(
                  onPressed: () async {
                    if (isSignedIn) {
                      await _authService.signOut();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    }
                  },
                  icon: Icon(isSignedIn ? Icons.logout : Icons.login),
                  label: Text(isSignedIn ? 'Sign Out' : 'Sign In'),
                );
              },
            ),
            const SizedBox(height: 20),
            // DEBUG: Reset onboarding and auth
            ElevatedButton.icon(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('onboarding_complete', false);
                await _authService.signOut();
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InitialRouteScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset (Show Onboarding/SignIn)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class SleepModeScreen extends StatefulWidget {
  final String soundPath;
  final int minutes;

  const SleepModeScreen({
    required this.soundPath,
    required this.minutes,
    super.key,
  });

  @override
  State<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends State<SleepModeScreen> {
  late int seconds;
  late AudioPlayer _audioPlayer;

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    seconds = widget.minutes * 60;
    _audioPlayer = AudioPlayer();
    _playAudio();
    startTimer();
  }

  Future<void> _playAudio() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Ensure looping
      await _audioPlayer.play(AssetSource(widget.soundPath));
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio file not found or is empty.')),
        );
      }
    }
  }

  void startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
        startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Sleep Mode")),
        body: Center(
          child: Text(
            "Sleep Mode Active\n\n$minutes:${remainingSeconds.toString().padLeft(2, '0')}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26),
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Sleep Mode"),
        content: const Text(
          "Sleep mode is active. Are you sure you want to exit?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to home screen
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }
}
