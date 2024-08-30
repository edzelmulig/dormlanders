import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dormlanders/service_providers/dashboard/service_provider_header_dashboard.dart';
import 'package:dormlanders/service_providers/my_appointments/appointment_card.dart';
import 'package:dormlanders/services/user_profile_service.dart';
import 'package:dormlanders/utils/custom_snackbar_with_icon.dart';
import 'package:dormlanders/utils/no_available_data.dart';
import 'package:dormlanders/utils/no_internet_screen.dart';
import 'package:dormlanders/utils/shimmer_client_home_page.dart';
import 'package:dormlanders/widgets/custom_loading_indicator.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';
import 'package:dormlanders/widgets/custom_user_profile.dart';

class ServiceProviderHomePage extends StatefulWidget {
  const ServiceProviderHomePage({Key? key}) : super(key: key);

  @override
  State<ServiceProviderHomePage> createState() =>
      _ServiceProviderHomePageState();
}

class _ServiceProviderHomePageState extends State<ServiceProviderHomePage> {
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;

  // VARIABLE DECLARATIONS

  late Map<String, dynamic> userData = {};
  String? imageURL;
  int numberOfServices = 0;
  int numberOfAppointments = 0;
  String? displayName;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _exitTimer = Timer(const Duration(seconds: 15), () {});
    listenToAppointments();
    listenToServiceUpdates();
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
      5,
    );
  }

  // METHOD THAT WILL GET THE NUMBER OF APPOINTMENTS
  void listenToAppointments() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("User is not signed in.");
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('my_appointments')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          numberOfAppointments = snapshot.docs.length;
        });
      }
    }, onError: (error) {
      // Handle any errors that occur during listening for updates
      debugPrint("Error listening for service updates: $error");
    });
  }

  // METHOD THAT WILL GET THE NUMBER OF THE SERVICES STORED IN FIRESTORE
  void listenToServiceUpdates() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("User is not signed in.");
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('my_services')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          numberOfServices = snapshot.docs.length;
        });
      }
    }, onError: (error) {
      // Handle any errors that occur during listening for updates
      debugPrint("Error listening for service updates: $error");
    });
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
      child: StreamBuilder<Map<String, dynamic>>(
        stream: UserProfileService().getUserDataStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const CustomLoadingIndicator();
          }

          // EXTRACT DATA FROM SNAPSHOT
          userData = snapshot.data ?? {};
          displayName = userData['displayName'] ?? 'No Name';
          imageURL = userData['imageURL'];
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0.0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // USER PROFILE
                  CustomUserProfile(
                    imageURL: imageURL,
                    imageWidth: 45,
                    imageHeight: 45,
                  ),

                  // Welcome text and username
                  Expanded(
                    child: AutoSizeText(
                      displayName ?? 'No Name',
                      style: const TextStyle(
                        color: Color(0xFF3C4D48),
                        fontWeight: FontWeight.w700,
                      ),
                      minFontSize: 16,
                      maxFontSize: 17,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // SIZED BOX: SPACING
                  const SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // DASHBOARD HEADER CONTAINER: REVENUE, APPOINTMENT AND SERVICES BUTTON
                DashboardHeaderContainer(
                  numberOfAppointments: numberOfAppointments,
                  numberOfServices: numberOfServices,
                ),

                // SIZED BOX: SPACING
                const SizedBox(height: 5),

                // BUTTONS
                _buildStatusButtons(),

                // LIST VIEW OF APPOINTMENTS
                _buildListViewAppointments(),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE5E7EB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          children: <Widget>[
            // LABEL: Recent Appointments and View all button
            const Padding(
              padding: EdgeInsets.only(
                left: 12,
                top: 10,
                right: 12,
                bottom: 10,
              ),
              child: Row(
                children: <Widget>[
                  // TEXT
                  CustomTextDisplay(
                    receivedText: "Recent reservation",
                    receivedTextSize: 17,
                    receivedTextWeight: FontWeight.w500,
                    receivedLetterSpacing: 0,
                    receivedTextColor: Color(0xFF3C3C40),
                  ),
                ],
              ),
            ),

            // BUTTON OPTIONS
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (int index = 0; index < 4; index++)
                    _buildButton(index,
                        ['New', 'Confirmed', 'Cancelled', 'Done'][index]),
                ],
              ),
            ),

            // SIZED BOX: SPACING
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(index, String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            // SET BG COLOR BASED ON SELECTION
            backgroundColor: _selectedIndex == index
                ? const Color(0xFF3C4D48)
                : Colors.white,
            foregroundColor: const Color(0xFF3C4D48),
            side: BorderSide(
              color: _selectedIndex == index
                  ? Colors.transparent
                  : const Color(0xFFCCD2D1),
              width: 1.0,
            ),
            // SET TEXT COLOR BASED ON THE SELECTION
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),

            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 0),
            minimumSize: Size.zero,
          ),
          onPressed: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: CustomTextDisplay(
              receivedText: text,
              receivedTextSize: 13,
              receivedTextWeight: FontWeight.w500,
              receivedLetterSpacing: 0,
              receivedTextColor: _selectedIndex == index
                  ? Colors.white
                  : const Color(0xFFCCD2D1)),
        ),
      ),
    );
  }

  Widget _buildListViewAppointments() {
    // LIST VIEW BUILDER FOR APPOINTMENT
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFE5E7EB),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('my_appointments')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // DISPLAY LOADING
                return const ServiceShimmer(itemCount: 3, containerHeight: 75);
              }

              // IF FETCHING DATA HAS ERROR EXECUTE THIS
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                // FILTER APPOINTMENTS BASED ON SELECTED INDEX
                List<DocumentSnapshot> filteredAppointments = [];
                if (_selectedIndex == 0) {
                  // Filter appointments with status 'new'
                  filteredAppointments = snapshot.data!.docs
                      .where((appointment) =>
                          appointment['appointmentStatus'] == 'new')
                      .toList();
                } else if (_selectedIndex == 1) {
                  // Filter appointments with status 'confirmed'
                  filteredAppointments = snapshot.data!.docs
                      .where((appointment) =>
                          appointment['appointmentStatus'] == 'confirmed')
                      .toList();
                } else if (_selectedIndex == 2) {
                  // Filter appointments with status 'cancelled'
                  filteredAppointments = snapshot.data!.docs
                      .where((appointment) =>
                          appointment['appointmentStatus'] == 'cancelled')
                      .toList();
                } else if (_selectedIndex == 3) {
                  // Filter appointments with status 'done'
                  filteredAppointments = snapshot.data!.docs
                      .where((appointment) =>
                          appointment['appointmentStatus'] == 'done')
                      .toList();
                }

                // DISPLAY ALL APPOINTMENTS AVAILABLE: LIST VIEW
                return filteredAppointments.isEmpty
                    ? const NoAvailableData(
                        icon: Icons.calendar_month_rounded,
                        text: "reservations",
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: filteredAppointments.length,
                        itemBuilder: (context, index) {
                          var appointment = filteredAppointments[index];
                          var appointmentID = appointment.id;

                          return AppointmentCard(
                            appointment: appointment,
                            appointmentID: appointmentID,
                          );
                        },
                      );
              }
            },
          ),
        ),
      ),
    );
  }
}
