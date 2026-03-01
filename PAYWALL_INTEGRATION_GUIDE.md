# Production-Ready Paywall Integration Guide

## Overview
This guide explains how to integrate the new `PaywallScreenPremium` into your SleepLock app. The new paywall is production-ready with dynamic pricing, proper error handling, and App Store/Play Store compliance.

## Files Created

1. **lib/screens/paywall_screen_premium.dart**
   - Production-ready paywall UI with dark purple design
   - Dynamic pricing from RevenueCat (no hardcoded prices)
   - Monthly/Yearly toggle with savings calculation
   - Free trial support
   - Restore purchases button (Apple requirement)
   - Loading and error states

2. **lib/examples/paywall_integration_example.dart**
   - Complete integration examples
   - RevenueCat initialization code
   - Entitlement checking examples
   - Subscription status listener
   - User login/logout handling

## Quick Start

### 1. Update main.dart Initialization

Replace your current RevenueCat initialization with platform-specific API keys:

```dart
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize RevenueCat with platform-specific keys
  PurchasesConfiguration configuration;
  if (defaultTargetPlatform == TargetPlatform.android) {
    configuration = PurchasesConfiguration('test_JKbvYVuKwWsjygXSVAOkpVmWjTa');
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    configuration = PurchasesConfiguration('test_JKbvYVuKwWsjygXSVAOkpVmWjTa');
  } else {
    throw UnsupportedError('Platform not supported');
  }
  
  await Purchases.configure(configuration);
  await NotificationService().initialize();
  runApp(const SleepLockApp());
}
```

### 2. Show the Paywall

Replace existing `PaywallScreen.show()` calls with:

```dart
// Old way:
await PaywallScreen.show(context);

// New way:
final didSubscribe = await PaywallScreenPremium.show(context);
if (didSubscribe) {
  // User subscribed - update UI, enable features, etc.
}
```

### 3. Check Premium Access

Replace existing entitlement checks with:

```dart
// Old way:
final hasPremium = await PaywallScreen.hasProEntitlement();

// New way:
final hasPremium = await PaywallScreenPremium.hasPremiumEntitlement();
```

## Features Included

### UI/UX Features
✅ Dark purple premium design matching sleep app aesthetic
✅ "Free Trial Available" badge
✅ Monthly/Yearly subscription toggle
✅ Dynamic "Save X%" calculation for annual plan
✅ Premium features list with check icons:
  - AI Guide
  - Screen Lock
  - Relaxing Sounds
  - Text and Audio Stories
  - AI Sleep Coach
  - Streaks
  - Night Check-in with Photo
✅ Dynamic pricing (fetched from RevenueCat)
✅ Free trial period display (if configured)
✅ Legal compliance text
✅ Restore Purchases button (Apple requirement)

### Technical Features
✅ RevenueCat SDK integration
✅ Dynamic offerings loading
✅ Monthly and annual package support
✅ Free trial support (configured in App/Play Store)
✅ Purchase flow with error handling
✅ User cancellation handling
✅ Restore purchases functionality
✅ Loading states
✅ Error states with retry
✅ Entitlement checking ("premium")
✅ Modal bottom sheet presentation
✅ No hardcoded prices or text
✅ Platform-specific API key configuration
✅ App Store & Play Store compliant

## RevenueCat Dashboard Setup

### Step 1: Create Products in App Store Connect (iOS)
1. Go to App Store Connect
2. Select your app
3. Go to "In-App Purchases"
4. Create Auto-Renewable Subscriptions:
   - Product ID: `premium_monthly`
   - Product ID: `premium_annual`
5. Configure pricing for each product
6. (Optional) Add introductory offer (e.g., 14 days free trial)

### Step 2: Create Products in Google Play Console (Android)
1. Go to Play Console
2. Select your app
3. Go to "Monetization" → "Subscriptions"
4. Create subscriptions:
   - Product ID: `premium_monthly`
   - Product ID: `premium_annual`
5. Configure pricing for each product
6. (Optional) Add free trial period

