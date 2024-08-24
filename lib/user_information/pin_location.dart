import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dormlanders/constants.dart';
import 'package:dormlanders/user_information/confirm_location.dart';
import 'package:dormlanders/services/geocoding_services.dart';
import 'package:dormlanders/services/location_services.dart';
import 'package:dormlanders/utils/custom_snackbar.dart';
import 'package:dormlanders/utils/navigation_utils.dart';
import 'package:dormlanders/utils/no_internet_screen.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class PinLocation extends StatefulWidget {
  const PinLocation({Key? key}) : super(key: key);

  @override
  State<PinLocation> createState() => _PinLocationState();
}

class _PinLocationState extends State<PinLocation> {
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;

  // TEXT EDITING CONTROLLERS
  final _addressController = TextEditingController();
  final _additionalInstructions = TextEditingController();

  // GOOGLE MAP CAMERA CONTROLLER
  GoogleMapController? _mapController;

  // CURRENT POSITION/LOCATION
  LatLng? _lastMapPosition;

  // VARIABLE DECLARATION
  String address = '';
  bool isMoving = false;

  // MAP THAT WILL HOLD THE PLACE DETAILS
  Map<String, dynamic> localPlaceDetails = {};
  Map<String, dynamic> temporaryPlaceDetails = {};

  // LATITUDE AND LONGITUDE VARIABLES
  double? latitudeValue;
  double? longitudeValue;

  // DETERMINE IF THE USER HAS SET ITS LOCATION ALREADY OR NOT
  bool hasData = true;

  // FORM KEY DECLARATION
  final _formKey = GlobalKey<FormState>();

  // FOCUS NODE DECLARATION
  final FocusNode _focusNode = FocusNode();

  // DEFINE GOOGLE MAP TYPE
  MapType _currentMapType = MapType.normal;

  // INITIALIZATION
  @override
  void initState() {
    super.initState();
    _checkConnection();
    _exitTimer = Timer(const Duration(seconds: 15), () {});
    _fetchUserLocation();
    _focusNode.addListener(
      () {
        if (_focusNode.hasFocus) {
          _addressController.selection = TextSelection.fromPosition(
            TextPosition(offset: _addressController.text.length),
          );
        }
      },
    );
  }

