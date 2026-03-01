import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/animated_backgrounds.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      backgroundBuilder: (child) => NightSkyBackground(child: child),
      title: 'Sleep without distraction',
      description: 'Your nights deserve calm, not endless scrolling.',
    ),
    OnboardingPage(
      backgroundBuilder: (child) => OceanWavesBackground(child: child),
      title: 'Sounds, stories, stillness',
      description: 'Drift into sleep with gentle audio designed for rest.',
    ),
    OnboardingPage(
      backgroundBuilder: (child) => FloatingCloudsBackground(child: child),
      title: 'Lock distractions',
      description: 'Let Sleeplock protect your sleep automatically.',
    ),
    OnboardingPage(
      backgroundBuilder: (child) => AuroraLightsBackground(child: child),
      title: 'Start Your Journey',
      description: 'Begin your path to better sleep tonight.',
      isCTA: true,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          final page = _pages[index];
          return page.backgroundBuilder(
            Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: _completeOnboarding,
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                page.title,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                page.description,
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.white70,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(
                              _pages.length,
                              (idx) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: _currentPage == idx ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == idx
                                      ? Colors.white
                                      : Colors.white24,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_currentPage == _pages.length - 1) {
                                _completeOnboarding();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E1B2E),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _currentPage == _pages.length - 1
                                      ? 'Start My Night'
                                      : 'Next',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class OnboardingPage {
  final Widget Function(Widget child) backgroundBuilder;
  final String title;
  final String description;
  final bool isCTA;

  OnboardingPage({
    required this.backgroundBuilder,
    required this.title,
    required this.description,
    this.isCTA = false,
  });
}
