import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dormlanders/utils/custom_loading.dart';
import 'package:dormlanders/utils/custom_snackbar.dart';
import 'package:dormlanders/services/provider_services.dart';

// FIREBASE SERVICES: CREATE, READ, UPDATE, DELETE (CRUD)
class FirebaseService {
  // CREATE: SERVICE OR ADD SERVICE
  static Future createService({
    // PARAMETERS NEEDED
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required bool isAvailable,
    required String serviceName,
    required String serviceDescription,
    required double price,
    required int maximumTenants,
    required int currentTenants,
    required int discount,
    required String dormKeyFeatures,
    PlatformFile? selectedImage,
    PlatformFile? kitchenView,
    PlatformFile? comfortRoomView,
    PlatformFile? bedRoomView,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      // DISPLAY LOADING DIALOG
      showLoadingIndicator(context);

      final userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) throw Exception("User not signed in");

      final String? selectedImageURL = await ProviderServices.uploadFile(selectedImage);
      final String? kitchenViewURL = await ProviderServices.uploadFile(kitchenView);
      final String? comfortRoomViewURL = await ProviderServices.uploadFile(comfortRoomView);
      final String? bedRoomViewURL = await ProviderServices.uploadFile(bedRoomView);


      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.uid)
          .collection('my_services')
          .add({
        'availability': isAvailable,
        'serviceName': serviceName,
        'serviceDescription': serviceDescription,
        'price': price,
        'maximumTenant': maximumTenants,
        'currentTenant': currentTenants,
        'discount': discount,
        'dormKeyFeatures': dormKeyFeatures,
        'imageURL': selectedImageURL,
        'kitchenView': kitchenViewURL,
        'comfortRoomView': comfortRoomViewURL,
        'bedRoomView': bedRoomViewURL,
      });

