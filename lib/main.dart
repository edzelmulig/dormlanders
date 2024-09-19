import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dormlanders/auth/main_page.dart';
import 'package:dormlanders/colors.dart';
import 'firebase_options.dart';

// Main function of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity, // or SafetyNet
    appleProvider: AppleProvider.deviceCheck, // For iOS
  );

  runApp(const MyApp());
}

// Handles the navigation to landing page.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: mentalboosttheme,
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Color(0xFF193147),
              selectionColor: Color(0xFF193147),
              selectionHandleColor: Color(0xFF193147),
            )
        ),
        home: const MainPage());
  }
}