import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:dormlanders/auth/landing_page.dart';
import 'package:dormlanders/client/client_navigation/client_navigation_bar.dart';
import 'package:dormlanders/service_providers/service_provider_navigation/provider_navigation_bar.dart';

class DynamicHomePage extends StatefulWidget {
  const DynamicHomePage({super.key});

  @override
  State<DynamicHomePage> createState() => _DynamicHomePage();
}

class _DynamicHomePage extends State<DynamicHomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('personal_information')
          .doc('info')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white.withOpacity(.8),
              ),
              width: 60,
              height: 60,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballScaleMultiple,
                colors: [Color(0xFF0D6D52)],
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('User data not found.'),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to landing page
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LandingPage(),
                      ),
                    );
                  },
                  child: const Text("Go to Login Page"),
                ),
              ],
            ),
          );
        }

        // Retrieve userType from the snapshot
        final userType = snapshot.data!.get('userType');

        // Check userType and navigate to the corresponding home page
        if (userType == 'Client') {
          return const ClientNavigationBar(); // Navigate to client home page
        } else if (userType == 'Provider') {
          return const ProviderNavigationBar(); // Navigate to service provider home page
        } else {
          // Handle unknown userType (if needed)
          return const Center(
            child: Text('Unknown user type'),
          );
        }
      },
    );
  }
}
