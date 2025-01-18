import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'diwaniya/add_diwaniya.dart';
import 'diwaniya/diwaniya_home.dart';
import 'home_page.dart';
import 'settings_provider.dart';
import 'dakka_al_wald_page.dart';
import 'update_manager.dart';
import 'baloot_calculator_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'diwaniya/player_provider.dart';
import 'notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? localUserId = prefs.getString('localUserId');

  if (localUserId == null) {
    localUserId = Uuid().v4();  // Generate a random UUID
    await prefs.setString('localUserId', localUserId);
  }

  await NotificationService.initialize(); // Initialize notifications

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: KmalnshrahApp(localUserId: localUserId!),
    ),
  );
}

class KmalnshrahApp extends StatelessWidget {
  final String localUserId;

  KmalnshrahApp({required this.localUserId});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        if (settingsProvider.keepScreenOn) {
          WakelockPlus.enable();
        } else {
          WakelockPlus.disable();
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('ar'),
              const Locale('en'),
            ],
            locale: Locale('ar'),
            theme: settingsProvider.isNightMode
                ? ThemeData.dark().copyWith(
              primaryColor: settingsProvider.appColor,
              hintColor: settingsProvider.appColor,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textTheme: TextTheme(
                bodyLarge: TextStyle(fontFamily: 'Tajawal'),
                bodyMedium: TextStyle(fontFamily: 'Tajawal'),
              ),
            )
                : ThemeData(
              fontFamily: 'Tajawal',
              primaryColor: settingsProvider.appColor,
              hintColor: settingsProvider.appColor,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: HomePage(localUserId: localUserId),
            routes: {
              '/Diwaniya': (context) => AddDiwaniya(localUserId: localUserId),
              '/diwaniya_home': (context) => DiwaniyaHome(localUserId: localUserId), // تعديل هنا
            },
          ),
        );
      },
    );
  }
}
