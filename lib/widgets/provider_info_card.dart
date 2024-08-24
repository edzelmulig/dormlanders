import 'package:flutter/material.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';
import 'package:dormlanders/widgets/profile_image_widget.dart';
import 'package:dormlanders/widgets/verified_display_name_widget.dart';

class ProviderInfoCard extends StatelessWidget {
  final String providerID;
  final String providerName;
  final String providerProfile;
  final String? providerStreet;
  final String? providerBarangay;
  final String? providerCity;
  final String? providerProvince;
  final double distance;
  final double? leftPadding;
  final double? topPadding;
  final double? bottomPadding;
  final double? rightPadding;
  final VoidCallback onPressed;

  const ProviderInfoCard({
    super.key,
    required this.providerID,
    required this.providerName,
    required this.providerProfile,
    this.providerStreet,
    this.providerBarangay,
    this.providerCity,
    this.providerProvince,
    required this.distance,
    this.leftPadding,
    this.topPadding,
    this.bottomPadding,
    this.rightPadding,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDistance = distance.toStringAsFixed(0);

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: leftPadding!,
          top: topPadding!,
          right: rightPadding!,
          bottom: bottomPadding!,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            padding: EdgeInsets.zero,
            elevation: 0,
            minimumSize: const Size(double.infinity, 100),
          ),
          onPressed: onPressed,
          child: Row(
            children: <Widget>[
              // PROVIDER PROFILE
              Padding(
                padding: const EdgeInsets.all(12),
                child: ProfileImageWidget(
                  width: 75,
                  height: 75,
                  borderRadius: 6,
                  imageURL: providerProfile,
                ),
              ),

              // TEXT: DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // DISPLAY NAME & VERIFIED LOGO
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          VerifiedDisplayNameWidget(
                            displayName: providerName,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            iconSize: 16,
                          ),
                        ],
                      ),
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(height: 5),

                    // LOCATION
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // CITY

                        Padding(
                          padding: EdgeInsets.only(right: 3),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFF9F9D9D),
                            size: 17,
                          ),
                        ),

                        Expanded(
                          child: Text(
                            "$providerStreet, $providerBarangay",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
                              height: 0.9,
                              color: Color(0xFF9F9D9D),
                              fontWeight: FontWeight.w500,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                  // DISTANCE
                  Text(
                    "$providerCity, $providerProvince · $formattedDistance km away",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                      height: 0.9,
                      color: Color(0xFF9F9D9D),
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),

                  // SIZED BOX: SPACING
                  const SizedBox(height: 15),
                  ],
                ),
              ),

              // ICON: ARROW
              const Padding(
                padding: EdgeInsets.only(
                  right: 15,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 17,
                    color: Color(0xFF9F9D9D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
