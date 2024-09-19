import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dormlanders/service_providers/my_services/add_service.dart';
import 'package:dormlanders/service_providers/my_services/update_service.dart';
import 'package:dormlanders/services/firebase_services.dart';
import 'package:dormlanders/utils/custom_modals.dart';
import 'package:dormlanders/utils/navigation_utils.dart';
import 'package:dormlanders/utils/no_internet_screen.dart';
import 'package:dormlanders/widgets/custom_app_bar.dart';
import 'package:dormlanders/widgets/custom_floating_action_button.dart';
import 'package:dormlanders/widgets/custom_loading_indicator.dart';
import 'package:dormlanders/widgets/provider_service_card.dart';
import 'package:dormlanders/utils/no_service_available.dart';

class MyServices extends StatefulWidget {
  const MyServices({super.key});

  @override
  State<MyServices> createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServices> {
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;

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
    //   5,
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
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(AppBar().preferredSize.height),
          child: CustomAppBar(
              backgroundColor: const Color(0xFFF5F5F5),
              titleText: "My Dormitories",
              onLeadingPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('my_services')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // DISPLAY CUSTOM LOADING INDICATOR
              return const CustomLoadingIndicator();
            }
            // IF FETCHING DATA HAS ERROR EXECUTE THIS
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // CHECK IF THERE IS AVAILABLE SERVICES
            if (snapshot.data?.docs.isEmpty ?? true) {
              // DISPLAY THERE IS NO AVAILABLE SERVICES
              return const NoServiceAvailable();

            } else {
              // DISPLAY AVAILABLE SERVICES: AS GRIDVIEW
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // NUMBER OF COLUMNS
                  crossAxisSpacing: 5, // HORIZONTAL SPACE BETWEEN CARDS
                  mainAxisSpacing: 5, // VERTICAL SPACE BETWEEN CARDS
                  childAspectRatio: 0.74, // ASPECT RATIO OF EACH CARD
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var service = snapshot.data!.docs[index];

                  return ProviderServiceCard(
                    service: service,
                    onUpdate: () {
                      // UPDATE THE DATA OF SERVICE
                      String serviceID = service.id;
                      navigateWithSlideFromRight(
                        context,
                        UpdateService(
                          receiveServiceID: serviceID,
                        ),
                        0.0,
                        1.0,
                      );
                    },
                    onDelete: () async {
                      showDeleteWarning(
                        context,
                        'Are you sure you want to delete this service?',
                        'Delete',
                        (docID) =>
                            FirebaseService.deleteService(context, docID),
                        service.id,
                      );
                    },
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: CustomFloatingActionButton(
          textLabel: "Add service",
          onPressed: () {
            navigateWithSlideFromRight(
              context,
              const AddService(),
              0.0,
              1.0,
            );
          },
        ),
      ),
    );
  }
}
