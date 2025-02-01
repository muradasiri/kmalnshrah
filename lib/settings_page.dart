import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:vibration/vibration.dart';
import 'settings_provider.dart';
import 'package:flutter/material.dart';
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    void handleSwitchChange(bool value, Function(bool) toggleFunction) {
      if (settingsProvider.isVibrationEnabled) {
        Vibration.vibrate(duration: 50);
      }
      toggleFunction(value);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات التطبيق'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ميزة الديوانيات'),
                  IconButton(
                    icon: Icon(Icons.info_outline, color: settingsProvider.appColor),
                    onPressed: () {
                      _showDiwaniyaFeatureExplanation(context);
                    },
                  ),
                ],
              ),
              trailing: ToggleButtons(
                borderRadius: BorderRadius.circular(12),
                borderColor: settingsProvider.appColor,
                selectedBorderColor: settingsProvider.appColor,
                fillColor: settingsProvider.appColor.withOpacity(0.2),
                selectedColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                color: settingsProvider.appColor,
                isSelected: [
                  !settingsProvider.useWithoutDiwaniyaFeatures,
                  settingsProvider.useWithoutDiwaniyaFeatures
                ],
                onPressed: (int index) {
                  bool value = index == 1;
                  handleSwitchChange(value, settingsProvider.toggleUseWithoutDiwaniyaFeatures);
                },
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('مفعلة'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('معطلة'),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text('اختيار لون التطبيق'),
            leading: Icon(Icons.color_lens, color: Theme.of(context).primaryColor),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  Color currentColor = settingsProvider.appColor;
                  return AlertDialog(
                    title: Text('اختيار لون التطبيق'),
                    content: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildColorOption(
                            color: Color(0xFF6750A4),
                            isSelected: currentColor == Color(0xFF6750A4),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFF6750A4));
                              Navigator.pop(context);
                            },
                          ),
                          _buildColorOption(
                            color: Color(0xFFF0053C),
                            isSelected: currentColor == Color(0xFFF0053C),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFFF0053C));
                              Navigator.pop(context);
                            },
                          ),
                          _buildColorOption(
                            color: Color(0xFF03DAC6),
                            isSelected: currentColor == Color(0xFF03DAC6),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFF03DAC6));
                              Navigator.pop(context);
                            },
                          ),

                          _buildColorOption(
                            color: Color(0xFF2196F3),
                            isSelected: currentColor == Color(0xFF2196F3),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFF2196F3));
                              Navigator.pop(context);
                            },
                          ),
                          _buildColorOption(
                            color: Color(0xFF8BC34A),
                            isSelected: currentColor == Color(0xFF8BC34A),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFF8BC34A));
                              Navigator.pop(context);
                            },
                          ),
                          _buildColorOption(
                            color: Color(0xFFFF5722),
                            isSelected: currentColor == Color(0xFFFF5722),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFFFF5722));
                              Navigator.pop(context);
                            },
                          ),

                          _buildColorOption(
                            color: Color(0xFF607D8B),
                            isSelected: currentColor == Color(0xFF607D8B),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFF607D8B));
                              Navigator.pop(context);
                            },
                          ),
                          _buildColorOption(
                            color: Color(0xFFE91E63),
                            isSelected: currentColor == Color(0xFFE91E63),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFFE91E63));
                              Navigator.pop(context);
                            },
                          ),
                          _buildColorOption(
                            color: Color(0xFF9C27B0),
                            isSelected: currentColor == Color(0xFF9C27B0),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFF9C27B0));
                              Navigator.pop(context);
                            },
                          ),
                          _buildColorOption(
                            color: Color(0xFF4CAF50),
                            isSelected: currentColor == Color(0xFF4CAF50),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFF4CAF50));
                              Navigator.pop(context);
                            },
                          ),
                          _buildColorOption(
                            color: Color(0xFFFF9800),
                            isSelected: currentColor == Color(0xFFFF9800),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFFFF9800));
                              Navigator.pop(context);
                            },
                          ),
                          _buildColorOption(
                            color: Color(0xFF3F51B5),
                            isSelected: currentColor == Color(0xFF3F51B5),
                            onTap: () {
                              settingsProvider.changeAppColor(Color(0xFF3F51B5));
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
            value: settingsProvider.isNotificationsEnabled,
            onChanged: (bool value) async {
              handleSwitchChange(value, settingsProvider.toggleNotifications);
              if (value) {
                var status = await Permission.notification.request();
                if (status.isDenied || status.isPermanentlyDenied) {
                  settingsProvider.toggleNotifications(false);
                }
              }
            },
            activeColor: settingsProvider.appColor,
          ),
          SwitchListTile(
            title: Text('نطق النتيجة'),
            secondary: Icon(Icons.volume_up, color: Theme.of(context).primaryColor),
            value: settingsProvider.isResultSpeakingEnabled,
            onChanged: (bool value) {
              handleSwitchChange(value, settingsProvider.toggleResultSpeaking);
            },
            activeColor: settingsProvider.appColor,
          ),
          ListTile(
            title: Text('اختيار الصوت'),
            leading: Icon(Icons.record_voice_over, color: Theme.of(context).primaryColor),
            trailing: DropdownButton<String>(
              value: settingsProvider.isVoiceMale ? ' صوت 1' : ' صوت 2',
              onChanged: (String? newValue) {
                settingsProvider.toggleVoiceGender(newValue == ' صوت 1');
                if (settingsProvider.isVibrationEnabled) {
                  Vibration.vibrate(duration: 50);
                }
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
              handleSwitchChange(value, settingsProvider.toggleKeepScreenOn);
              if (value) {
                var status = await Permission.ignoreBatteryOptimizations.request();
                if (status.isDenied || status.isPermanentlyDenied) {
                  settingsProvider.toggleKeepScreenOn(false);
                }
              }
            },
            activeColor: settingsProvider.appColor,
          ),
          SwitchListTile(
            title: Text('الوضع الداكن'),
            secondary: Icon(Icons.nights_stay, color: settingsProvider.appColor),
            value: settingsProvider.isNightMode,
            onChanged: (bool value) {
              handleSwitchChange(value, settingsProvider.toggleNightMode);
            },
            activeColor: settingsProvider.appColor,
          ),
          SwitchListTile(
            title: Text('تشغيل الاهتزاز'),
            secondary: Icon(Icons.vibration, color: settingsProvider.appColor),
            value: settingsProvider.isVibrationEnabled,
            onChanged: (bool value) {
              handleSwitchChange(value, settingsProvider.toggleVibration);
            },
            activeColor: settingsProvider.appColor,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
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
                'إصدار التطبيق: 2.1.4',
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

  void _showDiwaniyaFeatureExplanation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('شرح ميزة تعطيل الديوانيات'),
          content: Text(
            'في حال عدم وجود انترنت أو حضور ضيف غير مسجل، استخدم حاسبة البلوت السريعة ودقة الولد السريعة لتجنب إضافة الضيف للديوانية وتجنب الخلط في النتائج!',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('تم'),
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
