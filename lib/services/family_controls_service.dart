import 'package:flutter_family_controls/flutter_family_controls.dart';

class FamilyControlsService {
  static Future<bool> isSupported() async {
    try {
      return await FlutterFamilyControls.isSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isAuthorized() async {
    try {
      return await FlutterFamilyControls.isAuthorized();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestAuthorization() async {
    try {
      return await FlutterFamilyControls.requestAuthorization();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> showAppPicker({
    String? title,
    String? cancelLabel,
    String? saveLabel,
  }) async {
    try {
      return await FlutterFamilyControls.showAppPicker(
        title: title,
        cancelLabel: cancelLabel,
        saveLabel: saveLabel,
      );
    } catch (_) {
      return false;
    }
  }

  static Future<bool> enableRestrictions() async {
    try {
      return await FlutterFamilyControls.enableRestrictions();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> disableRestrictions() async {
    try {
      return await FlutterFamilyControls.disableRestrictions();
    } catch (_) {
      return false;
    }
  }

  static Future<int> getSelectedAppCount() async {
    try {
      return await FlutterFamilyControls.getSelectedAppCount();
    } catch (_) {
      return 0;
    }
  }

  static Future<bool> hasSelectedApps() async {
    try {
      return await FlutterFamilyControls.hasSelectedApps();
    } catch (_) {
      return false;
    }
  }
}
