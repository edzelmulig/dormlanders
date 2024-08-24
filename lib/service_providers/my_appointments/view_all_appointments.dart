import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dormlanders/service_providers/my_appointments/appointment_card.dart';
import 'package:dormlanders/utils/no_available_data.dart';
import 'package:dormlanders/utils/no_internet_screen.dart';
import 'package:dormlanders/utils/shimmer_client_home_page.dart';
import 'package:dormlanders/widgets/custom_app_bar.dart';

class ViewAllAppointments extends StatefulWidget {
  const ViewAllAppointments({super.key});

  @override
  State<ViewAllAppointments> createState() => _ViewAllAppointmentsState();
}

class _ViewAllAppointmentsState extends State<ViewAllAppointments> {
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;

  // INITIALIZATION
  @override
  void initState() {
    super.initState();
    _checkConnection();
    _exitTimer = Timer(const Duration(seconds: 15), () {});
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(AppBar().preferredSize.height),
          child: CustomAppBar(
              backgroundColor: const Color(0xFFF5F5F5),
              titleText: "My appointments",
              onLeadingPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }),
        ),
        body: Container(
          color: const Color(0xFFF5F5F5),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('my_appointments')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // DISPLAY LOADING
                return const ServiceShimmer(itemCount: 3, containerHeight: 75);
              }

              // IF FETCHING DATA HAS ERROR EXECUTE THIS
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.data!.docs.isEmpty) {
                return const NoAvailableData(
                  icon: Icons.notification_important_rounded,
                  text: "notifications",
                );
              } else {
                // DISPLAY ALL APPOINTMENTS AVAILABLE: LIST VIEW
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var appointment = snapshot.data!.docs[index];
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
