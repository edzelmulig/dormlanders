import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:dormlanders/services/provider_services.dart';

class UserLocationService {
  // LOCATION CONTROLLER
  final Location _locationController = Location();

  // FETCH LOCATION DATA FROM FIRESTORE
  Future<Map<String, dynamic>?> getUserLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    Map<String, dynamic>? locationData;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    final userCredential = FirebaseAuth.instance.currentUser;
    final data = await FetchProviderLocation().getUserLocation(userCredential!.uid);
    if (data != null && data.isNotEmpty) {
      locationData = {
        'latitude': data['latitude'] as double?,
        'longitude': data['longitude'] as double?,
        'additionalInstructions': data['additionalInstructions'],
        'placeDetails': data['placeDetails']
      };
    }
    return locationData;
  }


  // GET CURRENT LOCATION OF THE USER
  Future<LatLng?> getCurrentLocation() async {
    try {
      LocationData currentLocation = await _locationController.getLocation();
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        return LatLng(currentLocation.latitude!, currentLocation.longitude!);
      }
    } catch (e) {
      // Handle exceptions, possibly by showing an error or logging
      print("Could not fetch the current location: $e");
    }
    return null; // Return null if location is not available or in case of an error
  }


}