import 'package:flutter/material.dart';

class ServiceImageWidget extends StatelessWidget {
  final String imageURL;
  final bool availability;

  const ServiceImageWidget({
    super.key,
    required this.imageURL,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 110,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: imageURL.isNotEmpty
            ? availability
                ? FadeInImage(
                    fit: BoxFit.cover,
                    placeholder: const AssetImage("images/no_image.jpeg"),
                    image: NetworkImage(imageURL),
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'images/no_image.jpeg',
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : const FadeInImage(
                    fit: BoxFit.cover,
                    placeholder: AssetImage("images/unavailable.jpeg"),
                    image: AssetImage("images/unavailable.jpeg"),
                  )
            : Image.asset(
                "images/no_image.jpeg",
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
