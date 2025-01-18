import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'diwaniya/models.dart';
import 'diwaniya/diwaniya_home.dart';
import 'DiwaniyaSelectionPage.dart';
import 'settings_page.dart';
import 'update_manager.dart';
import 'settings_provider.dart';
import 'baloot_calculator_page.dart';
import 'dakka_al_wald_page.dart';
import 'diwaniya/database.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSettings();
    UpdateManager.checkForUpdate(context);
    _loadDiwaniyat();
    _configureFirebaseListeners();
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
      Navigator.pushNamed(context, '/diwaniya_home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icon/mainbackground2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    Image.asset(
                      'assets/logo.png',
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
                SizedBox(height: 24.0),
                _buildStaggeredButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaggeredButtons(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _buildCard(
            context,
            icon: Icons.calculate,
            text: 'حاسبة بلوت',
            onTap: () async {
              if (diwaniyat.isEmpty) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiwaniyaSelectionPage(
                      localUserId: widget.localUserId,
                      nextPageBuilder: (diwaniyaId) => BalootCalculatorPage(localUserId: widget.localUserId, diwaniyaId: diwaniyaId),
                    ),
                  ),
                );
                _loadDiwaniyat();
              } else if (diwaniyat.length == 1) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BalootCalculatorPage(localUserId: widget.localUserId, diwaniyaId: diwaniyat.first.id),
                  ),
                );
              } else {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiwaniyaSelectionPage(
                      localUserId: widget.localUserId,
                      nextPageBuilder: (diwaniyaId) => BalootCalculatorPage(localUserId: widget.localUserId, diwaniyaId: diwaniyaId),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: _buildCard(
            context,
            icon: Icons.shuffle,
            text: 'دقة الولد',
            onTap: () async {
              if (diwaniyat.isEmpty) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiwaniyaSelectionPage(
                      localUserId: widget.localUserId,
                      nextPageBuilder: (diwaniyaId) => DakkaAlWaldPage(localUserId: widget.localUserId, diwaniyaId: diwaniyaId),
                    ),
                  ),
                );
                _loadDiwaniyat();
              } else if (diwaniyat.length == 1) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DakkaAlWaldPage(localUserId: widget.localUserId, diwaniyaId: diwaniyat.first.id),
                  ),
                );
              } else {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiwaniyaSelectionPage(
                      localUserId: widget.localUserId,
                      nextPageBuilder: (diwaniyaId) => DakkaAlWaldPage(localUserId: widget.localUserId, diwaniyaId: diwaniyaId),
                    ),
                  ),
                );
              }
            },
          ),
        ),
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
                    color: Theme.of(context).primaryColor,
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
