import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeocodingService {

  // THIS WILL GET THE ADDRESS BASED ON THE POSITION or _lastMapPosition
  Future<Map<String, dynamic>?> getAddressFromLatLng(LatLng position) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks.first;

        Map<String, dynamic> addressDetails = {
          'street': place.street?.isEmpty ?? true ? 'Unknown' : place.street!,
          'barangay': place.subLocality?.isEmpty ?? true ? 'Unknown' : place.subLocality!,
          'city': place.locality ?? '',
          'province': place.subAdministrativeArea ?? '',
          'region': place.administrativeArea ?? '',
          'fullAddress': '${place.street}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}'
        };

        return addressDetails;
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}