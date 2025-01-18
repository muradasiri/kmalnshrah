import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:vibration/vibration.dart';
import 'settings_provider.dart';
import 'rules_page.dart'; // استيراد صفحة القوانين

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات التطبيق'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('اختيار لون التطبيق'),
            leading: Icon(Icons.color_lens ,color: Theme.of(context).primaryColor),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  Color currentColor = settingsProvider.appColor;
                  return AlertDialog(
                    title: Text('اختيار لون التطبيق'),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildColorOption(
                            color: Color(0xFF6750A4), // #6750a4
                            isSelected: currentColor == Color(0xFF6750A4),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFF6750A4));
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(height: 10),
                          _buildColorOption(
                            color: Color(0xFFF0053C), // #f0053c
                            isSelected: currentColor == Color(0xFFF0053C),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFFF0053C));
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          SwitchListTile(
            title: Text('تلقي الإشعارات'),
            secondary: Icon(Icons.notifications, color: settingsProvider.appColor),
            value: settingsProvider.isNotificationsEnabled ?? false,
            onChanged: (bool value) async {
              settingsProvider.toggleNotifications(value);
              if (value) {
                var status = await Permission.notification.request();
                if (status.isDenied || status.isPermanentlyDenied) {
                  settingsProvider.toggleNotifications(false);
                }
              }
            },
          ),
          SwitchListTile(
            title: Text('نطق النتيجة'),
            secondary: Icon(Icons.volume_up, color:  Theme.of(context).primaryColor),
            value: settingsProvider.isResultSpeakingEnabled,
            onChanged: (bool value) {
              settingsProvider.toggleResultSpeaking(value);
            },
          ),
          ListTile(
            title: Text('اختيار الصوت'),
            leading: Icon(Icons.record_voice_over, color: Theme.of(context).primaryColor),
            trailing: DropdownButton<String>(
              value: settingsProvider.isVoiceMale ? ' صوت 1' : ' صوت 2',
              onChanged: (String? newValue) {
                settingsProvider.toggleVoiceGender(newValue == ' صوت 1');
              },
              items: <String>[' صوت 1', ' صوت 2'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          SwitchListTile(
            title: Text('خاصية عدم إطفاء الشاشة'),
            secondary: Icon(Icons.screen_lock_landscape, color: settingsProvider.appColor),
            value: settingsProvider.keepScreenOn,
            onChanged: (bool value) async {
              settingsProvider.toggleKeepScreenOn(value);
              if (value) {
                var status = await Permission.ignoreBatteryOptimizations.request();
                if (status.isDenied || status.isPermanentlyDenied) {
                  settingsProvider.toggleKeepScreenOn(false);
                }
              }
            },
          ),
          SwitchListTile(
            title: Text('تشغيل الوضع الليلي'),
            secondary: Icon(Icons.nights_stay, color: settingsProvider.appColor),
            value: settingsProvider.isNightMode,
            onChanged: (bool value) {
              settingsProvider.toggleNightMode(value);
            },
          ),
          SwitchListTile(
            title: Text('تشغيل الاهتزاز'),
            secondary: Icon(Icons.vibration, color: settingsProvider.appColor),
            value: settingsProvider.isVibrationEnabled,
            onChanged: (bool value) {
              settingsProvider.toggleVibration(value);
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.share,
            text: 'مشاركة التطبيق',
            onTap: () {
              _shareApp();
            },
          ),
          Divider(),
          // إضافة عنصر جديد لقوانين البلوت
          _buildSettingItem(
            context,
            icon: Icons.rule,
            text: 'قوانين البلوت',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BalootRulesPage()),
              );
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.info,
            text: 'عن التطبيق',
            onTap: () {
              _showAboutAppDialog();
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.contact_mail,
            text: 'تواصل معنا',
            onTap: () {
              _contactUs();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption({required Color color, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        onTap();
        if (Provider.of<SettingsProvider>(context, listen: false).isVibrationEnabled) {
          Vibration.vibrate(duration: 50);
        }
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
              ),
            ),
            SizedBox(width: 20),
            Text(
              isSelected ? 'محدد' : 'اختيار',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(text),
      onTap: () {
        onTap();
        if (Provider.of<SettingsProvider>(context, listen: false).isVibrationEnabled) {
          Vibration.vibrate(duration: 50);
        }
      },
    );
  }

  void _shareApp() async {
    final String appUrl = 'https://play.google.com/store/apps/details?id=kmalnshrah.murada.sa';
    final String message = 'أنصحك بتحميل تطبيق كم النشرة لحساب نشرة البلوت! $appUrl';
    try {
      await Share.share(message);
    } catch (e) {
      print('حدث خطأ أثناء محاولة مشاركة التطبيق: $e');
    }
  }

  void _contactUs() async {
    const url = 'https://kmalnshrah.murada.sa/contact/';
    await FlutterWebBrowser.openWebPage(url: url);
  }

  void _showAboutAppDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('عن التطبيق'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'تطبيق كم النشرة لحساب نشرة البلوت',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'تم تطوير هذا التطبيق لتسهيل حساب نشرة البلوت بطريقة دقيقة وموثوقة وأيضاً بإمكانك تدق الولد بين أخوياك بكل سهولة ويختار من الموزع بشكل عشوائي.',
              ),
              SizedBox(height: 10),
              Text(
                'إصدار التطبيق: 2.0.7',
              ),
              SizedBox(height: 10),
              Text(
                'تصميم وتطوير MuradAsiri',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('إغلاق'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
