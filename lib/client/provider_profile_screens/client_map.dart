import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dormlanders/constants.dart';
import 'package:dormlanders/utils/no_internet_screen.dart';
import 'package:dormlanders/widgets/profile_image_widget.dart';
import 'package:dormlanders/widgets/verified_display_name_widget.dart';
import 'package:screenshot/screenshot.dart';

class ClientMap extends StatefulWidget {
  final double? clientLatitude;
  final double? clientLongitude;
  final String clientImageURL;
  final Map<String, dynamic> providerLocation;
  final Map<String, dynamic> providerInfo;

  const ClientMap({
    super.key,
    required this.clientLatitude,
    required this.clientLongitude,
    required this.clientImageURL,
    required this.providerLocation,
    required this.providerInfo,
  });

  @override
  State<ClientMap> createState() => _ClientMapState();
}

class _ClientMapState extends State<ClientMap> {
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;

  Uint8List? providerIcon;
  Uint8List? clientIcon;

  GoogleMapController? mapController;
  late LatLng clientLocation;
  late LatLng providerLocation;
  List<LatLng> polylineCoordinates = [];
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _exitTimer = Timer(const Duration(seconds: 15), () {});

    // Check if widget.providerInfo['imageURL'] is null
    String providerImageUrl = widget.providerInfo['imageURL'] ?? "images/no_image.jpeg";

