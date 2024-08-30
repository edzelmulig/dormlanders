import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dormlanders/client/client_messages.dart';
import 'package:dormlanders/client/provider_profile_screens/client_map.dart';
import 'package:dormlanders/services/user_profile_service.dart';
import 'package:dormlanders/utils/custom_snackbar.dart';
import 'package:dormlanders/utils/navigation_utils.dart';
import 'package:dormlanders/utils/no_internet_screen.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';
import 'package:dormlanders/widgets/profile_image_widget.dart';
import 'package:dormlanders/widgets/provider_service_card_client_side.dart';
import 'package:dormlanders/widgets/verified_display_name_widget.dart';
import 'package:shimmer/shimmer.dart';

class ClientProviderProfile extends StatefulWidget {
  final String providerID;
  final double providerDistance;
  final double? clientLatitude;
  final double? clientLongitude;
  final String clientImageURL;
  final Map<String, dynamic>? providerLocation;
  final Map<String, dynamic>? providerInfo;

  const ClientProviderProfile({
    super.key,
    required this.providerID,
    required this.providerDistance,
    this.clientLatitude,
    this.clientLongitude,
    required this.clientImageURL,
    required this.providerLocation,
    required this.providerInfo,
  });

  @override
  State<ClientProviderProfile> createState() => _ClientProviderProfileState();
}

class _ClientProviderProfileState extends State<ClientProviderProfile> {
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;

  final ScrollController _controllerOne = ScrollController();
  Map<String, dynamic>? fetchedProviderInfo;
  Map<String, dynamic>? fetchedProviderLocation;
  Map<String, dynamic>? fetchUserInfo;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _exitTimer = Timer(const Duration(seconds: 15), () {});
    _fetchClientInfo();
    if (widget.providerInfo == null || widget.providerLocation == null) {
      _fetchProviderInfoAndLocation();
    } else {
      fetchedProviderInfo = widget.providerInfo;
      fetchedProviderLocation = widget.providerLocation;
    }
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

  // FETCH PROVIDER INFO AND LOCATION
  Future<void> _fetchProviderInfoAndLocation() async {
    try {
      var personalData = await UserProfileService().getUserData(
        widget.providerID,
        "personal_information",
        "info",
      );
      var locationData = await UserProfileService().getUserData(
        widget.providerID,
        "personal_information",
        "location",
      );

      setState(() {
        fetchedProviderInfo = personalData;
        fetchedProviderLocation = locationData;
      });
    } catch (error) {
      print("Error fetching provider information: $error");
    }
  }

