import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dormlanders/widgets/custom_camera_icon.dart';

class CustomUpdateUserProfile extends StatelessWidget {

  final String? imageURL;
  final PlatformFile? selectedImage;
  final VoidCallback onPressed;
  final double imageWidth;
  final double imageHeight;

  const CustomUpdateUserProfile({
    super.key,
    required this.imageURL,
    required this.selectedImage,
    required this.imageWidth,
    required this.imageHeight,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return // USER PROFILE PICTURE
      Center(
        child: Stack(
          children: <Widget>[
            if (imageURL != null)
            // DISPLAY THE UPDATED IMAGE FROM THE URL
              Container(
                padding: const EdgeInsets.all(4),
                // Adjust the padding to control the border thickness
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF8C8C8C), // Set border color
                    width: 0.5, // Set border width
                  ),
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: imageWidth,
                    height: imageHeight,
                    child: FadeInImage(
                      fit: BoxFit.cover,
                      placeholder:
                      const AssetImage("images/no_image.jpeg"),
                      image: NetworkImage(imageURL!),
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'images/no_image.jpeg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              if (selectedImage != null)
              // DISPLAY THE SELECTED IMAGE BEFORE UPLOADING IT
                CircleAvatar(
                  backgroundImage: FileImage(File(selectedImage!.path!)),
                  radius: 70,
                )
              else
              // DEFAULT PLACEHOLDER OF AN IMAGE
                const CircleAvatar(
                  backgroundImage: AssetImage("images/no_image.jpeg"),
                  radius: 70,
                ),
            // CAMERA ICON BUTTON
            Positioned(
              bottom: 10,
              right: 0,
              child: CustomCameraIcon(
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      );
  }
}


class CustomUserProfile extends StatelessWidget {

  final String? imageURL;
  final double imageWidth;
  final double imageHeight;

  const CustomUserProfile({
    super.key,
    required this.imageURL,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(
          children: <Widget>[
            if (imageURL != null)
            // DISPLAY THE UPDATED IMAGE FROM THE URL
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(2),
                // Adjust the padding to control the border thickness
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF8C8C8C), // Set border color
                    width: 0.5, // Set border width
                  ),
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: imageWidth,
                    height: imageHeight,
                    child: FadeInImage(
                      fit: BoxFit.cover,
                      placeholder:
                      const AssetImage("images/no_image.jpeg"),
                      image: NetworkImage(imageURL!),
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'images/no_image.jpeg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              )
              else
            // DEFAULT PLACEHOLDER IMAGE, SIZE ADJUSTED TO MATCH THE ABOVE
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(2), // Adjust to match the border thickness of the image container
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF8C8C8C), // Match border color
                    width: 0.5, // Match border width
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    width: imageWidth, // Match the width of the image container
                    height: imageHeight, // Match the height of the image container
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("images/no_image.jpeg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
  }
}
