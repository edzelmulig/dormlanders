import 'package:flutter/material.dart';

// CLASS THAT WILL HANDE CUSTOM IMAGE COMPONENTS
class CustomImageDisplay extends StatelessWidget {
  final String receivedImageLocation;
  final double receivedPaddingLeft;
  final double receivedPaddingRight;
  final double receivedPaddingTop;
  final double receivedPaddingBottom;
  final double receivedImageWidth;
  final double receivedImageHeight;

  const CustomImageDisplay({
    super.key,
    required this.receivedImageLocation,
    required this.receivedPaddingLeft,
    required this.receivedPaddingRight,
    required this.receivedPaddingTop,
    required this.receivedPaddingBottom,
    required this.receivedImageWidth,
    required this.receivedImageHeight,
  });

  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = AssetImage(receivedImageLocation);
    Image image = Image(image: assetImage);
    return Container(
      padding: EdgeInsets.only(
        left: receivedPaddingLeft,
        right: receivedPaddingRight,
        top: receivedPaddingTop,
        bottom: receivedPaddingBottom,
      ),
      width: receivedImageWidth,
      height: receivedImageHeight,
      child: image,
    );
  }
}