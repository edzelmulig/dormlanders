import 'package:auto_size_text/auto_size_text.dart';
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
                // SIZED BOX: SPACING
                const SizedBox(height: 50),

                // MENTAL BOOST LOGO
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'images/mentalboost_logo_no_bg.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),

                // SIZED BOX: SPACING
                const SizedBox(height: 25),

                // MENTAL BOOST TEXT
                const CustomTextDisplay(
                  receivedText: "MentalBoost",
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
                    color: Color(0xFF279778),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const CustomTextDisplay(
                  receivedText: "Your appointment has been sent for approval.",
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
                          TextSpan(
                            text: widget.isOnlineSelected
                                ? "Paid amount: "
                                : "Unpaid amount: ",
                            style: TextStyle(
                              color: widget.isOnlineSelected
                                  ? const Color(0xFF3C4D48)
                                  : const Color(0xFFe91b4f),
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: widget.discount > 0
                                ? "₱ ${NumberFormat("#,##0", "en_PH").format(widget.discountedPrice)}.00"
                                : "₱ ${NumberFormat("#,##0", "en_PH").format(widget.price)}.00",
                            style: TextStyle(
                              color: widget.isOnlineSelected
                                  ? const Color(0xFF3C4D48)
                                  : const Color(0xFFe91b4f),
                              fontSize: 15.5,
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
                              " once your appointment gets approved.",
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
                    buttonColor: const Color(0xFF279778),
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
