import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dormlanders/client/provider_profile_screens/client_appointment.dart';
import 'package:dormlanders/utils/navigation_utils.dart';
import 'package:dormlanders/widgets/custom_button.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';
import 'package:dormlanders/widgets/service_image_widget.dart';

class ProviderServiceCardClientSide extends StatelessWidget {
  final String providerID;
  final bool availability;
  final int discount;
  final String imageURL;
  final double price;
  final String serviceDescription;
  final String serviceName;
  final String serviceType;
  final Map<String, dynamic>? providerInfo;
  final Map<String, dynamic>? clientInfo;

  const ProviderServiceCardClientSide({
    super.key,
    required this.providerID,
    required this.availability,
    required this.discount,
    required this.imageURL,
    required this.price,
    required this.serviceDescription,
    required this.serviceName,
    required this.serviceType,
    required this.providerInfo,
    required this.clientInfo,
  });


  @override
  Widget build(BuildContext context) {
    var discountedPrice = price - (price * discount / 100);

    return Center(
      child: Container(
        padding: const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 7),
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // SERVICE IMAGE
                ServiceImageWidget(
                  imageURL: imageURL,
                  availability: availability,
                ),

                // SERVICE NAME
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: CustomTextDisplay(
                    receivedText: serviceName,
                    receivedTextSize: 17,
                    receivedTextWeight: FontWeight.w600,
                    receivedLetterSpacing: 0,
                    receivedTextColor: const Color(0xFF3C4D48),
                  ),
                ),

                // SERVICE TYPE
                CustomTextDisplay(
                  receivedText: "Inclusion: $serviceType",
                  receivedTextSize: 13,
                  receivedTextWeight: FontWeight.w500,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Colors.grey,
                ),

                // SIZED BOX: SPACING
                const SizedBox(height: 3),

                // SERVICE DESCRIPTION
                Text(
                  "Description: $serviceDescription",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.2,
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                const SizedBox(height: 10),

                // SERVICE PRICE
                RichText(
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: discount > 0
                            ? "₱ ${NumberFormat("#,##0", "en_PH").format(discountedPrice)}.00"
                            : "₱ ${NumberFormat("#,##0", "en_PH").format(price)}.00",
                        style: const TextStyle(
                          color: Color(0xFF3C4D48),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: "/per month",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                // APPOINTMENT BUTTON
                availability
                    ? PrimaryCustomButton(
                        buttonText: "Book Reservation",
                        onPressed: () {
                          navigateWithSlideFromRight(
                            context,
                            ClientAppointment(
                              providerID: providerID,
                              imageURL: imageURL,
                              providerInfo: providerInfo,
                              clientInfo: clientInfo,
                              serviceName: serviceName,
                              discountedPrice: discountedPrice,
                              price: price,
                              discount: discount,
                              serviceType: serviceType,
                            ),
                            0.0,
                            1.0,
                          );
                        },
                        buttonHeight: 40,
                        buttonColor: const Color(0xFF193147),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontColor: Colors.white,
                        elevation: 0,
                        borderRadius: 7,
                      )
                    : PrimaryCustomButton(
                        buttonText: "Not Available",
                        onPressed: () {},
                        // This disables the button
                        buttonHeight: 40,
                        buttonColor: Colors.grey,
                        // Change color to indicate disabled state
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontColor: Colors.white,
                        elevation: 0,
                        borderRadius: 7,
                      ),
              ],
            ),
            discount != 0
                ? Positioned(
                    top: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 3),
                        child: Text(
                          '$discount% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                : const Text(""),
          ],
        ),
      ),
    );
  }
}
