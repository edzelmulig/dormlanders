import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dormlanders/user_information/pin_location.dart';
import 'package:dormlanders/utils/custom_loading.dart';
import 'package:dormlanders/utils/custom_modals.dart';
import 'package:dormlanders/utils/custom_snackbar.dart';
import 'package:dormlanders/utils/no_internet_screen.dart';
import 'package:dormlanders/widgets/complete_address_display.dart';
import 'package:dormlanders/widgets/custom_app_bar.dart';
import 'package:dormlanders/widgets/custom_button.dart';
import 'package:dormlanders/widgets/custom_modal_confirmation.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';
import 'package:dormlanders/widgets/custom_text_field.dart';

class ConfirmLocation extends StatefulWidget {
  final Map<String, dynamic> placeDetails;
  final double? latitudeValue;
  final double? longitudeValue;
  final String additionalInstructions;

  const ConfirmLocation({
    super.key,
    required this.placeDetails,
    required this.latitudeValue,
    required this.longitudeValue,
    required this.additionalInstructions,
  });

  @override
  State<ConfirmLocation> createState() => _ConfirmLocationState();
}

class _ConfirmLocationState extends State<ConfirmLocation> {
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;


  // CONTROLLERS
  final _streetController = TextEditingController();
  final _barangayController = TextEditingController();
  final _instructionsController = TextEditingController();

  // FORM KEY
  final _formKey = GlobalKey<FormState>();
  final _barangayFocusNode = FocusNode();
  final _instructionFocusNode = FocusNode();

  bool isLoading = false;