### Step 3: Configure RevenueCat Dashboard
1. Go to [app.revenuecat.com](https://app.revenuecat.com)
2. Create a new project or select existing
3. Add your apps:
   - iOS: Add bundle ID
   - Android: Add package name (com.sleeplock.app)
4. Copy API keys:
   - **Already configured in this project:** `test_JKbvYVuKwWsjygXSVAOkpVmWjTa`
   - Production keys: Android starts with `goog_`, iOS starts with `appl_`

### Step 4: Create Products in RevenueCat
1. Go to Products tab
2. Click "Add Product"
3. Create products matching App/Play Store:
   - `premium_monthly`
   - `premium_annual`

### Step 5: Create Entitlement
1. Go to Entitlements tab
2. Click "Add Entitlement"
3. Name it exactly: `premium` (case-sensitive)
4. Attach both products to this entitlement

### Step 6: Create Offering
1. Go to Offerings tab
2. Create new offering called "default"
3. Add packages:
   - **Monthly Package**
     - Package Type: Monthly
     - Product: premium_monthly
   - **Annual Package**
     - Package Type: Annual
     - Product: premium_annual
4. Set as default offering

### Step 7: Configure Free Trial (Optional)
In App Store Connect or Play Console:
- iOS: Set "Introductory Offer" (e.g., 14 days free)
- Android: Set "Free trial" in subscription settings

RevenueCat will automatically detect and display trial information!

## Migration from Old Paywall

### Find and Replace
Search your entire project for:

**OLD:**
```dart
import 'screens/paywall_screen.dart';
```
**NEW:**
```dart
import 'screens/paywall_screen_premium.dart';
```

**OLD:**
```dart
PaywallScreen.show(context);
```
**NEW:**
```dart
PaywallScreenPremium.show(context);
```

**OLD:**
```dart
PaywallScreen.hasProEntitlement();
```
**NEW:**
```dart
PaywallScreenPremium.hasPremiumEntitlement();
```

### Update Entitlement Name
The old code used `"sleeplock․co Pro"` - the new code uses `"premium"`.

**In RevenueCat Dashboard:**
1. Go to Entitlements tab
2. Either rename existing entitlement to `"premium"`, or
3. Create new entitlement called `"premium"` and attach products

## Testing

### iOS Testing
1. Create sandbox test account in App Store Connect
2. Sign out of App Store on device
3. Run app and trigger paywall
4. Sign in with sandbox account when prompted
5. Complete purchase
6. Verify premium features unlock

### Android Testing
1. Add test account in Play Console → License Testing
2. Run app from Android Studio/VS Code
3. Trigger paywall and complete test purchase
4. Verify premium features unlock

### Test Restore Purchases
1. Complete a test purchase
2. Uninstall and reinstall app
3. Tap "Restore Purchases"
4. Verify premium features unlock

### Test Subscription Status Listener
1. Subscribe in app
2. Go to App Store/Play Console
3. Cancel subscription
4. Verify app detects cancellation

## Common Issues

### "No offerings found"
- Check RevenueCat dashboard has products configured
- Verify offering is set as default
- Check API keys are correct for platform
- Wait 5-10 minutes for RevenueCat to sync

### "Purchase failed"
- Ensure test account is signed in
- Verify products exist in App Store Connect / Play Console
- Check product IDs match exactly
- Enable purchase testing in sandbox

### "Entitlement not unlocking"
- Verify entitlement is named exactly `"premium"`
- Check products are attached to entitlement
- Confirm purchase completed successfully
- Test with fresh RevenueCat customer

## App Store Compliance

✅ Restore Purchases button included (Apple requirement)
✅ Dynamic pricing (not hardcoded)
✅ Legal text includes pricing and cancellation info
✅ Free trial period clearly displayed
✅ No misleading language
✅ Cancel anytime messaging

## Production Checklist

Before releasing to App Store / Play Store:

- [ ] Replace test API key (`test_JKbvYVuKwWsjygXSVAOkpVmWjTa`) with production keys
- [ ] Change LogLevel to `LogLevel.info` (not debug)
- [ ] Test on real devices (not just emulators)
- [ ] Test all purchase flows
- [ ] Test restore purchases
- [ ] Verify correct pricing displays
- [ ] Test free trial if configured
- [ ] Verify premium features lock/unlock correctly
- [ ] Test subscription cancellation
- [ ] Configure products in App Store Connect
- [ ] Configure products in Play Console
- [ ] Set up offerings in RevenueCat
- [ ] Create entitlement in RevenueCat
- [ ] Enable auto-renew subscriptions
- [ ] Submit for review

## Support

For RevenueCat issues:
- Docs: https://docs.revenuecat.com
- Community: https://community.revenuecat.com

For Flutter/purchases_flutter issues:
- GitHub: https://github.com/RevenueCat/purchases-flutter

## Summary

The new `PaywallScreenPremium` is a complete, production-ready solution that:
1. Fetches pricing dynamically from RevenueCat
2. Supports monthly and annual subscriptions
3. Automatically displays free trial information
4. Handles all purchase flows and errors
5. Includes required restore purchases functionality
6. Matches your sleep app's premium design
7. Complies with App Store and Play Store guidelines

Simply replace the API keys, configure RevenueCat dashboard, and you're ready to ship! 🚀
