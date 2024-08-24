import 'package:flutter/material.dart';

// Helper method to build BottomNavigationBarItem
class NavigationUtils {
  static BottomNavigationBarItem buildBottomNavigationBarItem({
    // PARAMETERS NEEDED
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required String label,
    required int index,
    required int selectedIndex,
    bool hasNewUpdateNotification = false,
    bool hasNewUpdateAppointment = false,
    bool hasNewUpdateMessage = false,
    bool hasGcashAccount = false,
    bool hasLocation = false,
    required bool isClient,
  }) {

    return BottomNavigationBarItem(
      icon: Stack(
        children: <Widget> [
          Icon(
            selectedIndex == index ? selectedIcon : unselectedIcon,
            size: 28,
          ),
          // SERVICE PROVIDER -> NOTIFICATION
          if (index == 2 && hasNewUpdateNotification && isClient == false)
            Positioned(
              top: 3,
              right: 3.5,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFFe91b4f),
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // CLIENT -> APPOINTMENT
          if (index == 1 && hasNewUpdateAppointment && isClient == true)
            Positioned(
              top: 3,
              right: 0,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFFe91b4f),
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // CLIENT -> NOTIFICATION
          if (index == 3 && hasNewUpdateNotification && isClient == true)
            Positioned(
              top: 3,
              right: 3.5,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFFe91b4f),
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // CLIENT -> MESSAGES
          if(index == 2 && hasNewUpdateMessage && isClient == true)
            Positioned(
              top: 2,
              right: 0,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFFe91b4f),
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // SERVICE PROVIDER -> MESSAGES
          if(index == 1 && hasNewUpdateMessage && isClient == false)
            Positioned(
              top: 1,
              right: 0,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFFe91b4f),
                  shape: BoxShape.circle,
                ),
              ),
            ),

          // SERVICE PROVIDER -> PROFILE
          if(index == 3 && hasGcashAccount && hasLocation && isClient == false)
            Positioned(
              top: 3,
              right: 3,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFFe91b4f),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}
