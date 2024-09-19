import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:dormlanders/services/firebase_services.dart';
import 'package:dormlanders/services/provider_services.dart';
import 'package:dormlanders/utils/custom_snackbar.dart';
import 'package:dormlanders/utils/navigation_utils.dart';
import 'package:dormlanders/utils/no_internet_screen.dart';
import 'package:dormlanders/widgets/appointment_receipt.dart';
import 'package:dormlanders/widgets/custom_app_bar.dart';
import 'package:dormlanders/widgets/custom_button.dart';
import 'package:dormlanders/widgets/custom_image_display.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';
import 'package:dormlanders/widgets/date_picker_button.dart';
import 'package:dormlanders/widgets/profile_image_widget.dart';

class ClientAppointment extends StatefulWidget {
  final String providerID;
  final Map<String, dynamic>? providerInfo;
  final Map<String, dynamic>? clientInfo;
  final String imageURL;
  final String serviceName;
  final double discountedPrice;
  final double price;
  final int discount;
  final String dormKeyFeatures;

  const ClientAppointment({
    super.key,
    required this.providerID,
    required this.imageURL,
    required this.providerInfo,
    required this.clientInfo,
    required this.serviceName,
    required this.price,
    required this.discountedPrice,
    required this.discount,
    required this.dormKeyFeatures,
  });

  @override
  State<ClientAppointment> createState() => _ClientAppointmentState();
}

class _ClientAppointmentState extends State<ClientAppointment> {
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;

  final clientID = FirebaseAuth.instance.currentUser!.uid;
  late bool isOnline;
  late bool isFaceToFace;
  late bool isBoth;
  late bool _isOnlineSelected = true;

  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late String date = '';
  late String time = '';
  late String selectedServiceType;
  String referenceNumber = '';
  String providerPhoneNumber = '';

  PlatformFile? selectedImage;

