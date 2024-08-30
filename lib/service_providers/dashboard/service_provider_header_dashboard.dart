import 'package:flutter/material.dart';
import 'package:dormlanders/service_providers/my_appointments/view_all_appointments.dart';
import 'package:dormlanders/service_providers/my_services/offered_services.dart';
import 'package:dormlanders/utils/custom_snackbar.dart';
import 'package:dormlanders/utils/navigation_utils.dart';
import 'package:dormlanders/widgets/custom_button_with_number.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

// DASHBOARD HEADER CLASS
class DashboardHeaderContainer extends StatefulWidget {
  final int numberOfAppointments;
  final int numberOfServices;

  const DashboardHeaderContainer({
    super.key,
    required this.numberOfAppointments,
    required this.numberOfServices,
  });

  @override
  State<DashboardHeaderContainer> createState() => _DashboardHeaderContainer();
}

class _DashboardHeaderContainer extends State<DashboardHeaderContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          // REVENUE CONTAINER
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[

                  // NEW APPOINTMENTS AND MY SERVICES
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // APPOINTMENT BUTTON
                      CustomButtonWithNumber(
                        // NAVIGATE TO MY SERVICES SCREEN
                        numberOfServices: widget.numberOfAppointments,
                        buttonText: "Reservations",
                        onPressed: () {
                          navigateWithSlideFromRight(
                            context,
                              const ViewAllAppointments(),
                            1.0,
                            0.0,
                          );
                        },
                      ),

                      // SIZED BOX: SPACING
                      const SizedBox(width: 10),

                      // SERVICES BUTTON
                      CustomButtonWithNumber(
                        numberOfServices: widget.numberOfServices,
                        buttonText: "Dormitories",
                        onPressed: () {
                          // NAVIGATE TO MY SERVICES SCREEN
                          navigateWithSlideFromRight(
                            context,
                            const MyServices(),
                            1.0,
                            0.0,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
