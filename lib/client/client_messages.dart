import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dormlanders/services/chat/chat_service.dart';
import 'package:dormlanders/services/user_profile_service.dart';
import 'package:dormlanders/utils/chat_page.dart';
import 'package:dormlanders/utils/no_available_data.dart';
import 'package:dormlanders/utils/shimmer_client_home_page.dart';
import 'package:dormlanders/widgets/profile_image_widget.dart';

class ClientMessages extends StatefulWidget {
  const ClientMessages({super.key});

  @override
  State<ClientMessages> createState() => _ClientMessagesState();
}

class _ClientMessagesState extends State<ClientMessages> {
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
    //   10,
    // );
  }


  // CHAT AND AUTH SERVICES
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Messages",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3C3C40),
          ),
        ),
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('my_appointments')
          .where('appointmentStatus', whereIn: ['new', 'confirmed'])
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
            icon: Icons.email_rounded,
            text: "messages",
          );
        } else {
          // DISPLAY THE DATA
          Map<String, dynamic> lastConversation = {}; // Store last conversation for each provider-client pair

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // Access the data of each document using snapshot.data!.docs[index].data()
              final userData = snapshot.data!.docs[index].data();
              //print("*** $userData");

              String getTimeDifference() {
                DateTime createdAt = (userData['createdAt'] as Timestamp).toDate();
                Duration difference = DateTime.now().difference(createdAt);

                if (difference.inDays >= 30) {
                  int months = difference.inDays ~/ 30;
                  if (months == 1) {
                    return '1 month ago';
                  } else {
                    return '$months months ago';
                  }
                } else if (difference.inHours >= 24) {
                  int days = difference.inDays;
                  if (days == 1) {
                    return '1 day ago';
                  } else {
                    return '$days days ago';
                  }
                } else if (difference.inHours > 0) {
                  return '${difference.inHours} hours ago';
                } else {
                  return '${difference.inMinutes} minutes ago';
                }
              }

              final String clientUserID = userID;
              final String clientID = userData['clientID'];
              final String conversationID = '$clientUserID-$clientID';

              if (lastConversation.containsKey(conversationID)) {
                return const SizedBox(); // Skip if conversation already displayed
              } else {
                lastConversation[conversationID] = true; // Mark conversation as displayed
              }

              // Fetch provider information asynchronously
              return FutureBuilder(
                future: UserProfileService().getUserData(
                  clientID,
                  // Assuming 'clientID' is the provider ID
                  "personal_information",
                  "info",
                ),
                builder: (context, providerSnapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // DISPLAY LOADING
                    return const ServiceShimmer(itemCount: 3, containerHeight: 75);
                  }


                  if (providerSnapshot.hasError) {
                    // Handle error if fetching provider information fails
                    return const Text('Error fetching provider data');
                  }

                  final providerData = providerSnapshot.data;

                  if (providerData == null) {
                    // Handle the case where provider data is null
                    return const SizedBox();
                  }

                  // You can now use userData and providerData to display the data in your UI
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 1.0),
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                  receiverData: providerData,
                                  receiverID: userData['clientID']),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            children: <Widget>[
                              // CLIENT PROFILE
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  top: 10,
                                  bottom: 10,
                                  right: 15,
                                ),
                                child: ProfileImageWidget(
                                  width: 60,
                                  height: 60,
                                  borderRadius: 6,
                                  imageURL: providerData['imageURL'],
                                ),
                              ),
                              // APPOINTMENT DETAILS
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // CLIENT NAME
                                    RichText(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: providerData['displayName'],
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF3C3C40),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // APPOINTMENT CREATED
                                    SizedBox(
                                      child: Text(
                                        getTimeDifference(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          height: 1.2,
                                          fontSize: 11,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
