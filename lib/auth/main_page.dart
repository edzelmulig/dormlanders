import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dormlanders/auth/dynamic_home_page.dart';
import 'package:dormlanders/auth/landing_page.dart';

// This will check the if user is login or not
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const DynamicHomePage();
          } else {
            return const LandingPage();
          }
        },
      ),
    );
  }
}
