import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

// FUNCTION THAT WILL DISPLAY THE DIALOG
void showUploadDialog({
  required BuildContext context,
  PlatformFile? selectedImage,
  required Future<void> Function() uploadFile,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => UploadDialog(
      selectedImage: selectedImage,
      uploadFile: uploadFile,
    ),
  );
}

// STATEFUL CLASS TO DISPLAY THE LOADING INDICATOR WHILE UPLOADING THE IMAGE
class UploadDialog extends StatefulWidget {
  final PlatformFile? selectedImage;
  final Future<void> Function() uploadFile;

  const UploadDialog({
    Key? key,
    required this.selectedImage,
    required this.uploadFile,
  }) : super(key: key);

  @override
  State<UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<UploadDialog> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFEFFFE),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.selectedImage != null
              ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Image.file(
                      File(widget.selectedImage!.path!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : const Text("No image selected"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if (!_isUploading)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 15,
                      top: 10,
                      bottom: 10,
                      right: 5,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: const BorderSide(
                              width: 1,
                              color: Color(0xFF222227),
                            )),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const CustomTextDisplay(
                        receivedText: "Cancel",
                        receivedTextSize: 15,
                        receivedTextWeight: FontWeight.w500,
                        receivedLetterSpacing: 0,
                        receivedTextColor: Color(0xFF222227),
                      ),
                    ),
                  ),
                ),
              // const SizedBox(
              //   width: 15,
              // ),
              if (!_isUploading)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 5,
                      top: 10,
                      bottom: 10,
                      right: 15,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF222227),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          _isUploading = true;
                        });
                        await widget.uploadFile();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const CustomTextDisplay(
                        receivedText: "Upload",
                        receivedTextSize: 15,
                        receivedTextWeight: FontWeight.w500,
                        receivedLetterSpacing: 0,
                        receivedTextColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (_isUploading)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      width: 50,
                      height: 50,
                      child: const LoadingIndicator(
                        indicatorType: Indicator.ballSpinFadeLoader,
                        colors: [Color(0xFF0D6D52)],
                      ),
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