  // DISPOSE
  @override
  void dispose() {
    _connectionSubscription.cancel();
    _exitTimer.cancel();
    _additionalInstructions.dispose();
    _addressController.dispose();
    _focusNode.dispose();
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

  // FETCH USER LOCATION FROM FIRESTORE
  void _fetchUserLocation() async {
    final locationData = await UserLocationService().getUserLocation();
    if (locationData != null) {
      setState(() {
        // CLEAR EXISTING placeDetails value
        localPlaceDetails.clear();
        // Your logic to update the UI based on fetched location data
        latitudeValue = locationData['latitude'];
        longitudeValue = locationData['longitude'];
        _additionalInstructions.text =
            locationData['additionalInstructions'] ?? '';
        localPlaceDetails = locationData['placeDetails'] ?? {};
        // Don't forget to move the camera if necessary
        _lastMapPosition = LatLng(latitudeValue!, longitudeValue!);
        _mapController?.moveCamera(CameraUpdate.newLatLng(_lastMapPosition!));
      });
    } else {
      // Handle case where no location data is returned (e.g., fetch current location)
      setState(() {
        hasData = false;
        updateCurrentLocation();
      });
    }
  }

  // THIS WILL GET THE CURRENT LOCATION OR POSITION OF THE USER
  void updateCurrentLocation() async {
    final currentLocation = await UserLocationService().getCurrentLocation();
    if (currentLocation != null) {
      if(context.mounted) {
        setState(() {
          latitudeValue = currentLocation.latitude;
          longitudeValue = currentLocation.longitude;

          _lastMapPosition = currentLocation;
          _mapController?.moveCamera(CameraUpdate.newLatLng(_lastMapPosition!));
        });
      }
    } else {
      // Handle the case where current location is not available
    }
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
    setState(() {
      isMoving = true;
      address = '';
    });
  }

  void _onCameraIdle() {
    setState(() {
      isMoving = false;
    });

    getAddressFromLatLng();
  }

  // GET THE DETAILS OF THE ADDRESS
  void getAddressFromLatLng() async {
    if (_lastMapPosition == null || !mounted) return;

    GeocodingService geocodingService = GeocodingService();
    final addressDetails =
        await geocodingService.getAddressFromLatLng(_lastMapPosition!);

    if (mounted && addressDetails != null) {
      setState(() {
        address = addressDetails['fullAddress'];
        _addressController.text = address;
        // Update any other fields or variables as necessary
        temporaryPlaceDetails = {
          'street': addressDetails['street'],
          'barangay': addressDetails['barangay'],
          'city': addressDetails['city'],
          'province': addressDetails['province'],
          'region': addressDetails['region'],
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnectedToInternet) {
      return const NoInternetScreen();
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            // ADD THIS: Container to display the address at the bottom
            Form(
              key: _formKey,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // Distribute space evenly
                  children: <Widget>[
                    // Give the AutoSizeText widget more flexibility to resize within the Row.
                    Expanded(
                      child: GooglePlaceAutoCompleteTextField(
                        boxDecoration: BoxDecoration(
                          color: const Color(0xFFEDEDF5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textEditingController: _addressController,
                        googleAPIKey: apiKey,
                        inputDecoration: const InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFF279778),
                            ),
                          ),
                          hintText: "Search location",
                          hintStyle: TextStyle(
                            color: Color(0xFF6c7687),
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                          ),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        debounceTime: 500,
                        countries: const ["ph"],
                        // optional by default null is set
                        isLatLngRequired: true,
                        // if you required coordinates from place detail
                        getPlaceDetailWithLatLng: (Prediction prediction) {
                          // this method will return lat lng with place detail

                          // SAVE VALUE OF LAT AND LONG IN THE LOCAL VARIABLE
                          latitudeValue = double.parse(prediction.lat!);
                          longitudeValue = double.parse(prediction.lng!);

                          _lastMapPosition = LatLng(
                            double.parse(prediction.lat!),
                            double.parse(prediction.lng!),
                          );
                          _mapController?.moveCamera(
                              CameraUpdate.newLatLng(_lastMapPosition!));
                        },
                        // this callback is called when isLatLngRequired is true
                        itemClick: (Prediction prediction) {
                          _addressController.text = prediction.description!;
                          _addressController.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                                offset: prediction.description!.length),
                          );
                        },

                        // if we want to make custom list item builder
                        itemBuilder: (context, index, Prediction prediction) {
                          return Container(
                            padding: const EdgeInsets.only(
                              left: 13,
                              top: 5,
                              right: 5,
                              bottom: 5,
                            ),
                            child: Row(
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                  ),
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Expanded(
                                  child: Text(prediction.description ?? ""),
                                )
                              ],
                            ),
                          );
                        },
                        // if you want to add separator between list items
                        seperatedBuilder: const Divider(),
                        // want to show close icon
                        isCrossBtnShown: true,
                        // optional container padding
                      ),
                    )
                  ],
                ),
              ),
            ),

            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFEDEDF5),
                    width: 1.5,
                  ),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFEDEDF5),
                    blurRadius: 15,
                    spreadRadius: 5,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF279778),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    // VALIDATE THE INPUT
                    if (_addressController.text.isEmpty) {
                      showFloatingSnackBar(
                        context,
                        "Address is required",
                        const Color(0xFFe91b4f),
                      );
                    } else {
                      navigateWithSlideFromRight(
                        context,
                        ConfirmLocation(
                          placeDetails: hasData
                              ? localPlaceDetails
                              : temporaryPlaceDetails,
                          latitudeValue: latitudeValue,
                          longitudeValue: longitudeValue,
                          additionalInstructions: _additionalInstructions.text,
                        ),
                        0.0,
                        1.0,
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // NEXT TEXT
                      Container(
                        margin: const EdgeInsets.only(left: 5, right: 10),
                        child: CustomTextDisplay(
                          receivedText:
                              hasData ? "Update location" : "Confirm location",
                          receivedTextSize: 15,
                          receivedTextWeight: FontWeight.w500,
                          receivedLetterSpacing: 0,
                          receivedTextColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: Stack(
                children: <Widget>[
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _lastMapPosition ?? const LatLng(0, 0),
                      // A default location if none is obtained
                      zoom: 15,
                    ),
                    mapType: _currentMapType,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    onCameraMove: _onCameraMove,
                    onCameraIdle: _onCameraIdle,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      controller.setMapStyle('''
                        [
                          {
                            "featureType": "all",
                            "stylers": [
                              {"saturation": -80},
                              {"lightness": 20}
                            ]
                          },
                        ]
                      ''');
                    },
                    zoomControlsEnabled: false,
                  ),
                  Center(
                    // This centers the marker on the map
                    child: Center(
                      child: isMoving
                          ? Image.asset(
                              "images/location_pin_moving.png",
                              width: 50,
                              height: 50,
                            )
                          : Image.asset(
                              "images/location_pin_not_moving.png",
                              width: 50,
                              height: 50,
                            ),
                    ),
                  ),
                  // EXIT BUTTON
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
                  // BUTTON THAT WILL CHANGE THE MAP TYPE
                  Positioned(
                    bottom: 40,
                    left: 20,
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

                  // BUTTON TO AUTOMATICALLY POINT THE CURRENT POSITION OF THE USER
                  Positioned(
                    bottom: 35,
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
                      onPressed: updateCurrentLocation,
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFF279778),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
