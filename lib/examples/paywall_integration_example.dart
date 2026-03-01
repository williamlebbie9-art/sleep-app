import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../screens/paywall_screen_premium.dart';

/// Example code for integrating the PaywallScreenPremium
/// into your Flutter app with RevenueCat

// ============================================================================
// STEP 1: Initialize RevenueCat in main()
// ============================================================================

/// Call this in your main() function before runApp()
Future<void> initializeRevenueCat() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Purchases.setLogLevel(
    LogLevel.debug,
  ); // Use LogLevel.info in production

  // Configure RevenueCat with platform-specific API keys
  PurchasesConfiguration configuration;

  if (defaultTargetPlatform == TargetPlatform.android) {
    // Google Play Store API key
    configuration = PurchasesConfiguration('test_JKbvYVuKwWsjygXSVAOkpVmWjTa');
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    // App Store API key
    configuration = PurchasesConfiguration('test_JKbvYVuKwWsjygXSVAOkpVmWjTa');
  } else {
    // Fallback for unsupported platforms
    throw UnsupportedError('Platform not supported');
  }

  await Purchases.configure(configuration);
}

// Example main.dart integration:
/*
void main() async {
  await initializeRevenueCat();
  runApp(const MyApp());
}
*/

// ============================================================================
// STEP 2: Show Paywall Screen
// ============================================================================

/// Show the paywall as a modal bottom sheet
/// Returns true if user successfully subscribed
Future<void> showPaywallExample(BuildContext context) async {
  final didSubscribe = await PaywallScreenPremium.show(context);

  if (didSubscribe) {
    // User subscribed! Update UI, enable premium features, etc.
    debugPrint('User successfully subscribed to premium!');
  } else {
    // User dismissed paywall without subscribing
    debugPrint('User closed paywall without subscribing');
  }
}

// ============================================================================
// STEP 3: Check Premium Entitlement
// ============================================================================

/// Check if user has premium access
/// Use this to gate premium features throughout your app
Future<bool> checkPremiumAccess() async {
  final hasPremium = await PaywallScreenPremium.hasPremiumEntitlement();
  return hasPremium;
}

/// Example: Gate a premium feature
class PremiumFeatureExample extends StatelessWidget {
  const PremiumFeatureExample({super.key});

  Future<void> _onFeatureTapped(BuildContext context) async {
    // Check if user has premium access
    final hasPremium = await PaywallScreenPremium.hasPremiumEntitlement();

    if (hasPremium) {
      // Allow access to premium feature
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PremiumFeatureScreen()),
      );
    } else {
      // Show paywall
      await PaywallScreenPremium.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _onFeatureTapped(context),
      child: const Text('Access Premium Feature'),
    );
  }
}

class PremiumFeatureScreen extends StatelessWidget {
  const PremiumFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Feature')),
      body: const Center(child: Text('This is a premium feature!')),
    );
  }
}

// ============================================================================
// STEP 4: Listen to Customer Info Updates
// ============================================================================

/// Listen to realtime subscription status changes
/// This is useful for updating UI when subscription status changes
class SubscriptionStatusExample extends StatefulWidget {
  const SubscriptionStatusExample({super.key});

  @override
  State<SubscriptionStatusExample> createState() =>
      _SubscriptionStatusExampleState();
}

class _SubscriptionStatusExampleState extends State<SubscriptionStatusExample> {
  bool _hasPremium = false;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
    _listenToSubscriptionChanges();
  }

  Future<void> _checkInitialStatus() async {
    final hasPremium = await PaywallScreenPremium.hasPremiumEntitlement();
    setState(() => _hasPremium = hasPremium);
  }

  void _listenToSubscriptionChanges() {
    // Listen to customer info updates in realtime
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      final hasPremium = customerInfo.entitlements.active.containsKey(
        'premium',
      );
      setState(() => _hasPremium = hasPremium);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Status')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _hasPremium ? Icons.star : Icons.star_border,
              size: 64,
              color: _hasPremium ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _hasPremium ? 'Premium Active' : 'Free Plan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            if (!_hasPremium)
              ElevatedButton(
                onPressed: () => PaywallScreenPremium.show(context),
                child: const Text('Upgrade to Premium'),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STEP 5: Handle User Login/Logout (Optional)
// ============================================================================

/// If your app has user authentication, sync RevenueCat with your user IDs
Future<void> onUserLogin(String userId) async {
  try {
    // This syncs the user's subscription across devices
    await Purchases.logIn(userId);
    debugPrint('RevenueCat user logged in: $userId');
  } catch (e) {
    debugPrint('Error logging in to RevenueCat: $e');
  }
}

/// Log out the user from RevenueCat
Future<void> onUserLogout() async {
  try {
    await Purchases.logOut();
    debugPrint('RevenueCat user logged out');
  } catch (e) {
    debugPrint('Error logging out from RevenueCat: $e');
  }
}

// ============================================================================
// REVENUE CAT DASHBOARD SETUP
// ============================================================================

/*
REQUIRED SETUP IN REVENUECAT DASHBOARD:

1. Create a Project
   - Go to app.revenuecat.com
   - Create new project for your app

2. Add Your App
   - Add iOS app with Bundle ID
   - Add Android app with Package Name
   - Get API keys for each platform

3. Create Products
   - In App Store Connect: Create subscriptions (e.g., monthly, yearly)
   - In Play Console: Create subscriptions (e.g., monthly, yearly)
   - Note the Product IDs (e.g., "premium_monthly", "premium_yearly")

4. Configure Products in RevenueCat
   - Go to Products tab
   - Add products with the same IDs from App/Play Store
   - Set display names and descriptions

5. Create Entitlement
   - Go to Entitlements tab
   - Create entitlement named "premium"
   - Attach your subscription products to this entitlement

6. Create Offering
   - Go to Offerings tab
   - Create an offering (e.g., "default")
   - Add packages:
     - Monthly package → Link to monthly product
     - Annual package → Link to annual product
   - Set one as default offering

7. Configure Trial Period (Optional)
   - In App Store Connect or Play Console
   - Set introductory offer (e.g., 14 days free)
   - RevenueCat will automatically detect and display it

8. Test Your Integration
   - Use Sandbox accounts for testing
   - iOS: Create test account in App Store Connect
   - Android: Use license testing in Play Console
   - Verify purchases work and entitlements unlock

IMPORTANT NOTES:
- API key configured: test_JKbvYVuKwWsjygXSVAOkpVmWjTa
- Make sure entitlement is named exactly "premium" (case-sensitive)
- Test on real devices, not just emulators
- Enable App Store/Play Store testing before production release
*/
