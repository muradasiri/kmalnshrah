import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'diwaniya/database.dart';
import 'diwaniya/models.dart';
import 'diwaniya/diwaniya_home.dart';
import 'DiwaniyaSelectionPage.dart';
import 'settings_page.dart';
import 'update_manager.dart';
import 'settings_provider.dart';
import 'baloot_calculator_page.dart';
import 'dakka_al_wald_page.dart';
import 'quickcalculatorpage.dart';
import 'quickdakkapage.dart';
import 'package:vibration/vibration.dart';

class HomePage extends StatefulWidget {
  final String localUserId;

  HomePage({required this.localUserId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isVoiceOn = true;
  bool isMaleVoice = true;
  bool keepScreenOn = false;
  bool isNotificationsEnabled = true;
  List<Diwaniya> diwaniyat = [];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String selectedGame = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSelectedGame();
    UpdateManager.checkForUpdate(context);
    _loadDiwaniyat();
    _configureFirebaseListeners();
    _checkConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _handleConnectivityChange(result);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _loadSelectedGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGame = prefs.getString('selectedGame') ?? 'baloot';
    });
  }

  void _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _handleConnectivityChange(connectivityResult);
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    if (result == ConnectivityResult.none) {
      settingsProvider.toggleUseWithoutDiwaniyaFeatures(true);
      _showConnectivityDialog('لا يوجد اتصال بالإنترنت', 'تم تفعيل وضع تعطيل مميزات الديوانيات.');
    } else {
      if (settingsProvider.wasDisconnected) { // التحقق من الانقطاع السابق
        settingsProvider.toggleUseWithoutDiwaniyaFeatures(false);
        _showConnectivityDialog('تم استعادة الاتصال بالإنترنت', 'تم إعادة تفعيل مميزات الديوانيات.');
      }
    }
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isVoiceOn = prefs.getBool('isResultSpeakingEnabled') ?? true;
      isMaleVoice = prefs.getBool('isVoiceMale') ?? true;
      keepScreenOn = prefs.getBool('isScreenOn') ?? false;
      isNotificationsEnabled = prefs.getBool('isNotificationsEnabled') ?? true;
      WakelockPlus.toggle(enable: keepScreenOn);
      if (prefs.getBool('isVibrationEnabled') ?? false) {
        Vibration.vibrate(duration: 100);
      }
    });
  }

  Future<void> _loadDiwaniyat() async {
    diwaniyat = await DatabaseService().getDiwaniyatForUserOnce(widget.localUserId);
    setState(() {});
  }

  void _configureFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(context, '/HomePage');
    });
  }

  void _showDiwaniyaSelectionSheet(BuildContext context, String page) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return DiwaniyaSelectionPage(
          localUserId: widget.localUserId,
          nextPageBuilder: (diwaniyaId) {
            if (page == 'BalootCalculatorPage') {
              return BalootCalculatorPage(localUserId: widget.localUserId, diwaniyaId: diwaniyaId);
            } else if (page == 'DakkaAlWaldPage') {
              return DakkaAlWaldPage(localUserId: widget.localUserId, diwaniyaId: diwaniyaId);

            } else {
              return Container();
            }
          },
        );
      },
    );
  }

  void _showConnectivityDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('تم'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDarkMode = settingsProvider.isNightMode; // Use manual night mode setting
    final useWithoutDiwaniyaFeatures = settingsProvider.useWithoutDiwaniyaFeatures;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(isDarkMode ? 'assets/icon/background_dark.png' : 'assets/icon/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Image.asset(
                          isDarkMode ? 'assets/logo_wellcome_dark.png' : 'assets/logo_wellcome.png',
                          height: 100.0,
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'كم النشرة',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      ' الديوانيات',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(12),
                      borderColor: settingsProvider.appColor,
                      selectedBorderColor: settingsProvider.appColor,
                      fillColor: settingsProvider.appColor.withOpacity(0.2),
                      selectedColor: isDarkMode ? Colors.white : Colors.black,
                      color: settingsProvider.appColor,
                      isSelected: [
                        !settingsProvider.useWithoutDiwaniyaFeatures,
                        settingsProvider.useWithoutDiwaniyaFeatures
                      ],
                      onPressed: (int index) {
                        bool value = index == 1;
                        if (settingsProvider.isVibrationEnabled) {
                          Vibration.vibrate(duration: 25);
                        }
                        settingsProvider.toggleUseWithoutDiwaniyaFeatures(value);
                        setState(() {});
                      },
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('مفعلة'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('معطلة'),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.0),

                  ],
                ),
              ),
              SizedBox(height: 1.0),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 4.0),
                      _buildStaggeredButtons(context, useWithoutDiwaniyaFeatures),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredButtons(BuildContext context, bool useWithoutDiwaniyaFeatures) {
    return Column(
      children: [
        if (selectedGame == 'baloot' && !useWithoutDiwaniyaFeatures)
          Align(
            alignment: Alignment.centerRight,
            child: _buildCard(
              context,
              icon: Icons.calculate,
              text: 'حاسبة بلوت',
              onTap: () async {
                if (diwaniyat.isEmpty) {
                  _showDiwaniyaSelectionSheet(context, 'BalootCalculatorPage');
                  _loadDiwaniyat();
                } else if (diwaniyat.length == 1) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BalootCalculatorPage(localUserId: widget.localUserId, diwaniyaId: diwaniyat.first.id),
                    ),
                  );
                } else {
                  _showDiwaniyaSelectionSheet(context, 'BalootCalculatorPage');
                }
              },
            ),
          ),
        if (selectedGame == 'baloot' && useWithoutDiwaniyaFeatures)
          Align(
            alignment: Alignment.centerLeft,
            child: _buildCard(
              context,
              icon: Icons.calculate,
              text: 'حاسبة بلوت سريعة',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuickCalculatorPage(),
                  ),
                );
              },
            ),
          ),
        if (selectedGame == 'baloot' && !useWithoutDiwaniyaFeatures)
          Align(
            alignment: Alignment.centerLeft,
            child: _buildCard(
              context,
              icon: Icons.shuffle,
              text: 'دقة الولد',
              onTap: () async {
                if (diwaniyat.isEmpty) {
                  _showDiwaniyaSelectionSheet(context, 'DakkaAlWaldPage');
                  _loadDiwaniyat();
                } else if (diwaniyat.length == 1) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DakkaAlWaldPage(localUserId: widget.localUserId, diwaniyaId: diwaniyat.first.id),
                    ),
                  );
                } else {
                  _showDiwaniyaSelectionSheet(context, 'DakkaAlWaldPage');
                }
              },
            ),
          ),
        if (selectedGame == 'baloot' && useWithoutDiwaniyaFeatures)
          Align(
            alignment: Alignment.centerLeft,
            child: _buildCard(
              context,
              icon: Icons.shuffle,
              text: 'دقة الولد سريعة',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuickDakkaPage(),
                  ),
                );
              },
            ),
          ),

        if (!useWithoutDiwaniyaFeatures)
          Align(
            alignment: Alignment.centerRight,
            child: _buildCard(
              context,
              icon: Icons.group,
              text: 'الديوانيات',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiwaniyaHome(localUserId: widget.localUserId),
                  ),
                );
              },
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: _buildCard(
            context,
            icon: Icons.settings,
            text: 'إعدادات التطبيق',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        onTap();
        if (Provider.of<SettingsProvider>(context, listen: false).isVibrationEnabled) {
          Vibration.vibrate(duration: 50);
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 40.0, color: Theme.of(context).primaryColor),
              SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20.0, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
