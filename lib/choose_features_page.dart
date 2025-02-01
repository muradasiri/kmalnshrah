import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'diwaniya/diwaniya_home.dart';
import 'home_page.dart';
import 'settings_provider.dart';

class ChooseFeaturesPage extends StatelessWidget {
  final String localUserId;

  ChooseFeaturesPage({required this.localUserId});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDarkMode = settingsProvider.isNightMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('اختر المميزات'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group, size: 40, color: settingsProvider.appColor),
                  SizedBox(height: 20),
                  Text(
                    'هل ترغب في تفعيل ميزة الديوانيات؟',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: settingsProvider.appColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'ميزة الديوانيات تتيح للمستخدم إضافة عدد غير محدود من الديوانيات، وكل ديوانية تحتوي على عدد غير محدود من الأعضاء. يمكن عرض اللاعبين في كل ديوانية مع عرض عدد انتصاراتهم وهزائمهم وترتيبهم على مستوى الديوانية من الأول إلى الثالث، بالإضافة إلى الأوسمة وغيرها من المعلومات. كما يتم حفظ أرشيف الصكات وإتاحة إضافة ديوانيات أنشأها مستخدمون آخرون، مع إمكانية عرض نتائج الأعضاء وسجل النشرات. في حال عدم تفعيل ميزة الديوانيات، سيتم عرض حاسبة بلوت سريعة ودقة الولد السريعة دون حفظها على الخادم.',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black87),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('diwaniyaEnabled', true);
                          settingsProvider.toggleUseWithoutDiwaniyaFeatures(false); // تفعيل ميزة الديوانيات
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(localUserId: localUserId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: settingsProvider.appColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        icon: Icon(Icons.check, color: Colors.white),
                        label: Text('نعم', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('diwaniyaEnabled', false);
                          settingsProvider.toggleUseWithoutDiwaniyaFeatures(true); // تعطيل ميزة الديوانيات
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(localUserId: localUserId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: settingsProvider.appColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        icon: Icon(Icons.close, color: Colors.white),
                        label: Text('لا', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
