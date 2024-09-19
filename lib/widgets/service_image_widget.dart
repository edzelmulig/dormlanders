import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ServiceImageWidget extends StatelessWidget {
  final String imageURL;
  final String kitchenURL;
  final String comfortRoomURL;
  final String bedRoomURL;
  final bool availability;

  const ServiceImageWidget({
    super.key,
    required this.imageURL,
    required this.kitchenURL,
    required this.comfortRoomURL,
    required this.bedRoomURL,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    // Create a list of the image URLs to display in the carousel
    final List<String> imageUrls = [
      imageURL,
      kitchenURL,
      comfortRoomURL,
      bedRoomURL,
    ];

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: imageURL.isNotEmpty
            ? availability
            ? CarouselSlider(
          options: CarouselOptions(
            height: 200, // Adjust the height here
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 0.8, // Adjust this value to change width
          ),
          items: imageUrls.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.8, // Adjust width here
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7), // Apply rounded corners here
                    child: FadeInImage(
                      fit: BoxFit.cover,
                      placeholder: const AssetImage("images/no_image.jpeg"),
                      image: NetworkImage(url),
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'images/no_image.jpeg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }).toList(),
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