      // IF CREATING SERVICE SUCCESSFUL
      if (context.mounted) {
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
        showFloatingSnackBar(
          context,
          'Service created successfully.',
          const Color(0xFF193147),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // IF CREATING SERVICE FAILED
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error updating service: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
      }
    }
  }

  // READ: SERVICES
  static Future<Map<String, dynamic>> getUserServices(String serviceID) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final DocumentSnapshot userServicesSnapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(currentUser.uid)
          .collection("my_services")
          .doc(serviceID)
          .get();
      // RETURN SERVICE DATA AS MAP
      return userServicesSnapshot.data() as Map<String, dynamic>;
    }
    return {};
  }

  // UPDATE: SERVICE
  static Future updateService({
    // PARAMETERS NEEDED
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required bool isAvailable,
    required String serviceName,
    required String serviceDescription,
    required int maximumTenants,
    required int currentTenants,
    required double price,
    required int discount,
    required String dormKeyFeatures,
    required String serviceID,
    PlatformFile? selectedImage,
    PlatformFile? kitchenView,
    PlatformFile? comfortRoomView,
    PlatformFile? bedRoomView,
    String? oldImageURL,
    String? oldKitchenViewURL,
    String? oldComfortRoomViewURL,
    String? oldBedRoomViewURL,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      // DISPLAY LOADING DIALOG
      showLoadingIndicator(context);

      final userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) throw Exception("User not signed in");

      final String? downloadURL = await ProviderServices.uploadFile(
        selectedImage,
        oldImageURL: oldImageURL,
      );


      debugPrint("Front View URL: $downloadURL");


      final String? kitchenURL = await ProviderServices.uploadFile(
        kitchenView,
        oldImageURL: oldKitchenViewURL,
      );


      debugPrint("Kitchen View URL: $kitchenURL");


      final String? comfortRoomURL = await ProviderServices.uploadFile(
        comfortRoomView,
        oldImageURL: oldComfortRoomViewURL,
      );


      debugPrint("Comfort View URL: $comfortRoomURL");


      final String? bedRoomURL = await ProviderServices.uploadFile(
        bedRoomView,
        oldImageURL: oldBedRoomViewURL,
      );


      debugPrint("Bed Room View URL: $bedRoomURL");





      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.uid)
          .collection('my_services')
          .doc(serviceID)
          .update({
        'availability': isAvailable,
        'serviceName': serviceName,
        'serviceDescription': serviceDescription,
        'maximumTenant': maximumTenants,
        'currentTenant': currentTenants,
        'price': price,
        'discount': discount,
        'dormKeyFeatures': dormKeyFeatures,
        'imageURL': downloadURL ?? oldImageURL,
        'kitchenView': kitchenURL ?? oldKitchenViewURL,
        'comfortRoomView': comfortRoomURL ?? oldComfortRoomViewURL,
        'bedRoomView': bedRoomURL ?? oldBedRoomViewURL,
      });

      // IF ADDING SERVICE SUCCESSFUL
      if (context.mounted) {
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
        showFloatingSnackBar(
          context,
          'Service updated successfully.',
          const Color(0xFF193147),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // IF ADDING SERVICE FAILED
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error updating services: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
      }
    }
  }

  // DELETE: SERVICE
  static Future deleteService(BuildContext context, String docId) async {
    try {
      // Show loading dialog
      showLoadingIndicator(context);

      // Get the current user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Delete the service from the user's 'my_services' collection
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('my_services')
          .doc(docId);

      // GET THE DOCUMENT
      DocumentSnapshot doc = await docRef.get();
      if (doc.exists) {
        String? imagePath = doc['imageURL'];

        if (imagePath != null && imagePath.isNotEmpty) {
          // DELETE THE IMAGE FROM THE FIREBASE STORAGE
          await FirebaseStorage.instance.refFromURL(imagePath).delete();
        }
      }

      // DELETE THE SERVICE FROM USER'S my_services collection
      await docRef.delete();
      // IF ADDING SERVICE SUCCESSFUL
      if (context.mounted) {
        // DISMISS LOADING DIALOG
        if (context.mounted) Navigator.of(context).pop();
        showFloatingSnackBar(
          context,
          'Service deleted successfully.',
          const Color(0xFF193147),
        );
      }
    } catch (e) {
      // IF ADDING DELETING SERVICE IS FAILED
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "User not signed in",
          const Color(0xFFe91b4f),
        );
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
      }
    }
  }

  // CREATE: APPOINTMENT | SET APPOINTMENT
  static Future addAppointment({
    // PARAMETERS NEEDED
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required String clientID,
    required String providerID,
    required String serviceName,
    required String date,
    required String time,
    required PlatformFile? selectedImage,
    required String referenceNumber,
    String appointmentID = '',
  }) async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }

      // Show loading dialog
      showLoadingIndicator(context);
      if (providerID.isEmpty) throw Exception("User not signed in");

      final String? downloadURL = await ProviderServices.uploadReceipt(
        selectedImage,
      );

      final Timestamp appointmentTime = Timestamp.now();

      final appointmentDocRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(providerID)
          .collection('my_appointments')
          .add({
        'clientID': clientID,
        'serviceName': serviceName,
        'receiptImage': downloadURL,
        'appointmentDate': date,
        'appointmentTime': time,
        'appointmentStatus': 'new',
        'createdAt': appointmentTime,
        'appointmentID': appointmentID,
        'referenceNumber': referenceNumber,
      });

      final String returnAppointmentID = appointmentDocRef.id;
      print("========== $returnAppointmentID");

      // IF CREATING APPOINTMENT SUCCESSFUL
      if (context.mounted) {
        // Dismiss loading dialog
       Navigator.of(context).pop();
      }
      return returnAppointmentID;
    } catch(e) {
      // IF CREATING APPOINTMENT FAILED
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error updating service: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
      }
      return '';
    }
  }

  // UPDATE: APPOINTMENT | SET APPOINTMENT
  static Future updateAppointment({
    // PARAMETERS NEEDED
    required BuildContext context,
    required String appointmentID,
    required String providerID,
    required Map<String, dynamic> fieldsToUpdate,
  }) async {
    try {

      // Show loading dialog
      showLoadingIndicator(context);
      if (providerID.isEmpty) throw Exception("User not signed in");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(providerID)
          .collection('my_appointments')
          .doc(appointmentID)
          .update(fieldsToUpdate);

      // IF CREATING APPOINTMENT SUCCESSFUL
      if (context.mounted) {
        // CLOSE MODAL
        Navigator.of(context).pop();
      }
    } catch(e) {
      // IF CREATING APPOINTMENT FAILED
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error service: ${e.toString()}",
          const Color(0xFFe91b4f),
        );
        // Dismiss loading dialog
        if (context.mounted) Navigator.of(context).pop();
      }
    }
  }
}
