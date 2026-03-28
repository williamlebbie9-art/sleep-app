import 'dart:async';

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class PaywallScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const PaywallScreen({super.key, required this.onSuccess});

  static const String entitlementId = 'sleeplock․co Pro';

  static Future<bool> hasProEntitlement() async {
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.all[entitlementId]?.isActive == true;
  }

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.92,
        child: PaywallScreen(onSuccess: onSuccess),
      ),
    );
  }

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  static const String _offerStartKey = 'founder_offer_started_at_ms';

  static const List<String> _starterPlanIds = [
    'pro_starter',
    'starter',
    'premium_monthly',
  ];
  static const List<String> _proMaxPlanIds = [
    'pro_max',
    'promax',
    'premium_pro_max',
  ];
  static const List<String> _yearlyPlanIds = [
    'premium_annual',
    'premium_yearly',
    'pro_yearly',
  ];

  bool _loadingOfferings = true;
  bool _isPurchasing = false;
  String? _error;

  List<Package> _packages = [];
  Package? _proStarterPackage;
  Package? _proMaxPackage;
  Package? _yearlyPackage;

  Timer? _countdownTimer;
  Duration _timeLeft = const Duration(hours: 24);

  @override
  void initState() {
    super.initState();
    _initializePaywall();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializePaywall() async {
    await Future.wait([_loadFounderOfferTimer(), _loadOfferings()]);
  }

  Future<void> _loadFounderOfferTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final savedStartMs = prefs.getInt(_offerStartKey);
    final start = savedStartMs != null
        ? DateTime.fromMillisecondsSinceEpoch(savedStartMs)
        : now;

    if (savedStartMs == null) {
      await prefs.setInt(_offerStartKey, start.millisecondsSinceEpoch);
    }

    final offerEndsAt = start.add(const Duration(hours: 24));

    if (!mounted) return;
    setState(() {
      _timeLeft = _remaining(offerEndsAt);
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeLeft = _remaining(offerEndsAt);
      });
    });
  }

  Duration _remaining(DateTime end) {
    final delta = end.difference(DateTime.now());
    return delta.isNegative ? Duration.zero : delta;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final available = offerings.current?.availablePackages ?? [];

      if (!mounted) return;
      setState(() {
        _packages = available;
        _mapPlans(available);
        _loadingOfferings = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load subscription plans. Please try again.';
        _loadingOfferings = false;
      });
    }
  }

  void _mapPlans(List<Package> available) {
    Package? findByExactIds(List<Package> candidates, List<String> ids) {
      final normalizedIds = ids.map((id) => id.toLowerCase()).toSet();
      for (final package in candidates) {
        final packageId = package.identifier.toLowerCase();
        final productId = package.storeProduct.identifier.toLowerCase();
        if (normalizedIds.contains(packageId) ||
            normalizedIds.contains(productId)) {
          return package;
        }
      }
      return null;
    }

    Package? findByTokens(List<Package> candidates, List<String> tokens) {
      for (final package in candidates) {
        final haystack =
            '${package.identifier} ${package.storeProduct.identifier} ${package.storeProduct.title}'
                .toLowerCase();
        if (tokens.any(haystack.contains)) {
          return package;
        }
      }
      return null;
    }

    _yearlyPackage =
        findByExactIds(available, _yearlyPlanIds) ??
        available
            .where((p) => p.packageType == PackageType.annual)
            .firstOrNull ??
        findByTokens(available, ['annual', 'yearly', 'year']);

    final nonYearly = available.where((p) => p != _yearlyPackage).toList();

    _proMaxPackage =
        findByExactIds(nonYearly, _proMaxPlanIds) ??
        findByTokens(nonYearly, ['pro_max', 'promax', 'max']) ??
        (nonYearly.isNotEmpty ? nonYearly.first : null);

    final remainingForStarter = nonYearly
        .where((p) => p != _proMaxPackage)
        .toList();
    _proStarterPackage =
        findByExactIds(remainingForStarter, _starterPlanIds) ??
        findByTokens(remainingForStarter, [
          'starter',
          'basic',
          'pro',
          'monthly',
          'month',
        ]) ??
        (remainingForStarter.isNotEmpty ? remainingForStarter.first : null);

    final fallback = available.isNotEmpty ? available.first : null;
    _proStarterPackage ??= fallback;
    _proMaxPackage ??= fallback;
    _yearlyPackage ??= fallback;
  }

  Future<void> _purchase(Package? package) async {
    if (package == null) {
      setState(() {
        _error =
            'This plan is not available right now. Please try another option.';
      });
      return;
    }

    setState(() {
      _isPurchasing = true;
      _error = null;
    });

    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      final entitlements = purchaseResult.customerInfo.entitlements.active;

      if (entitlements.isNotEmpty) {
        if (!mounted) return;
        widget.onSuccess();
        Navigator.pop(context);
        return;
      }

      if (!mounted) return;
      setState(() {
        _error = 'Purchase completed but premium was not activated yet.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Purchase cancelled or failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isPurchasing = true;
      _error = null;
    });

    try {
      final customerInfo = await Purchases.restorePurchases();
      final hasActiveEntitlement = customerInfo.entitlements.active.isNotEmpty;

      if (!mounted) return;

      if (hasActiveEntitlement) {
        widget.onSuccess();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium subscription restored!')),
        );
      } else {
        setState(() {
          _error = 'No active purchases found.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to restore purchases.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  Future<void> _handleCloseAttempt() async {
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleCloseAttempt();
        return false;
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1028), Color(0xFF1A1F45), Color(0xFF231F4D)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      onPressed: _handleCloseAttempt,
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sleep Better Tonight. Wake Up Stronger.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'AI guidance, sleep stories, and deep insights designed to improve your rest.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
                const SizedBox(height: 18),
                _buildBenefits(),
                const SizedBox(height: 12),
                Text(
                  'Trusted by thousands improving their sleep every night.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.84),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                _buildUrgencyTimer(),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text(
                    'All plans include:\n• 7-Day Free Trial\n• Cancel Anytime',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPlanCard(
                  planName: 'PRO PLAN',
                  badgeLabel: 'Best Value Starter',
                  todayPrice: '\$3.99 Today',
                  crossedPrice: '\$7.99',
                  subtitle: 'First Month Discount.',
                  features: const [
                    'AI Sleep Assistant.',
                    'Unlimited Sounds.',
                    'Sleep Tracking.',
                  ],
                  disclosure:
                      '7-day free trial, then \$3.99 for the first paid month, then \$7.99/month. Cancel anytime.',
                  package: _proStarterPackage,
                  highlighted: false,
                ),
                const SizedBox(height: 14),
                _buildPlanCard(
                  planName: 'PRO MAX PLAN',
                  badgeLabel: '🔥 MOST POPULAR.',
                  todayPrice: '\$4.99 Today.',
                  crossedPrice: '\$9.99.',
                  subtitle: '',
                  features: const [
                    'Advanced AI Guidance.',
                    'Premium Stories Library.',
                    'Deep Sleep Analytics.',
                    'Priority Updates.',
                  ],
                  disclosure:
                      '7-day free trial, then \$4.99 for the first paid month, then \$9.99/month. Cancel anytime.',
                  package: _proMaxPackage,
                  highlighted: true,
                ),
                const SizedBox(height: 14),
                _buildPlanCard(
                  planName: 'YEARLY PLAN',
                  badgeLabel: '⭐ BEST SAVINGS.',
                  todayPrice: '\$45.99 Today.',
                  crossedPrice: '\$89.99/year.',
                  subtitle: 'Save Almost 50%.',
                  features: const [
                    'All Pro Max Features.',
                    'Best Long-Term Value.',
                    'Priority AI Access.',
                  ],
                  disclosure:
                      '7-day free trial, then \$45.99 for the first year, then renews at \$89.99/year unless canceled.',
                  package: _yearlyPackage,
                  highlighted: false,
                ),
                if (_loadingOfferings) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(minHeight: 2),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isPurchasing ? null : _handleCloseAttempt,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(color: Colors.white.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start for Free',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton(
                      onPressed: _isPurchasing ? null : _restorePurchases,
                      child: const Text('Restore Purchases'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                      child: const Text('Privacy Policy'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TermsOfServiceScreen(),
                          ),
                        );
                      },
                      child: const Text('Terms of Use'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Subscription automatically renews unless canceled at least 24 hours before renewal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.67),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencyTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF5C1A23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔥 Founder Launch Offer Ends In:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDuration(_timeLeft),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    const benefits = [
      'AI Sleep Assistant Guidance.',
      'Premium Sleep Stories.',
      'Deep Sleep Tracking.',
      'Exclusive Relaxation Sounds.',
      'Personalized Insights.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: benefits
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF63E6BE),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPlanCard({
    required String planName,
    required String badgeLabel,
    required String todayPrice,
    required String crossedPrice,
    required String subtitle,
    required List<String> features,
    required String disclosure,
    required Package? package,
    required bool highlighted,
  }) {
    final borderColor = highlighted ? const Color(0xFFB784FF) : Colors.white24;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      transform: Matrix4.identity()..scale(highlighted ? 1.03 : 1.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted
            ? const Color(0xFF2B1E54)
            : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: highlighted ? 1.8 : 1.0),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: const Color(0xFFB784FF).withOpacity(0.35),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            planName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: highlighted
                  ? const Color(0xFF8E44FF)
                  : const Color(0xFF34495E),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badgeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                todayPrice,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  crossedPrice,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    decoration: TextDecoration.lineThrough,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 10),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $feature',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPurchasing ? null : () => _purchase(package),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: highlighted
                    ? const Color(0xFFB784FF)
                    : const Color(0xFF6C7BFF),
                foregroundColor: Colors.white,
              ),
              child: _isPurchasing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Start Free Trial.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            disclosure,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
