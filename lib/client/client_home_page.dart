import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:location/location.dart';
import 'package:dormlanders/client/client_provider_profile.dart';
import 'package:dormlanders/client/client_search.dart';
import 'package:dormlanders/services/client_services.dart';
import 'package:dormlanders/services/location_services.dart';
import 'package:dormlanders/services/user_profile_service.dart';
import 'package:dormlanders/utils/custom_snackbar_with_icon.dart';
import 'package:dormlanders/utils/navigation_utils.dart';
import 'package:dormlanders/utils/no_internet_screen.dart';
import 'package:dormlanders/utils/shimmer_client_home_page.dart';
import 'package:dormlanders/widgets/provider_info_card.dart';
import 'package:dormlanders/widgets/custom_dummy_searchbar.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';
import 'package:dormlanders/models/provider_model.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;

  // LOCATION CONTROLLER
  final Location _locationController = Location();
  int count = 0;
  List<ServiceProvider> providers = [];

  bool isLoading = true;
  LatLng? currentLocation;
  late double clientLatitude = 0;
  late double clientLongitude = 0;
  late String clientImageURL;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _exitTimer = Timer(const Duration(seconds: 15), () {});
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _getClientProfile();
    updateCurrentLocation();
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    _exitTimer.cancel();
    _scrollController.dispose();
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
        showFloatingSnackBarWithIcon(
          context,
          'No internet connection',
          Icons.wifi_off_rounded,
          10,
        );
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

    showFloatingSnackBarWithIcon(
      context,
      'Connected to the internet',
      Icons.wifi_rounded,
      10,
    );
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      // Reached the end of the list
      fetchAllServicesData(); // Load more data
    }
  }

  // GET CURRENT LOCATION OF THE USER
  void updateCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      debugPrint("GETTING LOCATION");
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

    currentLocation = await UserLocationService().getCurrentLocation();
    if (currentLocation != null) {
      if (mounted) {
        setState(() {
          clientLatitude = currentLocation!.latitude;
          clientLongitude = currentLocation!.longitude;
        });
      }

      // FETCH THE PROVIDERS
      fetchAllServicesData();
      debugPrint("SUCCESSFULLY FETCHED PROVIDERS.");
    } else {
      // Handle the case where current location is not available
      updateCurrentLocation();
      debugPrint("FAILED TO FETCH PROVIDERS.");
    }
  }

  // FETCH CLIENT PROFILE
  Future _getClientProfile() async {
    final data = await UserProfileService().getUserData(
        FirebaseAuth.instance.currentUser!.uid, 'personal_information', 'info');

    if (mounted) {
      setState(() {
        // ASSIGN THE INITIAL VALUE TO THE CONTROLLERS
        clientImageURL = data['imageURL'] ?? "";
      });
    }
  }

  // FETCH ALL PROVIDERS
  Future fetchAllServicesData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<ServiceProvider> servicesData =
          await ClientServices.fetchAllProviders(
        clientLatitude,
        clientLongitude,
      );
      debugPrint("LAT: $clientLatitude LONG: $clientLongitude");
      if (!mounted) return;

      setState(() {
        providers = servicesData;
        count = servicesData.length;
        isLoading = false;
        debugPrint("PROVIDERS: $providers COUNT: $count");
      });
    } catch (error) {
      debugPrint("Error fetching service data: $error");
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void _onRefresh() async {
    // Perform your refresh logic here...
    await fetchAllServicesData();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnectedToInternet) {
      return const NoInternetScreen();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F0F5),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // HEADER OF HOME PAGE
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF279778),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, bottom: 10, top: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const CustomTextDisplay(
                      receivedText: "MentalBoost",
                      receivedTextSize: 26,
                      receivedTextWeight: FontWeight.w700,
                      receivedLetterSpacing: 0,
                      receivedTextColor: Colors.white,
                    ),
                    DummySearchBar(
                      hintText: "Search service or location",
                      onPressed: () {
                        navigateWithSlideFromRight(
                          context,
                          ClientSearchBar(
                            clientLatitude: clientLatitude,
                            clientLongitude: clientLongitude,
                            clientImageURL: clientImageURL,
                          ),
                          0.0,
                          1.0,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // SIZED BOX: SPACING
            const SizedBox(height: 15),

            // LIST OF ALL MENTAL HEALTH SERVICE PROVIDERS
            Expanded(
              child: isLoading
                  ? const ServiceShimmer(
                      itemCount: 6,
                      containerHeight: 110,
                    )
                  : RefreshIndicator(
                      edgeOffset: 0,
                      triggerMode: RefreshIndicatorTriggerMode.onEdge,
                      color: Colors.white,
                      backgroundColor: Color(0xFF279778),
                      onRefresh: () async {
                        await Future.delayed(Duration(milliseconds: 1500));
                        setState(() {
                          _onRefresh();
                        });
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: count,
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          // DIRECT USE OF THE ServiceProvider object
                          ServiceProvider currentProvider = providers[index];

                          return ProviderInfoCard(
                            providerID: currentProvider.userID,
                            providerName: currentProvider.providerName,
                            providerProfile: currentProvider.providerImage,
                            providerStreet: currentProvider.providerStreet,
                            providerBarangay: currentProvider.providerBarangay,
                            providerCity: currentProvider.providerCity,
                            providerProvince: currentProvider.providerProvince,
                            distance: currentProvider.distance,
                            leftPadding: 15,
                            topPadding: 0,
                            rightPadding: 15,
                            bottomPadding: 13,
                            onPressed: () {
                              navigateWithSlideFromRight(
                                context,
                                ClientProviderProfile(
                                  providerID: currentProvider.userID,
                                  providerDistance: currentProvider.distance,
                                  clientLatitude: clientLatitude,
                                  clientLongitude: clientLongitude,
                                  clientImageURL: clientImageURL,
                                  providerInfo:
                                      currentProvider.providerInfo ?? {},
                                  providerLocation:
                                      currentProvider.providerLocation ?? {},
                                ),
                                1.0,
                                0.0,
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
