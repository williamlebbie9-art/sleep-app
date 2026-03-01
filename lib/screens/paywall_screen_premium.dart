import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Production-ready paywall screen for SleepLock premium subscriptions
/// Uses RevenueCat for subscription management and dynamic pricing
class PaywallScreenPremium extends StatefulWidget {
  const PaywallScreenPremium({super.key});

  /// Show paywall as modal bottom sheet
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaywallScreenPremium(),
    );
    return result ?? false;
  }

  /// Check if user has premium entitlement
  /// Call this to gate premium features throughout the app
  static Future<bool> hasPremiumEntitlement() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey('premium');
    } catch (e) {
      debugPrint('Error checking premium entitlement: $e');
      return false;
    }
  }

  @override
  State<PaywallScreenPremium> createState() => _PaywallScreenPremiumState();
}

class _PaywallScreenPremiumState extends State<PaywallScreenPremium> {
  Offering? _offering;
  Package? _selectedPackage;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;
  bool _showYearly = true; // Default to yearly (better value)

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  /// Load offerings from RevenueCat
  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      if (current == null || current.availablePackages.isEmpty) {
        setState(() {
          _errorMessage = 'No subscription plans available';
          _isLoading = false;
        });
        return;
      }

      // Select default package (prefer annual)
      Package? defaultPackage;
      for (final pkg in current.availablePackages) {
        if (pkg.packageType == PackageType.annual) {
          defaultPackage = pkg;
          _showYearly = true;
          break;
        }
      }
      defaultPackage ??= current.availablePackages.first;

      setState(() {
        _offering = current;
        _selectedPackage = defaultPackage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load subscription plans: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Purchase the selected package
  Future<void> _purchasePackage() async {
    if (_selectedPackage == null) return;

    setState(() => _isPurchasing = true);

    try {
      final purchaseResult = await Purchases.purchasePackage(_selectedPackage!);
      final customerInfo = purchaseResult.customerInfo;

      // Check if premium entitlement is now active
      if (customerInfo.entitlements.active.containsKey('premium')) {
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        setState(() {
          _errorMessage = 'Purchase completed but premium not activated';
          _isPurchasing = false;
        });
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        setState(() {
          _errorMessage = 'Purchase failed: ${e.message}';
          _isPurchasing = false;
        });
      } else {
        // User cancelled, just reset loading state
        setState(() => _isPurchasing = false);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: ${e.toString()}';
        _isPurchasing = false;
      });
    }
  }

  /// Restore previous purchases
  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);

    try {
      final customerInfo = await Purchases.restorePurchases();

      if (customerInfo.entitlements.active.containsKey('premium')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Premium restored successfully!')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No purchases to restore')),
          );
        }
        setState(() => _isPurchasing = false);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Restore failed: ${e.toString()}';
        _isPurchasing = false;
      });
    }
  }

  /// Get monthly package from offering
  Package? get _monthlyPackage {
    return _offering?.availablePackages.firstWhere(
      (pkg) => pkg.packageType == PackageType.monthly,
      orElse: () => _offering!.availablePackages.first,
    );
  }

  /// Get annual package from offering
  Package? get _annualPackage {
    return _offering?.availablePackages.firstWhere(
      (pkg) => pkg.packageType == PackageType.annual,
      orElse: () => _offering!.availablePackages.first,
    );
  }

  /// Calculate savings percentage for annual vs monthly
  String _calculateSavings() {
    final monthly = _monthlyPackage;
    final annual = _annualPackage;

    if (monthly == null || annual == null) return '';

    final monthlyPrice = monthly.storeProduct.price;
    final annualPrice = annual.storeProduct.price;
    final yearlyMonthlyPrice = monthlyPrice * 12;

    if (yearlyMonthlyPrice == 0) return '';

    final savings =
        ((yearlyMonthlyPrice - annualPrice) / yearlyMonthlyPrice * 100);
    return 'Save ${savings.round()}%';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A0B2E), // Deep purple
            Color(0xFF2D1B4E), // Medium purple
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48.0),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    : _errorMessage != null
                    ? _buildErrorState()
                    : _buildPaywallContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.white70),
        const SizedBox(height: 16),
        Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loadOfferings,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildPaywallContent() {
    final selectedProduct = _selectedPackage?.storeProduct;

    return Column(
      children: [
        // Free Trial Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.deepPurpleAccent, width: 1),
          ),
          child: Text(
            selectedProduct?.introductoryPrice?.periodNumberOfUnits != null
                ? 'Free Trial Available'
                : 'Premium Features',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Title
        const Text(
          'Unlock Better Sleep',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        // Subtitle
        const Text(
          'Start your journey to peaceful nights',
          style: TextStyle(color: Colors.white70, fontSize: 16),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Monthly / Yearly Toggle
        if (_monthlyPackage != null && _annualPackage != null)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildToggleOption('Monthly', !_showYearly, () {
                    setState(() {
                      _showYearly = false;
                      _selectedPackage = _monthlyPackage;
                    });
                  }),
                ),
                Expanded(
                  child: _buildToggleOption('Yearly', _showYearly, () {
                    setState(() {
                      _showYearly = true;
                      _selectedPackage = _annualPackage;
                    });
                  }, badge: _calculateSavings()),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),

        // Pricing Card
        if (selectedProduct != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _showYearly
                    ? [Colors.deepPurpleAccent, Colors.purpleAccent]
                    : [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _showYearly
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  selectedProduct.priceString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  _showYearly ? 'per year' : 'per month',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                if (selectedProduct.introductoryPrice != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Free for ${selectedProduct.introductoryPrice!.periodNumberOfUnits} '
                    '${selectedProduct.introductoryPrice!.periodUnit.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

        const SizedBox(height: 32),

        // Features List
        _buildFeaturesList(),

        const SizedBox(height: 32),

        // CTA Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isPurchasing ? null : _purchasePackage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A0B2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: _isPurchasing
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    selectedProduct?.introductoryPrice != null
                        ? 'Start Free Trial'
                        : 'Subscribe Now',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // Legal Text
        if (selectedProduct != null)
          Text(
            _buildLegalText(selectedProduct),
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),

        const SizedBox(height: 16),

        // Restore Purchases Button
        TextButton(
          onPressed: _isPurchasing ? null : _restorePurchases,
          child: const Text(
            'Restore Purchases',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOption(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1A0B2E) : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            if (badge != null && isSelected) ...[
              const SizedBox(height: 4),
              Text(
                badge,
                style: TextStyle(
                  color: isSelected
                      ? Colors.deepPurple
                      : Colors.deepPurpleAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'AI Guide',
      'Screen Lock',
      'Relaxing Sounds',
      'Text and Audio Stories',
      'AI Sleep Coach',
      'Streaks',
      'Night Check-in with Photo',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.greenAccent, width: 2),
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                feature,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _buildLegalText(StoreProduct product) {
    final intro = product.introductoryPrice;
    if (intro != null) {
      final period = intro.periodNumberOfUnits;
      final unit = intro.periodUnit.name;
      return 'Free for $period $unit, then ${product.priceString}/${_showYearly ? 'year' : 'month'}. Cancel anytime.';
    }
    return 'Billed ${_showYearly ? 'annually' : 'monthly'}. Cancel anytime.';
  }
}
