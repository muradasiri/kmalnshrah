import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isVoiceMale = true;
  bool _isScreenOn = false;
  bool _isResultSpeakingEnabled = true;
  bool _isNotificationsEnabled = false;
  Color _appColor = Color(0xFFF0053C);
  bool _keepScreenOn = false;
  bool _isNightMode = true; // Default to true for night mode
  bool _isVibrationEnabled = false;

  bool get keepScreenOn => _keepScreenOn;
  bool get isVoiceMale => _isVoiceMale;
  bool get isScreenOn => _isScreenOn;
  bool get isResultSpeakingEnabled => _isResultSpeakingEnabled;
  bool get isNotificationsEnabled => _isNotificationsEnabled;
  Color get appColor => _appColor;
  bool get isNightMode => _isNightMode;
  bool get isVibrationEnabled => _isVibrationEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isVoiceMale = prefs.getBool('isVoiceMale') ?? true;
    _isScreenOn = prefs.getBool('isScreenOn') ?? false;
    _isResultSpeakingEnabled = prefs.getBool('isResultSpeakingEnabled') ?? true;
    _isNotificationsEnabled = prefs.getBool('isNotificationsEnabled') ?? false;
    _appColor = Color(prefs.getInt('appColor') ?? Color(0xFFF0053C).value);
    _keepScreenOn = prefs.getBool('keepScreenOn') ?? false;
    _isNightMode = prefs.getBool('isNightMode') ?? true;
    _isVibrationEnabled = prefs.getBool('isVibrationEnabled') ?? false;

    if (_isScreenOn) WakelockPlus.enable(); else WakelockPlus.disable();
    notifyListeners();
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
    notifyListeners();
  }

  void changeAppColor(Color color) {
    _appColor = color;
    _saveSettings();
    notifyListeners();
  }

  void toggleNightMode(bool isEnabled) {
    _isNightMode = isEnabled;
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
}