  // SAVE THE LOCATION IN FIRESTORE
  Future _pinLocation() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }

        // Show loading dialog
        showLoadingIndicator(context);

        final userCredential = FirebaseAuth.instance.currentUser;
        if (userCredential != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.uid)
              .collection('personal_information')
              .doc('location')
              .set({
            'placeDetails': widget.placeDetails,
            'additionalInstructions': _instructionsController.text,
            'latitude': widget.latitudeValue,
            'longitude': widget.longitudeValue,
          });

          // IF ADDING SERVICE SUCCESSFUL
          if (context.mounted) {
            // Dismiss loading dialog
            Navigator.of(context).pop();

            showFloatingSnackBar(
              context,
              "Location saved successfully.",
              const Color(0xFF279778),
            );
            // NAVIGATE TO PROFILE SCREEN
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        if (context.mounted) {
          showFloatingSnackBar(
            context,
            "User not signed in",
            const Color(0xFFe91b4f),
          );
          // Dismiss loading dialog
          if (context.mounted) Navigator.of(context).pop();
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  Future deleteService(String docId) async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      // Show loading dialog
      showLoadingIndicator(context);

      // Ensure you have a reference to FirebaseAuth to get the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('personal_information')
            .doc('location')
            .delete()
            .then(
          (_) {
            // IF DELETION IS SUCCESSFUL

            if (context.mounted) {
              // Dismiss loading dialog
              if (context.mounted) {
                Navigator.of(context).pop();
              }

              showFloatingSnackBar(
                context,
                "Location deleted successfully.",
                const Color(0xFF279778),
              );
              // NAVIGATE TO PROFILE SCREEN
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "User not signed in",
          const Color(0xFFe91b4f),
        );
        // Dismiss loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _exitTimer = Timer(const Duration(seconds: 15), () {});
    _streetController.text = widget.placeDetails['street'] ?? 'N/A';
    _barangayController.text = widget.placeDetails['barangay'] ?? 'N/A';
    _instructionsController.text = widget.additionalInstructions;
    _streetController.addListener(_onStreetChanged);
    _barangayController.addListener(_onStreetChanged);
    _instructionsController.addListener(_enforceWordLimit);
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    _exitTimer.cancel();
    _streetController.dispose();
    _barangayController.dispose();
    _instructionsController.dispose();
    _streetController.removeListener(_onStreetChanged);
    _barangayController.removeListener(_onStreetChanged);
    _instructionsController.removeListener(_enforceWordLimit);
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


  void _onStreetChanged() {
    // Update the placeDetails map and refresh the UI
    setState(() {
      widget.placeDetails['street'] = _streetController.text;
      widget.placeDetails['barangay'] = _barangayController.text;
    });
  }

  void _enforceWordLimit() {
    String text = _instructionsController.text;
    int wordCount = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;

    // Define the maximum allowed word count
    int maxWordCount = 30; // Change this value to your desired maximum

    if (wordCount > maxWordCount) {
      // Truncate the text to the maximum word count
      List<String> words =
      text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
      String newText =
          '${words.take(maxWordCount).join(' ')} '; // Add a space at the end for better UX
      _instructionsController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
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
        showConfirmationModal(
          context,
          'You are about to discard this update.',
          'Discard',
          const PinLocation(),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(AppBar().preferredSize.height),
          child: CustomAppBar(
            backgroundColor: Colors.white,
            titleText: "",
            onLeadingPressed: () => showConfirmationModal(
              context,
              'You are about to discard this update.',
              'Discard',
              const PinLocation(),
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // CONFIRM LOCATION
                    Container(
                      margin: const EdgeInsets.only(
                        top: 10,
                        bottom: 5,
                      ),
                      child: const CustomTextDisplay(
                        receivedText: "Pin location",
                        receivedTextSize: 20,
                        receivedTextWeight: FontWeight.w700,
                        receivedLetterSpacing: 0,
                        receivedTextColor: Color(0xFF3C3C40),
                      ),
                    ),

                    // NOTICE
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 30,
                      ),
                      child: RichText(
                        text: const TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  "Your location may be used to help clients find you,"
                                  " accurately, improve ads, and more. ",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF8C8C8C),
                              ),
                            ),
                            TextSpan(
                              text: "Learn more",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8C8C8C),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // LABEL COMPLETE ADDRESS
                    const CustomTextDisplay(
                      receivedText: "Complete address",
                      receivedTextSize: 15,
                      receivedTextWeight: FontWeight.w500,
                      receivedLetterSpacing: 0,
                      receivedTextColor: Color(0xFF242424),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    // COMPLETE ADDRESS DISPLAY
                    CompleteAddressDisplay(
                      placeDetails: {
                        'street': widget.placeDetails['street'],
                        'barangay': widget.placeDetails['barangay'],
                        'city': widget.placeDetails['city'],
                        'province': widget.placeDetails['province'],
                        'region': widget.placeDetails['region'],
                      },
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(
                      height: 10,
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // LABEL: STREET
                        const CustomTextDisplay(
                          receivedText: "Street",
                          receivedTextSize: 15,
                          receivedTextWeight: FontWeight.w500,
                          receivedLetterSpacing: 0,
                          receivedTextColor: Color(0xFF242424),
                        ),

                        // SIZED BOX: SPACING
                        const SizedBox(
                          height: 2,
                        ),

                        // TEXT FIELD: STREET
                        CustomTextField(
                          controller: _streetController,
                          currentFocusNode: null,
                          nextFocusNode: _barangayFocusNode,
                          validatorText: "Street name is required",
                          keyBoardType: null,
                          inputFormatters: null,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Street is required";
                            }
                            setState(() {
                              widget.placeDetails['street'] =
                                  _streetController.text;
                            });
                            return null;
                          },
                          hintText: "Enter street name",
                          minLines: 1,
                          maxLines: 1,
                          isPassword: false,
                        ),

                        // SIZED BOX: SPACING
                        const SizedBox(
                          height: 10,
                        ),

                        // LABEL: BARANGAY
                        const CustomTextDisplay(
                          receivedText: "Barangay",
                          receivedTextSize: 15,
                          receivedTextWeight: FontWeight.w500,
                          receivedLetterSpacing: 0,
                          receivedTextColor: Color(0xFF242424),
                        ),

                        // SIZED BOX: SPACING
                        const SizedBox(
                          height: 2,
                        ),

                        // TEXT FIELD: BARANGAY
                        CustomTextField(
                          controller: _barangayController,
                          currentFocusNode: _barangayFocusNode,
                          nextFocusNode: null,
                          keyBoardType: null,
                          inputFormatters: null,
                          validatorText: "Barangay is required",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Barangay is required";
                            }
                            return null;
                          },
                          hintText: "Enter barangay name",
                          minLines: 1,
                          maxLines: 1,
                          isPassword: false,
                        ),

                        // SIZED BOX: SPACING
                        const SizedBox(
                          height: 10,
                        ),

                        // DIVIDER: SEPARATION
                        const Divider(
                          thickness: 1.0,
                          color: Color(0xFFBDBDC7),
                        ),

                        // SIZED BIX: SPACING
                        const SizedBox(
                          height: 5,
                        ),

                        // LABEL: ADDITIONAL INSTRUCTIONS
                        const CustomTextDisplay(
                          receivedText: "Additional information",
                          receivedTextSize: 15,
                          receivedTextWeight: FontWeight.w500,
                          receivedLetterSpacing: 0,
                          receivedTextColor: Color(0xFF242424),
                        ),

                        // SUB LABEL: ADDITIONAL SUB INSTRUCTION
                        const CustomTextDisplay(
                          receivedText:
                              "Give us more information about your address.",
                          receivedTextSize: 15,
                          receivedTextWeight: FontWeight.w400,
                          receivedLetterSpacing: 0,
                          receivedTextColor: Color(0xFF8C8C8C),
                        ),

                        // SIZED BOX: SPACING
                        const SizedBox(
                          height: 10,
                        ),

                        // TEXT FIELD: ADDITIONAL INFORMATION
                        CustomTextField(
                          controller: _instructionsController,
                          currentFocusNode: _instructionFocusNode,
                          nextFocusNode: null,
                          keyBoardType: TextInputType.multiline,
                          inputFormatters: null,
                          validatorText: "Additional information is required",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Additional information is required";
                            }
                            int wordCount = value
                                .trim()
                                .split(RegExp(r'\s+'))
                                .where((word) => word.isNotEmpty)
                                .length;

                            // DEFINE MAXIMUM ALLOWED WORDS
                            int maxWordCount = 30;

                            if (wordCount > maxWordCount) {
                              // Truncate the input text to the maximum word count
                              List<String> words =
                              value.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
                              String truncatedText =
                                  '${words.take(maxWordCount).join(' ')} '; // Add a space at the end for better UX
                              _instructionsController.text = truncatedText;
                              return "Description must be less than $maxWordCount words";
                            }
                            return null;
                          },
                          hintText: "Note to client - e.g. landmark",
                          minLines: 1,
                          maxLines: 5,
                          isPassword: false,
                        ),

                        // SIZED BOX: SPACING
                        const SizedBox(
                          height: 20,
                        ),

                        // BUTTON: SAVE PHONE NUMBER
                        PrimaryCustomButton(
                          buttonText: "Save",
                          onPressed: _pinLocation,
                          buttonHeight: 55,
                          buttonColor: const Color(0xFF279778),
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          fontColor: Colors.white,
                          elevation: 1,
                          borderRadius: 10,
                        ),

                        // SIZED BOX: SPACING
                        const SizedBox(
                          height: 60,
                        ),

                        // TEXT: DELETE LOCATION
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: () async {
                              showDeleteWarning(
                                context,
                                'Are you sure you want to delete your location?',
                                'Delete',
                                deleteService,
                                "location",
                              );
                            },
                            child: const CustomTextDisplay(
                              receivedText: "Delete location",
                              receivedTextSize: 16,
                              receivedTextWeight: FontWeight.w500,
                              receivedLetterSpacing: 0,
                              receivedTextColor: Color(0xFFe91b4f),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
