import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:dormlanders/services/image_compression.dart';

// CLASS FOR PROVIDER'S SERVICES: SELECT IMAGE, UPLOAD IMAGE
class ProviderServices {
  // SELECT IMAGE
  static Future selectImage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    return result.files.first;
  }

  // UPLOAD IMAGE FOR SERVICES
  static Future uploadFile(
    PlatformFile? selectedImage, {
    String? oldImageURL,
  }) async {
    if (selectedImage == null || selectedImage.path == null) {
      return;
    }

    // COMPRESS THE IMAGE
    final File compressedImage = await compressImage(File(selectedImage.path!));

    final path =
        'serviceImages/${FirebaseAuth.instance.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}_${selectedImage.name}';
    final ref = FirebaseStorage.instance.ref().child(path);

    try {
      await ref.putFile(compressedImage);
      final String downloadURL = await ref.getDownloadURL();

      if (oldImageURL != null && oldImageURL.isNotEmpty) {
        final oldImageRef = FirebaseStorage.instance.refFromURL(oldImageURL);
        await oldImageRef.delete();
        debugPrint("Old image deleted successfully.");
      }
      return downloadURL;
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception during file upload: ${e.message}");
    } catch (e) {
      debugPrint("Error during file upload: $e");
    }
  }


  // UPLOAD IMAGE FOR APPOINTMENT
  static Future uploadReceipt(
      PlatformFile? selectedImage, {
        String? oldImageURL,
      }) async {
    if (selectedImage == null) {
      return;
    }

    // COMPRESS THE IMAGE
    final File compressedImage = await compressImage(File(selectedImage.path!));

    final path =
        'receiptImages/${FirebaseAuth.instance.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}_${selectedImage.name}';
    final ref = FirebaseStorage.instance.ref().child(path);

    try {
      await ref.putFile(compressedImage);
      final String downloadURL = await ref.getDownloadURL();

      if (oldImageURL != null && oldImageURL.isNotEmpty) {
        final oldImageRef = FirebaseStorage.instance.refFromURL(oldImageURL);
        await oldImageRef.delete();
        debugPrint("Old image deleted successfully.");
      }
      return downloadURL;
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception during file upload: ${e.message}");
    } catch (e) {
      debugPrint("Error during file upload: $e");
    }
  }
}

// CLASS THAT WILL HANDLE FETCHING FOR PROVIDER'S LOCATION
class FetchProviderLocation {
  Future getUserLocation(String serviceID) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final DocumentSnapshot userLocationSnapShot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(currentUser.uid)
          .collection("personal_information")
          .doc("location")
          .get();
      // RETURN SERVICE DATA AS MAP
      if (userLocationSnapShot.data() != null) {
        return userLocationSnapShot.data() as Map<String, dynamic>;
      } else {
        return <String, dynamic>{};
      }
    }
    return {};
  }
}
