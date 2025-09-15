import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_verynew/firebase_options.dart';
import 'package:todo_verynew/home/home_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await requestNotificationPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if(!kIsWeb){
    await  setupFlutterNotifications();
  }
   print("FMC token : ${ await FirebaseMessaging.instance.getToken()}");
  runApp(const MyApp());
}

Future<void> requestNotificationPermission() async{
  await Permission.notification.request();
}

Future<void> setupFlutterNotifications() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await setupFlutterNotifications();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Todo VeryNew',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          // home: const SteamEx(),
          home: const HomePage(),
        );
      },
    );
  }
}