  // FETCH CLIENT INFO
  Future<void> _fetchClientInfo() async {
    var clientID = FirebaseAuth.instance.currentUser!.uid;
    try {
      var clientData = await UserProfileService().getUserData(
        clientID,
        "personal_information",
        "info",
      );

      setState(() {
        fetchUserInfo = clientData;
      });
    } catch (error) {
      print("Error fetching provider information: $error");
    }
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
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // PROVIDER PROFILE, NAME, AND DISTANCE
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: <Widget>[
                  _buildProviderProfile(),
                  _buildProviderInfo(),
                ],
              ),
            ),

            // SIZED BOX: SPACING
            const SizedBox(height: 20),

            // BUTTONS: APPOINTMENT, MESSAGE, LOCATION ICON
            _buildButtons(),

            // SIZED BOX: SPACING
            const SizedBox(height: 10),

            // DIVIDER
            const Divider(
              color: Color(0xFFE5E7EB),
              thickness: 10,
            ),

            // TEXT SERVICES
            const Padding(
              padding: EdgeInsets.only(
                left: 20,
                top: 10,
                bottom: 10,
              ),
              child: CustomTextDisplay(
                receivedText: "Services",
                receivedTextSize: 18,
                receivedTextWeight: FontWeight.w500,
                receivedLetterSpacing: 0,
                receivedTextColor: Color(0xFF3C4D48),
              ),
            ),

            // LIST OF SERVICES
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.providerID)
                  .collection('my_services')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // DISPLAY CUSTOM LOADING INDICATOR
                  Expanded(
                    child: Scrollbar(
                      controller: _controllerOne,
                      thumbVisibility: true,
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[300],
                              ),
                              title: Container(
                                height: 20,
                                color: Colors.grey[300],
                              ),
                              subtitle: Container(
                                height: 12,
                                color: Colors.grey[300],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
                // IF FETCHING DATA HAS ERROR EXECUTE THIS
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // CHECK IF THERE IS AVAILABLE SERVICES
                if (snapshot.data?.docs.isEmpty ?? true) {
                  // DISPLAY THERE IS NO AVAILABLE SERVICES
                  return const SizedBox();
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var service = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                        return ProviderServiceCardClientSide(
                          providerID: widget.providerID,
                          availability: service['availability'],
                          discount: service['discount'],
                          imageURL: service['imageURL'],
                          price: service['price'],
                          serviceDescription: service['serviceDescription'],
                          serviceName: service['serviceName'],
                          serviceType: service['serviceType'],
                          providerInfo: fetchedProviderInfo,
                          clientInfo: fetchUserInfo,
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // APP BAR
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.0,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: EdgeInsets.zero,
        child: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 23,
            color: Color(0xFF7C7C7D),
          ),
        ),
      ),
    );
  }

  // PROVIDER PROFILE
  Widget _buildProviderProfile() {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: ProfileImageWidget(
        width: 75,
        height: 75,
        borderRadius: 10,
        imageURL: fetchedProviderInfo?['imageURL'] ?? '',
      ),
    );
  }

  // PROVIDER INFO
  Widget _buildProviderInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // DISPLAY NAME & VERIFIED LOGO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              VerifiedDisplayNameWidget(
                displayName:
                fetchedProviderInfo?['displayName'] ?? 'Loading...',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                iconSize: 20,
              ),
            ],
          ),

          // SIZED BOX: SPACING
          const SizedBox(height: 5),

          // PROVIDER DISTANCE
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // CITY
              Expanded(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                    children: [
                      const WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFF9F9D9D),
                            size: 18,
                          ),
                        ),
                      ),
                      // DISPLAY
                      TextSpan(
                        text:
                        "${fetchedProviderLocation?['placeDetails']['city'] ??
                            'Loading...'} · ${widget.providerDistance
                            .toStringAsFixed(0)}km away",
                        style: const TextStyle(
                          color: Color(0xFF9F9D9D),
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // DISTANCE
            ],
          ),
        ],
      ),
    );
  }

  // BUTTONS
  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // APPOINTMENT BUTTON
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFE5E7EB),
                foregroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: () async {
                String userID = FirebaseAuth.instance.currentUser!.uid;
                // CHECK IF THE CLIENT HAS APPOINTMENT
                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userID)
                    .collection('my_appointments')
                    .where('clientID', isEqualTo: widget.providerID)
                    .where('appointmentStatus', whereIn: ['new', 'confirmed'])
                    .get();

                try {
                  if (querySnapshot.docs.isNotEmpty) {
                    // LOCATE THE PROVIDER
                    if (context.mounted) {
                      navigateWithSlideFromRight(
                        context,
                        ClientMap(
                          clientLatitude: widget.clientLatitude,
                          clientLongitude: widget.clientLongitude,
                          clientImageURL: widget.clientImageURL,
                          providerLocation: fetchedProviderLocation!,
                          providerInfo: fetchedProviderInfo!,
                        ),
                        1.0,
                        0.0,
                      );
                    }
                  } else {
                    if(context.mounted) {
                      showFloatingSnackBar(
                        context, "Appointment needed for location access.",
                        const Color(0xFF3C3C40),
                      );
                    }
                  }
                } catch (error) {
                  debugPrint("Error: $error");
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CustomTextDisplay(
                  receivedText: "Find Location",
                  receivedTextSize: 15,
                  receivedTextWeight: FontWeight.w500,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Color(0xFF3C4D48),
                ),
              ),
            ),
          ),

          // SIZED BOX: SPACING
          const SizedBox(width: 10),

          // MESSAGE BUTTON
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF193147),
              foregroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              padding: EdgeInsets.zero,
            ),
            onPressed:  () async {
              String userID = FirebaseAuth.instance.currentUser!.uid;
              // CHECK IF THE CLIENT HAS APPOINTMENT
              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userID)
                  .collection('my_appointments')
                  .where('clientID', isEqualTo: widget.providerID)
                  .where('appointmentStatus', whereIn: ['new', 'confirmed'])
                  .get();

              try {
                if (querySnapshot.docs.isNotEmpty) {
                  // LOCATE THE PROVIDER
                  if (context.mounted) {
                    navigateWithSlideFromRight(
                      context,
                      ClientMessages(),
                      1.0,
                      0.0,
                    );
                  }
                } else {
                  if(context.mounted) {
                    showFloatingSnackBar(
                      context, "Appointment needed for direct messaging.",
                      const Color(0xFF3C3C40),
                    );
                  }
                }
              } catch (error) {
                debugPrint("Error: $error");
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: CustomTextDisplay(
                receivedText: "Message",
                receivedTextSize: 15,
                receivedTextWeight: FontWeight.w500,
                receivedLetterSpacing: 0,
                receivedTextColor: Colors.white,
              ),
            ),
          ),

          // SIZED BOX: SPACING
          const SizedBox(width: 10),

        ],
      ),
    );
  }
}
