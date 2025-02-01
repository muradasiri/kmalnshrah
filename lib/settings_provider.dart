import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isVoiceMale = true;
  bool _isScreenOn = false;
  bool _isResultSpeakingEnabled = true;
  bool _isNotificationsEnabled = false;
  Color _appColor = Color(0xFFF0053C);
  bool _keepScreenOn = false;
  bool _isNightMode = true; // Default to true for night mode
  bool _isVibrationEnabled = true; // Default to true for vibration
  bool _isManualNightMode = true; // Default to manual mode
  bool _useWithoutDiwaniyaFeatures = false;
  bool _wasDisconnected = false; // تتبع حالة الانقطاع السابقة

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool get keepScreenOn => _keepScreenOn;
  bool get isVoiceMale => _isVoiceMale;
  bool get isScreenOn => _isScreenOn;
  bool get isResultSpeakingEnabled => _isResultSpeakingEnabled;
  bool get isNotificationsEnabled => _isNotificationsEnabled;
  Color get appColor => _appColor;
  bool get isNightMode => _isNightMode;
  bool get isVibrationEnabled => _isVibrationEnabled;
  bool get isManualNightMode => _isManualNightMode;
  bool get useWithoutDiwaniyaFeatures => _useWithoutDiwaniyaFeatures;
  bool get wasDisconnected => _wasDisconnected; // إضافة Getter للوصول إلى المتغير

  SettingsProvider() {
    _loadSettings();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _handleConnectivityChange(result);
    });
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isVoiceMale = prefs.getBool('isVoiceMale') ?? true;
    _isScreenOn = prefs.getBool('isScreenOn') ?? false;
    _isResultSpeakingEnabled = prefs.getBool('isResultSpeakingEnabled') ?? true;
    _isNotificationsEnabled = prefs.getBool('isNotificationsEnabled') ?? false;
    _appColor = Color(prefs.getInt('appColor') ?? Color(0xFFF0053C).value);
    _keepScreenOn = prefs.getBool('keepScreenOn') ?? false;
    _isNightMode = prefs.getBool('isNightMode') ?? true; // Default to night mode
    _isVibrationEnabled = prefs.getBool('isVibrationEnabled') ?? true; // Default to true for vibration
    _isManualNightMode = prefs.getBool('isManualNightMode') ?? true;
    _useWithoutDiwaniyaFeatures = prefs.getBool('useWithoutDiwaniyaFeatures') ?? false;

    if (_isScreenOn) WakelockPlus.enable(); else WakelockPlus.disable();
    _configureFirebaseMessaging();
    notifyListeners();
  }

  void _configureFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (_isNotificationsEnabled) {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
        toggleNotifications(false);
      }
    } else {
      messaging.deleteToken();
    }
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isVoiceMale', _isVoiceMale);
    prefs.setBool('isScreenOn', _isScreenOn);
    prefs.setBool('isResultSpeakingEnabled', _isResultSpeakingEnabled);
    prefs.setBool('isNotificationsEnabled', _isNotificationsEnabled);
    prefs.setInt('appColor', _appColor.value);
    prefs.setBool('keepScreenOn', _keepScreenOn);
    prefs.setBool('isNightMode', _isNightMode);
    prefs.setBool('isVibrationEnabled', _isVibrationEnabled);
    prefs.setBool('isManualNightMode', _isManualNightMode);
    prefs.setBool('useWithoutDiwaniyaFeatures', _useWithoutDiwaniyaFeatures);
  }

  void toggleVoiceGender(bool isMale) {
    _isVoiceMale = isMale;
    _saveSettings();
    notifyListeners();
  }

  void toggleScreenOn(bool isOn) {
    _isScreenOn = isOn;
    if (isOn) WakelockPlus.enable(); else WakelockPlus.disable();
    _saveSettings();
    notifyListeners();
  }

  void toggleResultSpeaking(bool isEnabled) {
    _isResultSpeakingEnabled = isEnabled;
    _saveSettings();
    notifyListeners();
  }

  void toggleNotifications(bool isEnabled) {
    _isNotificationsEnabled = isEnabled;
    _saveSettings();
    _configureFirebaseMessaging();
    notifyListeners();
  }

  void changeAppColor(Color color) {
    _appColor = color;
    _saveSettings();
    notifyListeners();
  }

  void toggleNightMode(bool isEnabled) {
    _isNightMode = isEnabled;
    _isManualNightMode = true;
    _saveSettings();
    notifyListeners();
  }

  void toggleVibration(bool isEnabled) {
    _isVibrationEnabled = isEnabled;
    _saveSettings();
    notifyListeners();
  }

  void toggleKeepScreenOn(bool value) async {
    _keepScreenOn = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('keepScreenOn', value);
    WakelockPlus.toggle(enable: value);
    notifyListeners();
  }

  void toggleUseWithoutDiwaniyaFeatures(bool value) async {
    _useWithoutDiwaniyaFeatures = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('useWithoutDiwaniyaFeatures', value);
    notifyListeners();
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _wasDisconnected = true; // تم الانقطاع
      toggleUseWithoutDiwaniyaFeatures(true);
      print('No internet connection, Diwaniya features disabled.');
    } else {
      if (_wasDisconnected) {
        toggleUseWithoutDiwaniyaFeatures(false);
        print('Internet connection restored, Diwaniya features enabled.');
        // تم استعادة الاتصال بعد انقطاع
        notifyListeners();
        _wasDisconnected = false; // إعادة تعيين الحالة
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