  // FORM KEY DECLARATION
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _checkConnection();
    _exitTimer = Timer(const Duration(seconds: 15), () {});

    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    _exitTimer.cancel();
    super.dispose();
  }

  // CHECK CONNECTION
  Future<void> _checkConnection() async {
    _connectionSubscription = InternetConnectionChecker().onStatusChange.listen(
      (status) {
        // Check if the context is still mounted
        if (!mounted) return;

        setState(() {
          _isConnectedToInternet = status == InternetConnectionStatus.connected;
        });

        if (_isConnectedToInternet) {
          _showConnectedSnackBar();
        } else {
          _showDisconnectedSnackBar();
        }
      },
    );
  }

  void _showDisconnectedSnackBar() {
    if (!_isConnectedToInternet) {
      // Check if a disconnected snack bar is already being displayed
      if (!isDisconnectedSnackBarVisible) {
        // showFloatingSnackBarWithIcon(
        //   context,
        //   'No internet connection',
        //   Icons.wifi_off_rounded,
        //   10,
        // );
        // Set the flag to indicate that the disconnected snack bar is being displayed
        isDisconnectedSnackBarVisible = true;

        // Restart the app after 10 seconds unless connection is restored
        _exitTimer = Timer(const Duration(seconds: 15), () async {
          await InternetConnectionChecker().hasConnection
              ? _exitTimer.cancel()
              : SystemNavigator.pop();
        });
      }
    }
  }

  void _showConnectedSnackBar() {
    if (isDisconnectedSnackBarVisible) {
      // If a disconnected snack bar is being displayed, hide it
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // Reset the flag
      isDisconnectedSnackBarVisible = false;
    }

    // showFloatingSnackBarWithIcon(
    //   context,
    //   'Connected to the internet',
    //   Icons.wifi_rounded,
    //   10,
    // );
  }

  // FUNCTION THAT WILL HANDLE FOR BOOKING APPOINTMENT TO SERVICE PROVIDER
  void handleAddAppointment() async {
    referenceNumber = generateReferenceNumber();

    String providerAppointmentID = await FirebaseService.addAppointment(
      context: context,
      formKey: formKey,
      clientID: clientID,
      providerID: widget.providerID,
      serviceName: widget.serviceName,
      date: date,
      time: time,
      selectedImage: selectedImage,
      referenceNumber: referenceNumber,
    );

    if (providerAppointmentID.isNotEmpty) {
      try {
        // SAVE APPOINTMENT ID COPY -> TO CLIENT SIDE
        String clientAppointmentID =
            await handleAddAppointmentClient(providerAppointmentID);

        // SEND MESSAGE TO THE SERVICE PROVIDER

        // if (response.statusCode == 200) {
        //   print('OTP sent successfully');
        //   print(response.body);
        // } else {
        //   print('Failed to send OTP');
        //   print(response.body);
        // }

        // DISPLAY RECEIPT if appointment ID is successfully obtained
        if (mounted && clientAppointmentID.isNotEmpty) {
          navigateWithSlideFromRight(
            context,
            AppointmentReceipt(
              referenceNumber: referenceNumber,
              price: widget.price,
              discountedPrice: widget.discountedPrice,
              serviceName: widget.serviceName,
              isOnlineSelected: _isOnlineSelected,
              discount: widget.discount,
            ),
            0.0,
            1.0,
          );
        }
      } catch (e) {
        // Handle any errors that occur during appointment addition
        print("Error handling appointment: $e");
      }
    }

    if (context.mounted) {
      showFloatingSnackBar(
        context,
        'Reservation booked successfully.',
        const Color(0xFF193147),
      );
    }
  }

  // FUNCTION THAT WILL HANDLE FOR BOOKING APPOINTMENT TO CLIENT
  Future<String> handleAddAppointmentClient(
      String providerAppointmentID) async {
    try {
      String clientAppointmentID = await FirebaseService.addAppointment(
        context: context,
        formKey: formKey,
        clientID: widget.providerID,
        providerID: clientID,
        serviceName: widget.serviceName,
        date: date,
        time: time,
        selectedImage: selectedImage,
        appointmentID: providerAppointmentID,
        referenceNumber: referenceNumber,
      );

      if (clientAppointmentID.isNotEmpty) {
        await updateAppointmentID(providerAppointmentID, clientAppointmentID);
        return clientAppointmentID;
      }
    } catch (e) {
      // Handle any errors that occur during appointment addition
      print("Error adding appointment: $e");
    }
    return '';
  }

  // UPDATE THE APPOINTMENT ID ON THE SERVICE PROVIDER'S SIDE
  Future updateAppointmentID(
      String providerAppointmentID, String clientAppointmentID) async {
    // print(
    //     "APPOINTMENTID: $providerAppointmentID | PROVIDERID: ${widget.providerID} | VALUE ID: $clientAppointmentID");
    await FirebaseService.updateAppointment(
      context: context,
      appointmentID: providerAppointmentID,
      providerID: widget.providerID,
      fieldsToUpdate: {
        'appointmentID': clientAppointmentID,
      },
    );
  }

  // METHOD THAT WILL HANDLE THE IMAGE SELECTION FROM THE LOCAL STORAGE
  void handleImageSelection() async {
    final selected = await ProviderServices.selectImage();
    if (selected != null) {
      setState(() {
        selectedImage = selected;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2025),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary:
                  Color(0xFF193147), // Change the primary color of the dialog
            ),
            dialogBackgroundColor: Colors.white,
            // Change the background color of the dialog
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              dividerColor: Colors.grey,
              elevation: 0,
              surfaceTintColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10), // Change the border radius here
              ),
              headerBackgroundColor: const Color(0xFF193147),
              headerForegroundColor: Colors.white,

              // Add more customization as needed
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        date = _formatDate(selectedDate);
        // print("DATE: $date"); // Output: January 12, 2024
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat("MMMM d, yyyy").format(date);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF64666B),
              ),
              // Change the background color of the dialog
              timePickerTheme: TimePickerThemeData(
                dialBackgroundColor: const Color(0xFFE5E7EB),
                dayPeriodTextColor: const Color(0xFF64666B),
                elevation: 0,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: child!,
          );
        });
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;

        final int startHour = selectedTime.hour;
        final int startMinute = selectedTime.minute;
        final DayPeriod startPeriod = selectedTime.period;

        // Calculate the end time by adding 1 hour to the start time
        int endHour = startHour + 1;
        // Adjust end hour and period if necessary
        DayPeriod endPeriod = startPeriod;
        if (startHour == 12 && startPeriod == DayPeriod.am) {
          endPeriod = DayPeriod.pm;
        } else if (startHour == 11 && startPeriod == DayPeriod.pm) {
          endHour = 12; // Set end hour to 12 for 11 PM
          endPeriod = DayPeriod.am;
        } else if (endHour == 12) {
          endPeriod = startPeriod == DayPeriod.am ? DayPeriod.pm : DayPeriod.am;
        } else if (endHour > 12) {
          endHour -= 12;
          endPeriod = startPeriod == DayPeriod.am ? DayPeriod.pm : DayPeriod.am;
        }

        final String startTime =
            _formatTime(startHour, startMinute, startPeriod);
        final String endTime =
            _formatTime(endHour, selectedTime.minute, endPeriod);
        time = "$startTime - $endTime";

        // print("Start Time: $startTime");
        // print("End Time: $endTime");
        // print("TIME: $time");
      });
    }
  }

  String _formatTime(int hour, int minute, DayPeriod period) {
    String periodString = period == DayPeriod.am ? 'AM' : 'PM';

    // Adjust hourString for 12-hour clock format
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    String hourString = hour.toString();
    String minuteString = minute.toString().padLeft(2, '0');

    return '$hourString:$minuteString $periodString';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnectedToInternet) {
      return const NoInternetScreen();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(AppBar().preferredSize.height),
          child: CustomAppBar(
              backgroundColor: Colors.white,
              titleText: "Book appointment",
              onLeadingPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                // SIZED BOX: SPACING
                const SizedBox(height: 10),

                // SET DATE BUILDER
                _buildSetDate(),

                // SIZED BOX: SPACING
                const SizedBox(height: 17),

                // SEND PAYMENT BUILDER
                _buildSendPayment(),

                // SIZED BOX: SPACING
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SET DATE BUILDER
  Widget _buildSetDate() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15),
      padding: const EdgeInsets.only(left: 12, right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // SIZED BOX: SPACING
          const SizedBox(height: 15),

          ProfileImageWidget(
            width: MediaQuery.of(context).size.width,
            height: 130,
            borderRadius: 5,
            imageURL: widget.imageURL,
          ),

          // SIZED BOX: SPACING
          const SizedBox(height: 10),

          AutoSizeText(
            widget.serviceName,
            style: const TextStyle(
              height: 1.0,
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3C3C40),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // DIVIDER
          const Divider(
            color: Colors.grey,
            thickness: 0.5,
          ),

          // SIZED BOX: SPACING
          const SizedBox(height: 5),

          // SIZED BOX: SPACING
          const SizedBox(height: 12),

          // BUTTON TO SELECT DATE
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                top: 10,
                right: 10,
                bottom: 10,
              ),
              child: Column(
                children: <Widget>[
                  // SELECTED DATE
                  TimeSelectionRow(
                    icon: Icons.calendar_month_outlined,
                    label: "Select date",
                    value: DateFormat('yyyy-MM-dd').format(selectedDate),
                    onPressed: () => _selectDate(context),
                  ),

                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),

                  // SELECTED TIME
                  TimeSelectionRow(
                    icon: Icons.access_time_outlined,
                    label: "Select time",
                    value: selectedTime.format(context),
                    onPressed: () => _selectTime(context),
                  ),
                ],
              ),
            ),
          ),

          // SIZED BOX: SPACING
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // SEND PAYMENT BUILDER
  Widget _buildSendPayment() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15),
      padding: const EdgeInsets.only(left: 12, right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // SIZED BOX: SPACING
          const SizedBox(height: 15),

          // PRICE
          Row(
            children: <Widget>[
              const Text(
                "Payable amount:",
                style: TextStyle(
                  height: 1.0,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3C3C40),
                ),
              ),
              const Spacer(),
              // SERVICE PRICE
              RichText(
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: widget.discount > 0
                          ? "₱ ${NumberFormat("#,##0", "en_PH").format(widget.discountedPrice)}.00"
                          : "₱ ${NumberFormat("#,##0", "en_PH").format(widget.price)}.00",
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
            ],
          ),

          // SIZED BOX: SPACING
          const SizedBox(height: 16),

          // ACCOUNT NAME
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              children: <Widget>[
                const CustomImageDisplay(
                  receivedImageLocation: 'images/gcash_logo.png',
                  receivedPaddingLeft: 5,
                  receivedPaddingRight: 5,
                  receivedPaddingTop: 0,
                  receivedPaddingBottom: 0,
                  receivedImageWidth: 50,
                  receivedImageHeight: 50,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const CustomTextDisplay(
                          receivedText: "GCash name: ",
                          receivedTextSize: 15,
                          receivedTextWeight: FontWeight.w500,
                          receivedLetterSpacing: 0,
                          receivedTextColor: Color(0xFF64666B),
                        ),
                        AutoSizeText(
                          widget.providerInfo?['accountName'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64666B),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        const CustomTextDisplay(
                          receivedText: "GCash number: ",
                          receivedTextSize: 15,
                          receivedTextWeight: FontWeight.w500,
                          receivedLetterSpacing: 0,
                          receivedTextColor: Color(0xFF64666B),
                        ),
                        AutoSizeText(
                          widget.providerInfo?['accountNumber'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64666B),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),

          // SIZED BOX: SPACING
          const SizedBox(height: 12),

          // UPLOAD IMAGE CONTAINER
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFBDBDC7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(
                color: Color(0xFFBDBDC7),
                // Set color for enabled state
                width: 1.5, // Set width for enabled state
              ),
              elevation: 0,
              minimumSize: const Size(double.infinity, 200),
            ),
            onPressed: () {
              handleImageSelection();
            },
            child: selectedImage != null
                ? Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(selectedImage!.path!),
                          // Use the path of the selected image
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 11,
                        top: 10,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImage = null;
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              child: const Icon(
                                Icons.clear_rounded,
                                color: Color(0xFFF5F5F5),
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 3),
                          child: Icon(
                            Icons.upload,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                        SizedBox(
                          child: Text(
                            "Please upload your receipt here",
                            style: TextStyle(
                              height: 0.77,
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        CustomTextDisplay(
                          receivedText: "(Only if you paid via GCash)",
                          receivedTextSize: 10.5,
                          receivedTextWeight: FontWeight.normal,
                          receivedLetterSpacing: 0,
                          receivedTextColor: Colors.grey,
                        ),
                      ],
                    ),
                  ),
          ),

          // SIZED BOX: SPACING
          const SizedBox(height: 15),

          // CONFIRM BUTTON
          PrimaryCustomButton(
            buttonText: "Confirm appointment",
            onPressed: () {
              if (_isOnlineSelected == false) {
                if (selectedImage == null) {
                  setState(() {
                    showFloatingSnackBar(
                      context,
                      "Payment receipt is required",
                      const Color(0xFF64666B),
                    );
                  });
                } else if (date.isEmpty) {
                  setState(() {
                    showFloatingSnackBar(
                      context,
                      "Please set the date to proceed",
                      const Color(0xFF64666B),
                    );
                  });
                } else if (time.isEmpty) {
                  setState(() {
                    showFloatingSnackBar(
                      context,
                      "Please set the time to proceed",
                      const Color(0xFF64666B),
                    );
                  });
                } else {
                  handleAddAppointment();
                }
              } else if (date.isEmpty) {
                setState(() {
                  showFloatingSnackBar(
                    context,
                    "Please set the date to proceed",
                    const Color(0xFF64666B),
                  );
                });
              } else if (time.isEmpty) {
                setState(() {
                  showFloatingSnackBar(
                    context,
                    "Please set the time to proceed",
                    const Color(0xFF64666B),
                  );
                });
              } else {
                handleAddAppointment();
              }
            },
            buttonHeight: 55,
            buttonColor: const Color(0xFF193147),
            fontWeight: FontWeight.w500,
            fontSize: 15,
            fontColor: Colors.white,
            elevation: 0,
            borderRadius: 7,
          ),

          // SIZED BOX: SPACING
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // SERVICE TYPE BUTTON BUILDER

  String generateReferenceNumber() {
    // Logic to generate a reference number (You can customize this as needed)
    String referenceNumber = '${DateTime.now().millisecondsSinceEpoch}';
    return referenceNumber;
  }
}
