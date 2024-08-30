import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dormlanders/service_providers/my_appointments/appointment_provider_modal.dart';
import 'package:dormlanders/services/user_profile_service.dart';
import 'package:dormlanders/widgets/profile_image_widget.dart';

class ClientNotificationCard extends StatefulWidget {
  // PARAMETERS NEEDED
  final dynamic appointment;
  final String appointmentID;

  const ClientNotificationCard({
    super.key,
    required this.appointment,
    required this.appointmentID,
  });

  @override
  State<ClientNotificationCard> createState() => _ClientNotificationCardState();
}

class _ClientNotificationCardState extends State<ClientNotificationCard> {
  late Map<String, dynamic> clientData = {};

  @override
  void initState() {
    super.initState();
    _getClientData();
  }

  // FETCH CLIENT DATA
  Future _getClientData() async {
    final data = await UserProfileService().getUserData(
      widget.appointment['clientID'],
      'personal_information',
      'info',
    );

    if (mounted) {
      setState(() {
        // ASSIGN THE INITIAL VALUE TO THE CONTROLLERS
        clientData = data;
      });
    }
  }

  String getTimeDifference() {
    DateTime createdAt = (widget.appointment['createdAt'] as Timestamp).toDate();
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


  @override
  Widget build(BuildContext context) {
    final Color containerColor;
    String messageText = '';
    if ((widget.appointment['appointmentStatus'] == 'new') ||
    (widget.appointment['appointmentStatus'] == 'confirmed')) {
      containerColor = Colors.white;
      messageText = "You booked an reservation with ";
    } else {
      containerColor = const Color(0xFFE5E7EB);
    }
    if(widget.appointment['appointmentStatus'] == 'confirmed') {
      messageText = "Your reservation is confirmed by ";
    } else if(widget.appointment['appointmentStatus'] == 'cancelled') {
      messageText = "Your reservation has been cancelled by ";
    } else if(widget.appointment['appointmentStatus'] == 'done') {
      messageText = "Your reservation was marked done by ";
    }

    return Material(
      color: containerColor,
      child: InkWell(
        onTap: () {
          appointmentProviderModal(
              context, widget.appointment, clientData, widget.appointmentID);
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
                  imageURL: clientData['imageURL'],
                ),
              ),
              // APPOINTMENT DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // CLIENT NAME
                    RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: messageText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF3C3C40),
                            ),
                          ),
                          TextSpan(
                            text: clientData.isNotEmpty
                                ? "${clientData['displayName']}."
                                : "Client name",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3C3C40),
                            ),
                          ),

                        ],
                      ),
                    ),


                    // SIZED BOX: SPACING
                    const SizedBox(height: 5),


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

              // ICON
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.more_horiz_rounded,
                  size: 22,
                  color: Color(0xFF3C4D48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