    _captureImage(providerImageUrl, isProvider: true);
    _captureImage(widget.clientImageURL, isProvider: false);
    initializeClientLocation();
    getPolyPoints();
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    _exitTimer.cancel();
    super.dispose();
  }

  // CHECK CONNECTION
  Future<void> _checkConnection() async {
    _connectionSubscription = InternetConnectionChecker().onStatusChange.listen(
          (status) {
        // Check if the context is still mounted
        if (!mounted) return;

        setState(() {
          _isConnectedToInternet = status == InternetConnectionStatus.connected;
        });

        if (_isConnectedToInternet) {
          _showConnectedSnackBar();
        } else {
          _showDisconnectedSnackBar();
        }
      },
    );
  }

  void _showDisconnectedSnackBar() {
    if (!_isConnectedToInternet) {
      // Check if a disconnected snack bar is already being displayed
      if (!isDisconnectedSnackBarVisible) {
        // showFloatingSnackBarWithIcon(
        //   context,
        //   'No internet connection',
        //   Icons.wifi_off_rounded,
        //   10,
        // );
        // Set the flag to indicate that the disconnected snack bar is being displayed
        isDisconnectedSnackBarVisible = true;

        // Restart the app after 10 seconds unless connection is restored
        _exitTimer = Timer(const Duration(seconds: 15), () async {
          await InternetConnectionChecker().hasConnection
              ? _exitTimer.cancel()
              : SystemNavigator.pop();
        });
      }
    }
  }

  void _showConnectedSnackBar() {
    if (isDisconnectedSnackBarVisible) {
      // If a disconnected snack bar is being displayed, hide it
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // Reset the flag
      isDisconnectedSnackBarVisible = false;
    }

    // showFloatingSnackBarWithIcon(
    //   context,
    //   'Connected to the internet',
    //   Icons.wifi_rounded,
    //   10,
    // );
  }

  // METHOD THAT WILL CAPTURE IMAGE
  Future<void> _captureImage(String imageURL,
      {required bool isProvider}) async {
    // Capture the widget into an image
    final controller = ScreenshotController();
    final imageBytes = await controller.captureFromWidget(
      _buildProviderProfile(imageURL),
    );

    if(mounted) {
      setState(() {
        if (isProvider) {
          providerIcon = imageBytes;
        } else {
          clientIcon = imageBytes;
        }
      });
    }
  }

  void initializeClientLocation() {
    clientLocation = LatLng(widget.clientLatitude!, widget.clientLongitude!);
    providerLocation =
        LatLng(widget.providerLocation['latitude'], widget.providerLocation['longitude']);
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: apiKey,  // Use the named parameter for the API key
      request: PolylineRequest(  // Create a PolylineRequest object
          origin: PointLatLng(clientLocation.latitude, clientLocation.longitude),  // Origin point
          destination: PointLatLng(providerLocation.latitude, providerLocation.longitude),  // Destination point
          mode: TravelMode.driving,  // You can specify the travel mode (optional)
          wayPoints: []  // Optionally add waypoints, if any
      ),
    );


    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );

        setState(() {});
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // After the map is created, show the InfoWindow
    showMarkerInfoWindow();
  }

  // Function to programmatically show the InfoWindow
  void showMarkerInfoWindow() {
    mapController?.showMarkerInfoWindow(const MarkerId("provider"));
  }


  @override
  Widget build(BuildContext context) {
    Color polylineColor = _currentMapType == MapType.normal
        ? const Color(0xFF279778)
        : Colors.white;

    if(!_isConnectedToInternet) {
      return const NoInternetScreen();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            // GOOGLE MAP ON SCREEN
            Expanded(
              child: Stack(
                children: <Widget>[
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: clientLocation,
                      zoom: 15,
                    ),
                    myLocationEnabled: false,
                    myLocationButtonEnabled: true,
                    mapType: _currentMapType,
                    zoomControlsEnabled: false,
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId("route"),
                        points: polylineCoordinates,
                        color: polylineColor,
                        width: 6,
                      ),
                    },
                    onMapCreated: _onMapCreated,
                    markers: {
                      Marker(
                        markerId: const MarkerId("client"),
                        position: clientLocation,
                        icon: clientIcon != null
                            ? BitmapDescriptor.fromBytes(clientIcon!)
                            : BitmapDescriptor.defaultMarker,
                      ),
                      Marker(
                        markerId: const MarkerId("provider"),
                        position: providerLocation,
                        icon: providerIcon != null
                            ? BitmapDescriptor.fromBytes(providerIcon!)
                            : BitmapDescriptor.defaultMarker,
                        infoWindow: InfoWindow(title: widget.providerInfo['displayName']),
                      ),
                    },
                  ),

                  // BUTTON THAT WILL CHANGE THE MAP TYPE
                  Positioned(
                    bottom: 30,
                    left: 10,
                    child: FloatingActionButton(
                      backgroundColor: const Color(0xFF279778),
                      onPressed: () {
                        setState(() {
                          // Toggle between MapType.normal and MapType.satellite
                          if (_currentMapType == MapType.normal) {
                            _currentMapType = MapType.satellite;
                          } else {
                            _currentMapType = MapType.normal;
                          }
                        });
                      },
                      child: SizedBox(
                        width: double.infinity,
                        // Makes the container fill the FAB
                        height: double.infinity,
                        // Makes the container fill the FAB
                        child: FittedBox(
                          // This will scale and fit the image to the container
                          fit: BoxFit.cover,
                          // This ensures the image covers the button area, adjust BoxFit as needed
                          child: Image.asset(
                            _currentMapType == MapType.normal
                                ? 'images/mapType_normal.png'
                                : 'images/mapType_satellite.png',
                            // No need to set width and height here, FittedBox handles it
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 20,
                    left: 10,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor:
                        const Color(0xFF279778).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(30, 30),
                        elevation: 3,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFF279778),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 20,
                    // Position at the bottom of the screen
                    right: 20,
                    // Position to the right (you can adjust the positioning as needed)
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor:
                        const Color(0xFF279778).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        minimumSize: const Size(55, 55),
                        elevation: 3,
                      ),
                      onPressed: () {
                        mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(clientLocation, 15),
                        );
                      },
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFF279778),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PROVIDER ADDRESS
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1.7,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 15),

                  // PROVIDER NAME
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Row(
                      children: <Widget>[
                        VerifiedDisplayNameWidget(
                          displayName: widget.providerInfo['displayName'] ?? 'Loading...',
                          fontSize: 16.5,
                          fontWeight: FontWeight.w500,
                          iconSize: 17,
                        ),
                      ],
                    ),
                  ),

                  // SIZED BOX: SPACING
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            text: TextSpan(
                              children: <TextSpan>[
                                const TextSpan(
                                  text: "Additional instruction: ",
                                  style: TextStyle(
                                    color: Color(0xFF9F9D9D),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: widget
                                      .providerLocation['additionalInstructions'] ?? 'Loading...',
                                  style: const TextStyle(
                                    height: 1.0,
                                    color: Color(0xFF9F9D9D),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SIZED BOX: SPACING
                  const SizedBox(height: 7),

                  const Divider(
                    thickness: 1,
                    color: Color(0xFFE5E7EB),
                  ),

                  // ADDITIONAL INFORMATION
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 10,
                      top: 8,
                      bottom: 8,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(
                            right: 17,
                          ),
                          child: Icon(
                            Icons.push_pin_sharp,
                            size: 25,
                            color: Color(0xFF3C3C40),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AutoSizeText(
                                "${widget.providerLocation['placeDetails']['street']}, "
                                "${widget.providerLocation['placeDetails']['barangay']}, "
                                "${widget.providerLocation['placeDetails']['city']},",
                                style: const TextStyle(
                                  height: 1.0,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF3C3C40),
                                ),
                                minFontSize: 15,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              AutoSizeText(
                                "${widget.providerLocation['placeDetails']['province']}, "
                                "${widget.providerLocation['placeDetails']['region']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                ),
                                minFontSize: 13,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    thickness: 1,
                    color: Color(0xFFE5E7EB),
                  ),

                  // PROVIDER NUMBER
                  _userInfo(Icons.phone_in_talk_rounded,
                      widget.providerInfo['phoneNumber']),

                  const Divider(
                    thickness: 1,
                    color: Color(0xFFE5E7EB),
                  ),

                  // PROVIDER EMAIL
                  _userInfo(Icons.email_rounded, widget.providerInfo['email']),

                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderProfile(String imageURL) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: const Color(0xFF279778), // Change color as needed
            width: 8, // Change width as needed
          ),
        ),
        child: ProfileImageWidget(
          width: 50,
          height: 50,
          borderRadius: 100,
          imageURL: imageURL,
        ),
      ),
    );
  }

  Widget _userInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 17,
            ),
            child: Icon(
              icon,
              size: 25,
              color: const Color(0xFF3C3C40),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AutoSizeText(
                  text,
                  style: const TextStyle(
                    height: 1.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3C3C40),
                  ),
                  minFontSize: 15,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
