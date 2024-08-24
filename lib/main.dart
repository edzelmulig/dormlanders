import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mentalboost/auth/main_page.dart';
import 'package:mentalboost/colors.dart';
import 'firebase_options.dart';

// Main function of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
              cursorColor: Color(0xFF279778),
              selectionColor: Color(0xFF279778),
              selectionHandleColor: Color(0xFF279778),
            )
        ),
        home: const MainPage());
  }
}