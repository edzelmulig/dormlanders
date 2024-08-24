import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dormlanders/service_providers/service_provider_home_page.dart';
import 'package:dormlanders/service_providers/service_provider_messages.dart';
import 'package:dormlanders/service_providers/service_provider_notification.dart';
import 'package:dormlanders/service_providers/service_provider_profile.dart';
import 'package:dormlanders/service_providers/service_provider_navigation/navigation_bar_components.dart';

class ProviderNavigationBar extends StatefulWidget {
  const ProviderNavigationBar({Key? key}) : super(key: key);

  @override
  State<ProviderNavigationBar> createState() => _ProviderNavigationBar();
}

class _ProviderNavigationBar extends State<ProviderNavigationBar> {
  // Navigation index
  static const int _defaultIndex = 0;
  int _selectedIndex = _defaultIndex;
  bool _hasNewUpdateNotification = false;
  bool _hasNewUpdateMessage = false;
  bool _hasGcashAccount = false;
  bool _hasLocation = false;

  // Stream subscription
  late StreamSubscription<QuerySnapshot>? _notificationSubscription;

  // List of pages
  final List<Widget> _pages = [
    const ServiceProviderHomePage(),
    ServiceProviderMessages(),
    const ServiceProviderNotification(),
    const ServiceProviderProfile(),
  ];

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
    _listenToMessagesForAllChatRooms();
    _checkUserGcashAndLocation();
  }

  // LISTEN TO THE NOTIFICATION CHANGES
  void _listenToNotifications() {
    _notificationSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('my_appointments')
        .snapshots()
        .listen((snapshot) {
      // Check if there are new appointments
      bool hasNewNotification = snapshot.docs.any((appointment) =>
          appointment['appointmentStatus'] == 'new' ||
          appointment['appointmentStatus'] == 'cancelled');

      if (mounted) {
        setState(() {
          _hasNewUpdateNotification = hasNewNotification;
        });
      }
    });
  }

  // LISTEN TO CHATROOM/MESSAGES CHANGES
  void _listenToMessagesForChatRoom(String chatRoomId) {
    FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      // Check if there are any new messages in the snapshot
      bool hasNewMessage = snapshot.docChanges.any((change) =>
      change.type == DocumentChangeType.added);

      if (mounted) {
        setState(() {
          _hasNewUpdateMessage = hasNewMessage;
        });
      }
    });
  }


  // LISTEN TO THE MESSAGES FOR ALL CHAT ROOMS OF THE CURRENT USER
  void _listenToMessagesForAllChatRooms() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference myChatRoomsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('my_chatrooms');

    QuerySnapshot chatRoomsSnapshot = await myChatRoomsRef.get();
    for (QueryDocumentSnapshot chatRoomDoc in chatRoomsSnapshot.docs) {
      String chatRoomId = chatRoomDoc.id;
      _listenToMessagesForChatRoom(chatRoomId);
    }
  }

  // CHECK IF THE USER HAS CLIENT HAS NO GCASH NAME & NUMBER
  void _checkUserGcashAndLocation() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;

    // Check user's GCash account
    DocumentSnapshot userInfoSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('my_information')
        .doc('info')
        .get();

    // Check if the snapshot exists and contains data
    if (userInfoSnapshot.exists) {
      // Retrieve accountName and accountNumber from the snapshot data
      String accountName = userInfoSnapshot['accountName'];
      String accountNumber = userInfoSnapshot['accountNumber'];

      // Check if accountName and accountNumber are not null and not empty
      if (accountNumber.isNotEmpty && accountName.isNotEmpty) {
        // Both accountName and accountNumber have values
        setState(() {
          _hasGcashAccount = true;
        });
      } else {
        // Either accountName or accountNumber is null or empty
        setState(() {
          _hasGcashAccount = false;
        });
      }
    } else {
      // Document does not exist
      print('User document does not exist');
    }

    // Check user's location information
    DocumentSnapshot locationSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('my_information')
        .doc('location')
        .get();

    // Check if the location snapshot exists and contains data
    bool hasLocation = locationSnapshot.exists;
    setState(() {
      _hasLocation = hasLocation;
    });
  }


  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // Navigate to bottom bar item
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _hasNewUpdateNotification = false;
      }
    });
  }

  // LISTEN TO THE CHANGES IN THE NOTIFICATION

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFEFFFE),
        unselectedFontSize: 11,
        selectedFontSize: 11,
        selectedItemColor: const Color(0xFF3C3C40),
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
        items: [
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.home_rounded,
            unselectedIcon: Icons.home_outlined,
            label: "Home",
            index: 0,
            selectedIndex: _selectedIndex,
            isClient: false,
          ),
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.message,
            unselectedIcon: Icons.message_outlined,
            label: "Messages",
            index: 1,
            selectedIndex: _selectedIndex,
            hasNewUpdateMessage: _hasNewUpdateMessage,
            isClient: false,
          ),
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.notifications,
            unselectedIcon: Icons.notifications_none,
            label: "Notification",
            index: 2,
            selectedIndex: _selectedIndex,
            hasNewUpdateNotification: _hasNewUpdateNotification,
            isClient: false,
          ),
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.person,
            unselectedIcon: Icons.person_outline,
            label: "Profile",
            index: 3,
            selectedIndex: _selectedIndex,
            hasGcashAccount: _hasGcashAccount,
            hasLocation: _hasLocation,
            isClient: false,
          ),
        ],
      ),
    );
  }
}
