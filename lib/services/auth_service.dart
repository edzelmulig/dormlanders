import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dormlanders/auth/dynamic_home_page.dart';
import 'package:dormlanders/auth/landing_page.dart';
import 'package:dormlanders/services/shared_preferences.dart';
import 'package:dormlanders/utils/custom_loading.dart';
import 'package:dormlanders/utils/custom_snackbar.dart';
import 'package:dormlanders/widgets/custom_alert_dialog.dart';

class AuthService {

  // SIGN IN AUTHENTICATION
  Future signIn({
    // PARAMETERS NEEDED
    required BuildContext context,
    required String email,
    required String password,
    required bool isChecked,
  }) async {

    try {
      // SHOW LOADING INDICATOR
      if (context.mounted) {
        showLoadingIndicator(context);
      }

      // SING IN WITH EMAIL AND PASSWORD
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // DISMISS LOADING INDICATOR
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // SAVE EMAIL AND PASSWORD IF "Remember Me" IS CHECKED
      if (isChecked) {
        await PreferenceService.saveCredentials(email.trim(), password.trim());
      }

      // NAVIGATE TO HOME PAGE AFTER SUCCESSFUL SIGN-IN
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const DynamicHomePage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException errors
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage =
            'Account not found. Please check your email and try again.';
      } else {
        errorMessage = 'Incorrect email or password. Please try again.';
      }

      // UPDATE ERROR MESSAGE
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }

      // DISMISS LOADING DIALOG
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle other errors
      debugPrint('Error signing in: $e');

      // DISPLAY ERROR MESSAGE TO THE USER
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error signing in: $e')));
      }

      // DISMISS LOADING DIALOG
      if (context.mounted) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      }
    }
  }

  // SIGN UP
  static Future signUp({
    // PARAMETERS NEEDED
    required BuildContext context,
    required String email,
    required String password,
    String displayName = '',
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String userType,
  }) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        // SHOW LOADING INDICATOR
        showLoadingIndicator(context);

        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'dummy': 'data',
        });

        // SAVE USER TO FIRESTORE
        if (displayName.isEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .collection('personal_information')
              .doc("info")
              .set({
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'email': email,
            'userType': userType,
          });
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .collection('personal_information')
              .doc("info")
              .set({
            'displayName': displayName,
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'email': email,
            'userType': userType,
          });
        }

        // DISMISS LOADING DIALOG
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        if (context.mounted) {
          showFloatingSnackBar(
            context,
            'Account created successfully.',
            const Color(0xFF193147),
          );
        }

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                return const LandingPage();
              },
            ),
          );
        }
      } catch (error) {
        // Show error to the user
        if (context.mounted) {
          Navigator.of(context).pop();
          showFloatingSnackBar(
            context,
            "Error signing up: ${error.toString()}",
            const Color(0xFFe91b4f),
          );
        }
      }
    }
  }

  // FORGOT PASSWORD
  Future passwordReset(BuildContext context, GlobalKey<FormState> formKey,
      TextEditingController forgotEmailController) async {
    if (formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: forgotEmailController.text.trim(),
        );

        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) {
            return CustomAlertDialog(
              message:
                  "A password reset email has been sent to your e-mail address.",
              backGroundColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const LandingPage();
                    },
                  ),
                );
              },
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        print(e);
      }
    }
  }
}
