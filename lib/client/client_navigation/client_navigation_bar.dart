import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dormlanders/client/client_home_page.dart';
import 'package:dormlanders/client/client_messages.dart';
import 'package:dormlanders/client/client_my_appointments.dart';
import 'package:dormlanders/client/client_notification.dart';
import 'package:dormlanders/client/client_profile.dart';
import 'package:dormlanders/service_providers/service_provider_navigation/navigation_bar_components.dart';

class ClientNavigationBar extends StatefulWidget {
  const ClientNavigationBar({super.key});

  @override
  State<ClientNavigationBar> createState() => _ClientNavigationBarState();
}

class _ClientNavigationBarState extends State<ClientNavigationBar> {
  // NAVIGATION INDEX
  static const int _defaultIndex = 0;
  int _selectedIndex = _defaultIndex;
  bool _hasNewUpdateNotification = false;
  bool _hasNewUpdateAppointment = false;
  bool _hasNewUpdateMessage = false;

  // Stream subscription
  late StreamSubscription<QuerySnapshot>? _appointmentSubscription;
  late StreamSubscription<QuerySnapshot>? _notificationSubscription;

  // LIST OF PAGES
  final List<Widget> _pages = [
    const ClientHomePage(),
    const ClientMyAppointments(),
    const ClientMessages(),
    const ClientNotifications(),
    const ClientProfile(),
  ];

  @override
  void initState() {
    super.initState();
    _listenToAppointments();
    _listenToNotifications();
    _listenToMessagesForAllChatRooms();
  }

  // LISTEN TO THE my_appointments CHANGES
  void _listenToAppointments() {
    _appointmentSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('my_appointments')
        .snapshots()
        .listen((snapshot) {
      // Check if there are new appointments
      bool hasNewAppointment = snapshot.docs.any((appointment) =>
          appointment['appointmentStatus'] == 'new' ||
          appointment['appointmentStatus'] == 'confirmed');

      if (mounted) {
        setState(() {
          _hasNewUpdateAppointment = hasNewAppointment;
        });
      }
    });
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

  // LISTEN TO THE MESSAGES FOR ALL CHAT ROOMS INVOLVING THE CURRENT USER
  void _listenToMessagesForAllChatRooms() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference myChatRoomsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('my_chatrooms');

    QuerySnapshot chatRoomsSnapshot = await myChatRoomsRef.get();
    for (QueryDocumentSnapshot chatRoomDoc in chatRoomsSnapshot.docs) {
      String chatRoomId = chatRoomDoc.id;
      _listenToMessagesForChatRoom(chatRoomId);
    }
  }

  @override
  void dispose() {
    _appointmentSubscription?.cancel();

    super.dispose();
  }

  // NAVIGATE TO BOTTOM BAR ITEM
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
            isClient: true,
          ),
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.calendar_month_rounded,
            unselectedIcon: Icons.calendar_month_outlined,
            label: "Appointments",
            index: 1,
            selectedIndex: _selectedIndex,
            hasNewUpdateAppointment: _hasNewUpdateAppointment,
            isClient: true,
          ),
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.message,
            unselectedIcon: Icons.message_outlined,
            label: "Messages",
            index: 2,
            selectedIndex: _selectedIndex,
            hasNewUpdateMessage: _hasNewUpdateMessage,
            isClient: true,
          ),
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.notifications,
            unselectedIcon: Icons.notifications_none,
            label: "Notification",
            index: 3,
            selectedIndex: _selectedIndex,
            hasNewUpdateNotification: _hasNewUpdateNotification,
            isClient: true,
          ),
          NavigationUtils.buildBottomNavigationBarItem(
            selectedIcon: Icons.person,
            unselectedIcon: Icons.person_outline,
            label: "Profile",
            index: 4,
            selectedIndex: _selectedIndex,
            isClient: true,
          ),
        ],
      ),
    );
  }
}
