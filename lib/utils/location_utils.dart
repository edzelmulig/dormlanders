import 'package:geolocator/geolocator.dart';

class LocationUtils {
  static double calculateDistance(double clientLatitude, double clientLongitude, double providerLatitude, double providerLongitude) {
    // Calculate distance in meters
    double distanceInMeters = Geolocator.distanceBetween(clientLatitude, clientLongitude, providerLatitude, providerLongitude);
    return distanceInMeters;
  }
}