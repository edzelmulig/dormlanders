import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  // Method to handle user logout
  Future<void> _logout() async {
    try {
      // Sign out from FirebaseAuth
      await FirebaseAuth.instance.signOut();

      // Sign out from Google to remove the cached session
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Ensure cached Google credentials are cleared
      // Only attempt to disconnect if there is an active Google session
      if (await googleSignIn.isSignedIn()) {
        try {
          await googleSignIn.disconnect(); // Disconnects the Google account fully
        } catch (e) {
          // If disconnect fails, log it and continue
          debugPrint('Error disconnecting Google account: $e');
        }
      }


      // Navigate back to the LandingPage
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LandingPage(),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  // Method to register user with only name and email as 'Tenant'
  Future<void> _registerUser() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('personal_information')
          .doc('info')
          .set({
        'firstName': user.displayName ?? 'Tenant', // Use displayName or fallback to 'Tenant'
        'lastName': '-', // Dummy last name
        'phoneNumber': '0000000000', // Dummy phone number
        'userType': 'Tenant', // Set user type as Tenant
        'email': user.email, // Use FirebaseAuth email
      });
    } catch (e) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
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
                  colors: [Color(0xFF193147)],
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
            // If the user data does not exist, register the user with minimal data
            _registerUser();

            // Retrieve user email and name from FirebaseAuth
            final String email = user.email ?? 'No Email';
            final String displayName = user.displayName ?? 'No Name';

            // Display user information and 'User data not found' message
            return Center(
              child: SizedBox(
                width: 100, // Adjust the size as needed
                height: 100, // Adjust the size as needed
                child: Image.asset(
                  'images/searching_icon.png', // Path to your local GIF
                  fit: BoxFit.cover,
                ),
              ),
            );
          }

          // Retrieve userType from the snapshot
          final userType = snapshot.data!.get('userType');

          // Delay navigation to the corresponding home page until after the build
          Future.microtask(() {
            if (userType == 'Tenant') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ClientNavigationBar(),
                ),
              );
            } else if (userType == 'Owner') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ProviderNavigationBar(),
                ),
              );
            } else {
              // Handle unknown userType (if needed)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unknown user type')),
              );
            }
          });

          // Return a temporary screen while navigating
          return Center(
            child: SizedBox(
              width: 100, // Adjust the size as needed
              height: 100, // Adjust the size as needed
              child: Image.asset(
                'images/searching_icon.png', // Path to your local GIF
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
