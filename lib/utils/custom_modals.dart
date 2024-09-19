import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dormlanders/auth/landing_page.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';
import 'package:google_sign_in/google_sign_in.dart';

// DISPLAY DELETE WARNING MODAL
void showDeleteWarning(
    // PARAMETERS NEEDED
    BuildContext context,
    String textReminder,
    String textAction,
    Future Function(String) deleteActionCallback,
    String docID,
    ) {
  showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(10),
      ),
    ),
    context: context,
    isDismissible: true,
    backgroundColor: Colors.white,
    elevation: 0,
    builder: (context) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 5),
              child: Center(
                child: CustomTextDisplay(
                  receivedText: textReminder,
                  receivedTextSize: 14,
                  receivedTextWeight: FontWeight.normal,
                  receivedLetterSpacing: 0,
                  receivedTextColor: const Color(0xFF868686),
                ),
              ),
            ),
            const Divider(
              color: Color(0xFFF7F5F5),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await deleteActionCallback(docID);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE7E7E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: CustomTextDisplay(
                  receivedText: textAction,
                  receivedTextSize: 16,
                  receivedTextWeight: FontWeight.w500,
                  receivedLetterSpacing: 0,
                  receivedTextColor: const Color(0xFFe91b4f),
                ),
              ),
            ),
            Container(
              height: 10,
              color: const Color(0xFFF5F5F5),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE7E7E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const CustomTextDisplay(
                  receivedText: "Cancel",
                  receivedTextSize: 16,
                  receivedTextWeight: FontWeight.normal,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Color(0xFF3C3C40),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    },
  );
}

// DISPLAY MODAL BOTTOM SHEET LOGOUT
void showLogoutModal(BuildContext context) {
  showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(10),
      ),
    ),
    context: context,
    isDismissible: true,
    backgroundColor: Colors.white,
    elevation: 0,
    builder: (context) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 5),
              child: const Center(
                child: CustomTextDisplay(
                  receivedText: "Are you sure you want log out?",
                  receivedTextSize: 14,
                  receivedTextWeight: FontWeight.normal,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Color(0xFF868686),
                ),
              ),
            ),
            const Divider(
              color: Color(0xFFF7F5F5),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () async {
                  // LOG OUT, NAVIGATE TO LANDING PAGE AGAIN
                  final googleSignIn = GoogleSignIn();
                  await googleSignIn.signOut();
                  // Only attempt to disconnect if there is an active Google session
                  if (await googleSignIn.isSignedIn()) {
                    try {
                      await googleSignIn.disconnect(); // Disconnects the Google account fully
                    } catch (e) {
                      // If disconnect fails, log it and continue
                      debugPrint('Error disconnecting Google account: $e');
                    }
                  }

                  if(context.mounted) {
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const LandingPage();
                        },
                      ),
                          (_) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE7E7E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const CustomTextDisplay(
                  receivedText: "Sign out",
                  receivedTextSize: 16,
                  receivedTextWeight: FontWeight.w500,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Color(0xFFe91b4f),
                ),
              ),
            ),
            Container(
              height: 10,
              color: const Color(0xFFF5F5F5),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE7E7E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const CustomTextDisplay(
                  receivedText: "Cancel",
                  receivedTextSize: 16,
                  receivedTextWeight: FontWeight.normal,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Color(0xFF3C3C40),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    },
  );
}
