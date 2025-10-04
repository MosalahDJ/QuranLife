import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/Utils/binding.dart';
import 'core/localization/translations.dart';
import 'core/theme/thems.dart';
import 'features/controller/settings%20controllers/language_controller.dart';
import 'features/controller/settings%20controllers/theme_controller.dart';
import 'features/view/splash%20page/splash_view.dart';
import 'myrouts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

// messaging background handler

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Force portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    dotenv.load(fileName: ".env"),
  ]);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  if (kReleaseMode) {
    await SentryFlutter.init((options) {
      options.dsn =
          'https://ffbe2284578ddb220992bfafac17ac6c@o4508945405313024.ingest.de.sentry.io/4508945417371728';
    }, appRunner: () => runApp(SentryWidget(child: QuranLifeApp(prefs: prefs))));
  } else {
    runApp(QuranLifeApp(prefs: prefs));
  }
}

class QuranLifeApp extends StatelessWidget {
  final SharedPreferences prefs;
  const QuranLifeApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put<ThemeController>(
      ThemeController(),
      permanent: true,
    );
    final languageController = Get.put<LanguageController>(
      LanguageController(prefs),
      permanent: true,
    );

    return GetMaterialApp(
      title: 'QuranLife',

      theme: Themes().lightmode,
      darkTheme: Themes().darkmode,
      //using thememode for changing theme whene user change selected theme value
      themeMode:
          themeController.selectedTheme.value == AppTheme.system
              ? ThemeMode.system
              : themeController.selectedTheme.value == AppTheme.light
              ? ThemeMode.light
              : ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      initialBinding: Mybinding(),
      home: const SplashView(),
      getPages: Myrouts.getpages,
      translations: Messages(),
      locale: Locale(languageController.language.value), // Use stored language
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}



// I make an appeale for my fucking google play account  because it's banned by 
//the fucking google play team anyway fuck them bacause they'r all bitches 
// if they think this fucking move will make me disapointment , so they just a 
//fucking dankeys I'am here befor and I'm here now and also I'll be here tomorow
//because I belive in my god and I belive with my work and you will can't ever 
//ever , never stop me go to the hell all of you I will upgrade myself and I 
//will find a solotion for every problem you apeare it to me and I'll be one of 
//the best in one day because simply I'am instopable , I have a dream and of 
//caurse I will find my dream I will folow them in the last of the world , fuck 
//all bitches and no thanks no zabi