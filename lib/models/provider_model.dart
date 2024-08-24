class ServiceProvider {
  final String userID;
  final String providerName;
  final String providerImage;
  final String providerStreet;
  final String providerBarangay;
  final String providerCity;
  final String providerProvince;
  final double distance;
  final List<String> serviceNames;
  final double? providerLatitude;
  final double? providerLongitude;
  final Map<String, dynamic>? providerLocation;
  final Map<String, dynamic>? providerInfo;

  ServiceProvider({
    required this.userID,
    required this.providerName,
    required this.providerImage,
    required this.providerStreet,
    required this.providerBarangay,
    required this.providerCity,
    required this.providerProvince,
    required this.distance,
    required this.serviceNames,
    this.providerLatitude,
    this.providerLongitude,
    this.providerLocation,
    this.providerInfo,
  });

  // Factory constructor to create a ServiceProvider from a map
  factory ServiceProvider.fromMap(Map<String, dynamic> map) {
    return ServiceProvider(
      userID: map['userID'] ?? '',
      providerName: map['providerName'] ?? 'N/A',
      providerImage: map['providerImage'] ?? 'images/no_image.jpeg',
      providerStreet: map['providerStreet'] ?? 'N/A',
      providerBarangay: map['providerBarangay'] ?? 'N/A',
      providerCity: map['providerCity'] ?? 'N/A',
      providerProvince: map['providerProvince'] ?? 'N/A',
      distance: map['distance'] ?? 0.0,
      serviceNames: List<String>.from(map['serviceNames'] ?? []),
      providerLatitude: map['providerLatitudeValue'] ?? 0.0,
      providerLongitude: map['providerLongitudeValue'] ?? 0.0,
      providerLocation: map['providerLocation'],
      providerInfo: map['providerInfo'],
    );
  }
}
