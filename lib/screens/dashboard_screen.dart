import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_adviser_screen.dart';
import 'story_list_screen.dart';
import '../sound_selection.dart';
import 'sleep_timer_screen.dart';
import 'activate_sleep_lock_screen.dart';
import 'ai_checkin_screen.dart';
import 'bedtime_settings_screen.dart';
import 'streak_gallery_screen.dart';
import 'support_screen.dart';
import '../utils/streak_manager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String? _selectedMood;
  int _streak = 0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _loadStreak();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadStreak() async {
    final streak = await StreakManager.getStreak();
    setState(() => _streak = streak);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1B2E), Color(0xFF121018)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildGreetingSection(),
                const SizedBox(height: 24),
                _buildSleepStatsCard(),
                const SizedBox(height: 24),
                _buildQuickActionsGrid(),
                const SizedBox(height: 24),
                _buildNightCheckIn(),
                const SizedBox(height: 24),
                _buildAdditionalFeatures(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildGreetingSection() {
    final hour = DateTime.now().hour;
    String greeting = 'Good Evening';
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, Sleeper',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ready for restful sleep?',
                style: TextStyle(fontSize: 16, color: Color(0xFFB8B5D1)),
              ),
            ],
          ),
        ),
        _buildStreakIndicator(),
      ],
    );
  }

  Widget _buildStreakIndicator() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C6CFF), Color(0xFF5B4BDB)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF7C6CFF,
                ).withValues(alpha: 0.3 + (_pulseController.value * 0.2)),
                blurRadius: 20 + (_pulseController.value * 10),
                spreadRadius: 2 + (_pulseController.value * 3),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  '$_streak Day',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Streak',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSleepStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF24213A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF7C6CFF).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6CFF).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sleep Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6CFF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Last 7 Days',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7C6CFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Last Night', '7h 32m', Icons.bedtime),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem('Quality Score', '84%', Icons.star),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMiniGraph(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF7C6CFF), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFFB8B5D1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniGraph() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 60),
        painter: _SleepGraphPainter(),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildActionCard(
              'AI Sleep Coach',
              Icons.psychology,
              const Color(0xFF7C6CFF),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AIAdviserScreen()),
              ),
            ),
            _buildActionCard(
              'Sleep Stories',
              Icons.auto_stories,
              const Color(0xFF6C5CE7),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StoryListScreen()),
              ),
            ),
            _buildActionCard(
              'Screen Lock',
              Icons.lock_clock,
              const Color(0xFF5B4BDB),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ActivateSleepLockScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Night Check-In',
              Icons.camera_alt,
              const Color(0xFF5D3EC5),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AICheckInScreen()),
              ),
            ),
            _buildActionCard(
              'Sleep Timer',
              Icons.timer,
              const Color(0xFF4A3BC2),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SleepTimerScreen()),
              ),
            ),
            _buildActionCard(
              'Sounds',
              Icons.music_note,
              const Color(0xFF3E319F),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SoundSelectionScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNightCheckIn() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF24213A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling tonight?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMoodButton('😌 Calm', 'calm'),
              _buildMoodButton('😰 Stressed', 'stressed'),
              _buildMoodButton('😴 Tired', 'tired'),
              _buildMoodButton('😟 Anxious', 'anxious'),
            ],
          ),
          if (_selectedMood != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AICheckInScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C6CFF),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Start Night Check-In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodButton(String label, String mood) {
    final isSelected = _selectedMood == mood;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = mood),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C6CFF) : const Color(0xFF1E1B2E),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C6CFF)
                : const Color(0xFF7C6CFF).withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7C6CFF).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'More Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureTile(
          'Bedtime Reminders',
          'Set smart notifications',
          Icons.notifications_active,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BedtimeSettingsScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureTile(
          'Streak Gallery',
          'View your sleep photos',
          Icons.photo_library,
          () async {
            final prefs = await SharedPreferences.getInstance();
            final keys = prefs.getKeys().where((k) => k.startsWith('photo_'));
            final photoEntries = <String, String>{
              for (final key in keys)
                if (prefs.getString(key) != null) key: prefs.getString(key)!,
            };
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StreakGalleryScreen(photoEntries: photoEntries),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildFeatureTile(
          'Help & Support',
          'Get help and troubleshoot issues',
          Icons.help_outline,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupportScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF24213A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7C6CFF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF7C6CFF), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFB8B5D1),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFB8B5D1),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF24213A),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.bar_chart, 'Stats', 1),
          _buildNavItem(Icons.library_books, 'Library', 2),
          _buildNavItem(Icons.person, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF7C6CFF).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFF7C6CFF)
                  : const Color(0xFFB8B5D1),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? const Color(0xFF7C6CFF)
                    : const Color(0xFFB8B5D1),
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 3,
                width: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6CFF),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C6CFF).withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SleepGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7C6CFF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF7C6CFF).withValues(alpha: 0.3),
          const Color(0xFF7C6CFF).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final points = [0.4, 0.6, 0.5, 0.8, 0.7, 0.65, 0.55];
    final stepX = size.width / (points.length - 1);

    path.moveTo(0, size.height * (1 - points[0]));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height * (1 - points[0]));

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height * (1 - points[i]);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height * (1 - points[i - 1]);
        final cpX = prevX + stepX / 2;

        path.cubicTo(cpX, prevY, cpX, y, x, y);
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }

      // Draw point
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()
          ..color = const Color(0xFF7C6CFF)
          ..style = PaintingStyle.fill,
      );
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
