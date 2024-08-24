import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dormlanders/models/provider_model.dart';
import 'package:dormlanders/services/user_profile_service.dart';
import 'package:dormlanders/utils/location_utils.dart';

class ClientServices {
  // FETCH ALL THE SERVICE PROVIDERS
  static Future<List<ServiceProvider>> fetchAllProviders(
    double clientLatitudeValue,
    double clientLongitudeValue,
  ) async {
    List<ServiceProvider> allUserData = [];
    try {
      debugPrint("CLIENT SERVICES!!!");
      final userQuerySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      if (userQuerySnapshot.docs.isNotEmpty) {
        for (var userDoc in userQuerySnapshot.docs) {
          String userID = userDoc.id;
          List<String> serviceNames = [];

          final serviceQuerySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userID)
              .collection('my_services')
              .get();

          if (serviceQuerySnapshot.docs.isNotEmpty) {
            String? serviceID;
            var personalData = await UserProfileService()
                .getUserData(userID, "personal_information", "info");
            var providerLocation = await UserProfileService()
                .getUserData(userID, "personal_information", "location");

            for (var serviceDoc in serviceQuerySnapshot.docs) {
              serviceID = serviceDoc.id;

              debugPrint("ID: $serviceID");
              var serviceData = await UserProfileService()
                  .getUserData(userID, "my_services", serviceID);

              print("=====+");
              print(personalData);
              print("=====++");
              print(providerLocation);
              print("=====+++");
              debugPrint("Service Data: $serviceData");
              serviceNames.add(serviceData['serviceName']);
              debugPrint("...........");
              debugPrint("Service Names: $serviceNames");
            }


            Map<String, dynamic> placeDetails =
                providerLocation['placeDetails'] ?? {};

            debugPrint("-----------");
            debugPrint("PLACE: $placeDetails");

            // GET THE DISTANCE
            double distance = LocationUtils.calculateDistance(
              clientLatitudeValue,
              clientLongitudeValue,
              providerLocation['latitude'],
              providerLocation['longitude'],
            );

            double distanceKilometers = distance / 1000;

            ServiceProvider userData = ServiceProvider(
              userID: userID,
              providerName: personalData['displayName'] ?? 'N/A',
              providerImage: personalData['imageURL'] ?? 'N/A',
              providerStreet: placeDetails['street'],
              providerBarangay: placeDetails['barangay'],
              providerCity: placeDetails['city'],
              providerProvince: placeDetails['province'],
              distance: distanceKilometers,
              serviceNames: serviceNames,
              providerLatitude: providerLocation['latitude'],
              providerLongitude: providerLocation['longitude'],
              providerLocation: providerLocation,
              providerInfo: personalData,
            );

            print("+++");
            print(userData.providerBarangay);
            allUserData.add(userData);
          }
        }
        // SORT BASED ON DISTANCE
        debugPrint("RETURNING!!!");
        allUserData.sort((a, b) => a.distance.compareTo(b.distance));
      }
    } catch (error) {
      print("Error fetching service data: $error");
    }

    return allUserData;
  }
}
