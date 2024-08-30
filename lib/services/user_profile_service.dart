import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:dormlanders/services/image_compression.dart';
import 'package:dormlanders/utils/custom_snackbar.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // FETCH AND DISPLAY REALTIME CHANGES OF USER DATA FROM FIRESTORE
  Stream<Map<String, dynamic>> getUserDataStream() {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('personal_information')
          .doc('info')
          .snapshots()
          .map((snapshot) => snapshot.data() ?? {});
    } else {
      // Return an empty stream if there is no user logged in
      return Stream.value({});
    }
  }

  // FETCH USER DATA FROM FIRESTORE
  Future<Map<String, dynamic>> getUserData(
    // PARAMETERS NEEDED
    String userID,
    String collectionName,
    String documentName,
  ) async {
    final userData = await _firestore
        .collection('users')
        .doc(userID)
        .collection(collectionName)
        .doc(documentName)
        .get();
    return userData.data() ?? {};
  }

  // UPDATE USER PROFILE
  static Future<void> updateProfileImage(String downloadURL) async {
    try {
      final userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential != null && userCredential.uid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.uid)
            .collection('personal_information')
            .doc('info')
            .set(
          {
            'imageURL': downloadURL, // The new imageURL you want to add
          },
          SetOptions(merge: true),
        ); // Use merge option to only update imageURL without overwriting other fields
        debugPrint("Image URL updated successfully in Firestore.");
      }
    } on FirebaseException catch (firebaseEx) {
      debugPrint("Firebase Exception: ${firebaseEx.message}");
    } catch (e) {
      debugPrint("Error updating imageURL in Firestore: $e");
    }
  }

  // UPDATE USER DATA/INFORMATION
  static void updateProfileData(
    BuildContext context,
    GlobalKey<FormState> formKey, {
    TextEditingController? displayNameController,
    TextEditingController? firstNameController,
    TextEditingController? lastNameController,
    TextEditingController? phoneNumberController,
    TextEditingController? emailController,
    TextEditingController? accountNameController,
    TextEditingController? accountNumberController,
  }) async {
    // ENSURE THAT THE FORM IS VALID
    if (formKey.currentState!.validate()) {
      try {
        // GET THE CURRENT USER FROM FIREBASE AUTHENTICATION
        final currentUser = FirebaseAuth.instance.currentUser;
        // MAKING SURE THAT USER IS SIGN IN
        if (currentUser != null) {
          Map<String, dynamic> dataToUpdate = {};
          if (displayNameController != null) {
            dataToUpdate['displayName'] = displayNameController.text.trim();
          }
          if (firstNameController != null) {
            dataToUpdate['firstName'] = firstNameController.text.trim();
          }
          if (lastNameController != null) {
            dataToUpdate['lastName'] = lastNameController.text.trim();
          }
          if (phoneNumberController != null) {
            dataToUpdate['phoneNumber'] = phoneNumberController.text.trim();
          }
          if (emailController != null) {
            dataToUpdate['email'] = emailController.text.trim();
          }
          if (accountNameController != null) {
            dataToUpdate['accountName'] = accountNameController.text.trim();
          }
          if (accountNumberController != null) {
            dataToUpdate['accountNumber'] = accountNumberController.text.trim();
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('personal_information')
              .doc('info')
              .update(dataToUpdate);

          // Show a success message or navigate to another screen
          if (context.mounted) {
            showFloatingSnackBar(
              context,
              'Data updated successfully.',
              const Color(0xFF193147),
            );
          }
        } else {
          // Handle the case where the user is not signed in
          showFloatingSnackBar(
            context,
            "User not signed in",
            const Color(0xFFe91b4f),
          );
        }
      } catch (error) {
        // Show an error message if the update fails
        if (context.mounted) {
          showFloatingSnackBar(
            context,
            "Failed to update: $error",
            const Color(0xFFe91b4f),
          );
        }
      }
    }
  }

  // SELECT PROFILE IMAGE
  static Future selectImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    return result;
  }

  // UPLOAD PROFILE IMAGE
  static Future uploadFile(
      PlatformFile? selectedImage, String? oldImage) async {
    // CHECK FIRST IF THERE IS AN IMAGE TO UPLOAD
    if (selectedImage == null) {
      return;
    }

    // COMPRESS THE IMAGE
    final File compressedImage = await compressImage(File(selectedImage.path!));

    // DEFINE THE STORAGE PATH
    final path = 'profileImages/'
        '${FirebaseAuth.instance.currentUser!.uid}'
        '_${DateTime.now().millisecondsSinceEpoch}'
        '_${selectedImage.name}';

    //final file = File(selectedImage.path!);
    final ref = FirebaseStorage.instance.ref().child(path);

    try {
      await ref.putFile(compressedImage);
      final String downloadURL = await ref.getDownloadURL();

      // Delete the old image from Firebase Storage, if it exists
      if (oldImage != null && oldImage.isNotEmpty) {
        final oldImageRef = FirebaseStorage.instance.refFromURL(oldImage);
        await oldImageRef.delete();
      }

      return downloadURL;
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception during file upload: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Error during file upload: $e");
      return null;
    }
  }
}
