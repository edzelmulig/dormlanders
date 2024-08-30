import 'package:flutter/material.dart';
import 'package:dormlanders/client/my_appointments/appointment_client_modal.dart';
import 'package:dormlanders/services/user_profile_service.dart';
import 'package:dormlanders/widgets/profile_image_widget.dart';

class AppointmentCardClient extends StatefulWidget {
  // PARAMETERS NEEDED
  final dynamic appointment;
  final String appointmentID;

  const AppointmentCardClient({
    super.key,
    required this.appointment,
    required this.appointmentID,
  });

  @override
  State<AppointmentCardClient> createState() => _AppointmentCardClientState();
}

class _AppointmentCardClientState extends State<AppointmentCardClient> {
  late Map<String, dynamic> providerData = {};

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
        providerData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFE5E7EB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        onPressed: () {
          appointmentClientModal(context, widget.appointment, providerData, widget.appointmentID);
        },
        child: Row(
          children: <Widget>[
            // CLIENT PROFILE
            Padding(
              padding: const EdgeInsets.all(10),
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
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Text(
                      providerData.isNotEmpty
                          ? "${providerData['displayName']}"
                          : "${providerData['firstName']} ${providerData['lastName']}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: 1.3,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3C3C40),
                      ),
                    ),
                  ),
                  // APPOINTMENT DATE AND TIME
                  Text(
                    "${widget.appointment['appointmentDate']} at ${widget.appointment['appointmentTime']}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: 0.9,
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF3C3C40),
                    ),
                  ),
                  // STATUS INDICATOR
                  Container(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    margin: const EdgeInsets.only(top: 3),
                    width: 100,
                    decoration: BoxDecoration(
                      color: widget.appointment['appointmentStatus'] == 'new'
                          ? const Color(0xFFFD964F).withOpacity(0.3)
                          : widget.appointment['appointmentStatus'] == 'confirmed'
                          ? const Color(0xFF279778).withOpacity(0.3)
                          : widget.appointment['appointmentStatus'] ==
                          'cancelled'
                          ? const Color(0xFFF83333).withOpacity(0.3)
                          : const Color(0xFF3680EE).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: widget.appointment['appointmentStatus'] ==
                                  'new'
                                  ? 'Pending'
                                  : widget.appointment['appointmentStatus'] ==
                                  'confirmed'
                                  ? 'Confirmed'
                                  : widget.appointment['appointmentStatus'] ==
                                  'cancelled'
                                  ? 'Cancelled'
                                  : 'Done',
                              style: TextStyle(
                                color: widget.appointment['appointmentStatus'] ==
                                    'new'
                                    ? const Color(0xFFFD964F)
                                    : widget.appointment['appointmentStatus'] ==
                                    'confirmed'
                                    ? const Color(0xFF279778)
                                    : widget.appointment[
                                'appointmentStatus'] ==
                                    'cancelled'
                                    ? const Color(0xFFF83333)
                                    : const Color(0xFF3680EE),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
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
                Icons.more_vert_rounded,
                size: 22,
                color: Color(0xFF3C4D48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
