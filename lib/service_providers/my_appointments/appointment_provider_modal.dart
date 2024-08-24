import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dormlanders/services/firebase_services.dart';
import 'package:dormlanders/utils/custom_snackbar.dart';
import 'package:dormlanders/widgets/custom_button.dart';
import 'package:dormlanders/widgets/profile_image_widget.dart';

// MODAL BOTTOM FOR ACTION CONFIRMATION
void appointmentProviderModal(
  BuildContext context,
  final dynamic appointment,
  Map<String, dynamic> clientData,
  final String appointmentID,
) {
  showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    context: context,
    isDismissible: true,
    backgroundColor: Colors.white,
    elevation: 0,
    builder: (context) {
      // print("==C $appointmentID");
      // print("===SP ${appointment['appointmentID']}");
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 180, right: 180),
              child: Container(
                width: double.infinity,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: const Color(0xFFE5E7EB),
                ),
              ),
            ),
            // CLIENT PERSONAL DATA
            Padding(
              padding: const EdgeInsets.only(
                left: 30,
                top: 20,
                right: 30,
                bottom: 20,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // CLIENT PROFILE
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ProfileImageWidget(
                      width: 110,
                      height: 100,
                      borderRadius: 12,
                      imageURL: clientData['imageURL'],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // CLIENT NAME
                        SizedBox(
                          child: Text(
                            "${clientData['firstName']} ${clientData['lastName']}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              height: 1.3,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3C3C40),
                            ),
                          ),
                        ),

                        // SIZED BOX: SPACING
                        const SizedBox(height: 12),

                        // CONTACT NUMBER
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.phone_rounded,
                                size: 18,
                                color: Color(0xFF3C3C40),
                              ),
                            ),
                            Text(
                              clientData['phoneNumber'] ?? 'Loading...',
                              style: const TextStyle(
                                height: 1.2,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3C3C40),
                              ),
                            ),
                          ],
                        ),

                        // CONTACT NUMBER
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.email_rounded,
                                size: 18,
                                color: Color(0xFF3C3C40),
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                child: Text(
                                  clientData['email'] ?? 'Loading...',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    height: 1.2,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF3C3C40),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // SERVICE DETAILS
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1EF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: <Widget>[
                    // SERVICE DETAILS
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // SERVICE NAME
                          Text(
                            appointment['serviceName'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              height: 1.2,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3C3C40),
                            ),
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            child: Text(
                              "${appointment['appointmentDate']} | ${appointment['appointmentTime']}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                height: 0.9,
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF3C3C40),
                              ),
                            ),
                          ),

                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: appointment['serviceType'] !=
                                      "Face-to-face consultation"
                                      ? "${appointment['serviceType']}  |  Paid via GCash "
                                      : "${appointment['serviceType']}  |  Unpaid ",
                                  style: const TextStyle(
                                    height: 0.9,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF3C3C40),
                                  ),
                                ),
                                WidgetSpan(
                                  child: Center(
                                    child: appointment['serviceType'] ==
                                        "Face-to-face consultation"
                                        ? const Icon(
                                      Icons.cancel_rounded,
                                      size: 15,
                                      color: Color(0xFFe91b4f),
                                    )
                                        : const Icon(
                                      Icons.check_circle,
                                      size: 15,
                                      color: Color(0xFF279778),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // REFERENCE NUMBER
                          const SizedBox(height: 10),

                          SizedBox(
                            child: Text(
                              "Ref No. ${appointment['referenceNumber']}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                height: 0.9,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            var response = await Dio().get(
                                "${appointment['receiptImage']}",
                                options:
                                    Options(responseType: ResponseType.bytes));

                            if (response.statusCode == 200) {
                              // CONVERT RESPONSE DATA TO Uint8List
                              Uint8List imageData = response.data as Uint8List;

                              final result =
                                  await ImageGallerySaver.saveImage(imageData);
                              if (context.mounted) {
                                showFloatingSnackBar(
                                  context,
                                  "Photo saved to this device",
                                  const Color(0xFF3C3C40),
                                );
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              }
                            } else {
                              print(
                                  "Error: Failed to download image. Status code: ${response.statusCode}");
                            }
                          } catch (e) {
                            debugPrint('Error downloading image: $e');
                          }
                        },
                        child: const Icon(
                          Icons.file_download_outlined,
                          size: 27,
                          color: Color(0xFF3C3C40),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SIZED BOX: SPACING
            const SizedBox(height: 20),

            if (appointment['appointmentStatus'] == 'new') ...[
              // IF NOT CONFIRMED OR DONE
              Column(
                children: <Widget>[
                  // CONFIRM BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: PrimaryCustomButton(
                      buttonText: "Confirm",
                      onPressed: () async {
                        try {
                          // UPDATE THE appointmentStatus ON PROVIDER'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointmentID,
                            providerID: FirebaseAuth.instance.currentUser!.uid,
                            fieldsToUpdate: {
                              'appointmentStatus': 'confirmed',
                            },
                          );

                          // UPDATE THE appointmentStatus ON CLIENT'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointment['appointmentID'],
                            providerID: appointment['clientID'],
                            fieldsToUpdate: {
                              'appointmentStatus': 'confirmed',
                            },
                          );

                          Navigator.of(context).pop();
                          if (context.mounted) {
                            showFloatingSnackBar(
                              context,
                              'Appointment updated successfully.',
                              const Color(0xFF279778),
                            );
                          }
                        } catch (e) {
                          print('Error confirming appointment: $e');
                        }
                      },
                      buttonHeight: 55,
                      buttonColor: const Color(0xFF279778),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: Colors.white,
                      elevation: 0,
                      borderRadius: 10,
                    ),
                  ),

                  // SIZED BOX: SPACING
                  const SizedBox(height: 10),

                  // CANCEL BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: PrimaryCustomButton(
                      borderColor: const Color(0xFFBDBDC7),
                      borderWidth: 1.5,
                      buttonText: "Cancel",
                      onPressed: () async {
                        try {
                          // UPDATE THE appointmentStatus ON PROVIDER'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointmentID,
                            providerID: FirebaseAuth.instance.currentUser!.uid,
                            fieldsToUpdate: {
                              'appointmentStatus': 'cancelled',
                            },
                          );

                          // UPDATE THE appointmentStatus ON CLIENT'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointment['appointmentID'],
                            providerID: appointment['clientID'],
                            fieldsToUpdate: {
                              'appointmentStatus': 'cancelled',
                            },
                          );

                          Navigator.of(context).pop();
                          if (context.mounted) {
                            showFloatingSnackBar(
                              context,
                              'Appointment cancelled successfully.',
                              const Color(0xFF279778),
                            );
                          }
                        } catch (e) {
                          print('Error cancelling appointment: $e');
                        }
                      },
                      buttonHeight: 55,
                      buttonColor: Colors.transparent,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: const Color(0xFFe91b4f),
                      elevation: 0,
                      borderRadius: 10,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ] else if (appointment['appointmentStatus'] == 'confirmed') ...[
              Column(
                children: <Widget>[
                  // CONFIRM BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: PrimaryCustomButton(
                      buttonText: "Done",
                      onPressed: () async {
                        try {
                          // UPDATE THE appointmentStatus ON PROVIDER'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointmentID,
                            providerID: FirebaseAuth.instance.currentUser!.uid,
                            fieldsToUpdate: {
                              'appointmentStatus': 'done',
                            },
                          );

                          // UPDATE THE appointmentStatus ON CLIENT'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointment['appointmentID'],
                            providerID: appointment['clientID'],
                            fieldsToUpdate: {
                              'appointmentStatus': 'done',
                            },
                          );

                          Navigator.of(context).pop();
                          if (context.mounted) {
                            showFloatingSnackBar(
                              context,
                              'Appointment done.',
                              const Color(0xFF279778),
                            );
                          }
                        } catch (e) {
                          print('Error updating appointment: $e');
                        }
                      },
                      buttonHeight: 55,
                      buttonColor: const Color(0xFF3680EE),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: Colors.white,
                      elevation: 0,
                      borderRadius: 10,
                    ),
                  ),

                  // SIZED BOX: SPACING
                  const SizedBox(height: 10),

                  // CANCEL BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: PrimaryCustomButton(
                      borderColor: const Color(0xFFBDBDC7),
                      borderWidth: 1.5,
                      buttonText: "Cancel",
                      onPressed: () async {
                        try {
                          // UPDATE THE appointmentStatus ON PROVIDER'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointmentID,
                            providerID: FirebaseAuth.instance.currentUser!.uid,
                            fieldsToUpdate: {
                              'appointmentStatus': 'cancelled',
                            },
                          );

                          // UPDATE THE appointmentStatus ON CLIENT'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointment['appointmentID'],
                            providerID: appointment['clientID'],
                            fieldsToUpdate: {
                              'appointmentStatus': 'cancelled',
                            },
                          );
                          Navigator.of(context).pop();
                          if (context.mounted) {
                            showFloatingSnackBar(
                              context,
                              'Appointment cancelled successfully.',
                              const Color(0xFF279778),
                            );
                          }
                        } catch (e) {
                          print('Error cancelling appointment: $e');
                        }
                      },
                      buttonHeight: 55,
                      buttonColor: Colors.transparent,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: const Color(0xFFe91b4f),
                      elevation: 0,
                      borderRadius: 10,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ] else if (appointment['appointmentStatus'] == 'cancelled') ...[
              Column(
                children: <Widget>[
                  // CONFIRM BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: PrimaryCustomButton(
                      buttonText: "Cancelled",
                      onPressed: () {},
                      buttonHeight: 55,
                      buttonColor: const Color(0xFF3C3C40),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: Colors.white,
                      elevation: 0,
                      borderRadius: 10,
                    ),
                  ),

                  // SIZED BOX: SPACING
                  const SizedBox(height: 20),
                ],
              ),
            ] else if (appointment['appointmentStatus'] == 'done') ...[
              Column(
                children: <Widget>[
                  // CONFIRM BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: PrimaryCustomButton(
                      buttonText: "Done",
                      onPressed: () {},
                      buttonHeight: 55,
                      buttonColor: const Color(0xFF3C3C40),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: Colors.white,
                      elevation: 0,
                      borderRadius: 10,
                    ),
                  ),

                  // SIZED BOX: SPACING
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ],
        ),
      );
    },
  );
}
