import 'package:flutter/material.dart';

class ProfileImageWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final String? imageURL;

  const ProfileImageWidget({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.imageURL,
  });

  @override
  Widget build(BuildContext context) {
    // Using `?? ""` to ensure a non-null String is always passed to NetworkImage
    String effectiveURL = imageURL ?? "";

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: effectiveURL.isNotEmpty
            ? FadeInImage(
                fit: BoxFit.cover,
                placeholder: const AssetImage("images/no_image.jpeg"),
                image: NetworkImage(effectiveURL),
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'images/no_image.jpeg',
                    fit: BoxFit.cover,
                  );
                },
              )
            : const FadeInImage(
                fit: BoxFit.cover,
                placeholder: AssetImage("images/no_image.jpeg"),
                image: AssetImage("images/no_image.jpeg"),
              ),
      ),
    );
  }
}
