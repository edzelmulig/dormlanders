import 'package:auto_size_text/auto_size_text.dart';
import 'package:dormlanders/widgets/custom_image_display.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:dormlanders/utils/custom_snackbar.dart';
import 'package:dormlanders/widgets/custom_button.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';
import 'package:screenshot/screenshot.dart';

class AppointmentReceipt extends StatefulWidget {
  final String referenceNumber;
  final double price;
  final double discountedPrice;
  final String serviceName;
  final bool isOnlineSelected;
  final int discount;

  const AppointmentReceipt({
    super.key,
    required this.referenceNumber,
    required this.price,
    required this.discountedPrice,
    required this.serviceName,
    required this.isOnlineSelected,
    required this.discount,
  });

  @override
  State<AppointmentReceipt> createState() => _AppointmentReceiptState();
}

class _AppointmentReceiptState extends State<AppointmentReceipt> {
  late String paidAmount;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.discountedPrice < 0) {
        paidAmount = widget.price.toStringAsFixed(2);
      } else {
        paidAmount = widget.discountedPrice.toStringAsFixed(2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: const Icon(
                    Icons.clear_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Screenshot(
          controller: screenshotController,
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                // DORMLANDER LOGO
                // Container(
                //   color: Colors.red,
                //   child: ClipRRect(
                //     borderRadius: BorderRadius.circular(50),
                //     child: Image.asset(
                //       "images/dormlanders_logo.png",
                //       width: 250,
                //       height: 200,
                //       fit: BoxFit.cover,
                //     ),
                //   ),
                // ),
                Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05, bottom: 0),
                  child: const CustomImageDisplay(
                    receivedImageLocation: "images/dormlanders_logo.png",
                    receivedPaddingLeft: 0,
                    receivedPaddingRight: 0,
                    receivedPaddingTop: 0,
                    receivedPaddingBottom: 0,
                    receivedImageWidth: 350,
                    receivedImageHeight: 150,
                  ),
                ),

                // SIZED BOX: SPACING
                const SizedBox(height: 10),

                // DORMLANDER TEXT
                const CustomTextDisplay(
                  receivedText: "DormLanders Receipt",
                  receivedTextSize: 17,
                  receivedTextWeight: FontWeight.w700,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Color(0xFF3C3C40),
                ),

                // DATE
                CustomTextDisplay(
                  receivedText: _getCurrentDate(),
                  receivedTextSize: 15,
                  receivedTextWeight: FontWeight.w500,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Colors.grey,
                ),

                // SIZED BOX: SPACING
                const SizedBox(height: 30),

                // SERVICE NAME
                AutoSizeText(
                  widget.serviceName,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF193147),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const CustomTextDisplay(
                  receivedText: "Your reservation has been sent for approval.",
                  receivedTextSize: 14.5,
                  receivedTextWeight: FontWeight.w500,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Colors.grey,
                ),

                // SIZED BOX: SPACING
                const SizedBox(height: 20),

                // PAID AMOUNT
                Container(
                  margin: const EdgeInsets.only(left: 80, right: 80),
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(
                            text: "Paid amount:",
                            style: TextStyle(
                              color: Color(0xFF193147),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: widget.discount > 0
                                ? "₱ ${NumberFormat("#,##0", "en_PH").format(widget.discountedPrice)}.00"
                                : "₱ ${NumberFormat("#,##0", "en_PH").format(widget.price)}.00",
                            style: const TextStyle(
                              color: Color(0xFF193147),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // SIZED BOX: SPACING
                const SizedBox(height: 40),

                // NOTE
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              "Approval may take sometimes, you will get notify"
                              " once your reservation gets approved.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // SIZED BOX: SPACING
                const SizedBox(height: 80),

                // DOWNLOAD BUTTON
                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  child: PrimaryCustomButton(
                    buttonText: "Download receipt",
                    onPressed: () async {
                      try {
                        // Capture screenshot
                        final capturedImage =
                            await screenshotController.capture();

                        // Save screenshot to gallery
                        final result =
                            await ImageGallerySaver.saveImage(capturedImage!);

                        if (mounted) {
                          showFloatingSnackBar(
                            context,
                            "Receipt downloaded successfully!",
                            const Color(0xFF3C3C40),
                          );
                        }
                      } catch (e) {
                        debugPrint("Error capturing/saving screenshot: $e");
                      }
                    },
                    buttonHeight: 50,
                    buttonColor: const Color(0xFF193147),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontColor: Colors.white,
                    elevation: 0,
                    borderRadius: 50,
                  ),
                ),

                const Spacer(),

                Expanded(
                  child: CustomTextDisplay(
                    receivedText: "Ref No. ${widget.referenceNumber}",
                    receivedTextSize: 13,
                    receivedTextWeight: FontWeight.w700,
                    receivedLetterSpacing: 0,
                    receivedTextColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCurrentDate() {
    // Get current date
    DateTime now = DateTime.now();
    // Format date using DateFormat from intl package
    String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
    return formattedDate;
  }
}
