import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'referral_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ReferralService _referralService = ReferralService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle({String? referralCode}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _upsertUserProfile(
          userCredential.user!,
          provider: 'google',
          referralCode: referralCode,
        );
      }

      // Link RevenueCat to Firebase user
      if (userCredential.user != null) {
        await Purchases.logIn(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithApple({String? referralCode}) async {
    try {
      final isAppleSignInAvailable = await SignInWithApple.isAvailable();
      if (!isAppleSignInAvailable) {
        throw Exception('Apple Sign-In is not available on this device.');
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        String? fullName;
        if (appleCredential.givenName != null ||
            appleCredential.familyName != null) {
          fullName = [appleCredential.givenName, appleCredential.familyName]
              .whereType<String>()
              .where((part) => part.trim().isNotEmpty)
              .join(' ')
              .trim();
          if (fullName.isEmpty) {
            fullName = null;
          }
        }

        await _upsertUserProfile(
          userCredential.user!,
          provider: 'apple',
          emailOverride: appleCredential.email,
          displayNameOverride: fullName,
          referralCode: referralCode,
        );
      }

      // Link RevenueCat to Firebase user
      if (userCredential.user != null) {
        await Purchases.logIn(userCredential.user!.uid);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? referralCode,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      await Purchases.logIn(userCredential.user!.uid);
      await _upsertUserProfile(
        userCredential.user!,
        provider: 'email',
        referralCode: referralCode,
      );
    }

    return userCredential;
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      await Purchases.logIn(userCredential.user!.uid);
    }

    return userCredential;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await Purchases.logOut();
  }

  Future<void> _upsertUserProfile(
    User user, {
    required String provider,
    String? emailOverride,
    String? displayNameOverride,
    String? referralCode,
  }) async {
    final displayName =
        (displayNameOverride != null && displayNameOverride.trim().isNotEmpty)
        ? displayNameOverride.trim()
        : (user.displayName != null && user.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : null;

    final email = (emailOverride != null && emailOverride.trim().isNotEmpty)
        ? emailOverride.trim()
        : (user.email != null && user.email!.trim().isNotEmpty)
        ? user.email!.trim()
        : null;

    final data = <String, dynamic>{
      'uid': user.uid,
      'provider': provider,
      'email': email,
      'displayName': displayName,
      'photoUrl': user.photoURL,
      'emailVerified': user.emailVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(user.uid).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _applyReferralIfProvided(user: user, referralCode: referralCode);
  }

  Future<void> _applyReferralIfProvided({
    required User user,
    String? referralCode,
  }) async {
    final fallbackCode = await _referralService.getPendingReferralCode();
    final normalized = (referralCode ?? fallbackCode)?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      return;
    }

    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();
    final existingCode = userDoc.data()?['referredByCreatorCode'] as String?;
    if (existingCode != null && existingCode.trim().isNotEmpty) {
      return;
    }

    final creatorUid = await _referralService.resolveCreatorUidByCode(
      normalized,
    );
    if (creatorUid == null) {
      throw Exception('Referral code is invalid.');
    }
    if (creatorUid == user.uid) {
      throw Exception('You cannot use your own referral code.');
    }

    await userRef.set({
      'referredByCreatorCode': normalized,
      'referredByCreatorUid': creatorUid,
      'referredAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _referralService.clearPendingReferralCode();
  }
}
