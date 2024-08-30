import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dormlanders/service_providers/service_provider_profile.dart';
import 'package:dormlanders/services/user_profile_service.dart';
import 'package:dormlanders/utils/custom_snackbar.dart';
import 'package:dormlanders/utils/no_internet_screen.dart';
import 'package:dormlanders/widgets/custom_app_bar.dart';
import 'package:dormlanders/widgets/custom_button.dart';
import 'package:dormlanders/widgets/custom_loading_indicator.dart';
import 'package:dormlanders/widgets/custom_modal_confirmation.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';
import 'package:dormlanders/widgets/custom_text_field.dart';

class UserAccountInformation extends StatefulWidget {
  final String text;

  const UserAccountInformation({
    super.key,
    required this.text,
  });

  @override
  State<UserAccountInformation> createState() => _UserAccountInformation();
}

class _UserAccountInformation extends State<UserAccountInformation> {
  final String? userID = FirebaseAuth.instance.currentUser!.uid;
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;

  // TEXT EDITING CONTROLLER DECLARATION
  late TextEditingController _displayNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _accountNameController;
  late TextEditingController _accountNumberController;

  // FORM KEY DECLARATION
  final formKey = GlobalKey<FormState>();

  // FOCUS NODE DECLARATION
  final _displayNameFocusNode = FocusNode();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _accountNameFocusNode = FocusNode();
  final _accountNumberFocusNode = FocusNode();

  // INITIALIZATION
  @override
  void initState() {
    super.initState();
    _checkConnection();
    _exitTimer = Timer(const Duration(seconds: 15), () {});
    _getUserData();
    _displayNameController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _accountNameController = TextEditingController();
    _accountNumberController = TextEditingController();
  }

  // DISPOSE
  @override
  void dispose() {
    _connectionSubscription.cancel();
    _exitTimer.cancel();
    _displayNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _accountNameFocusNode.dispose();
    _accountNumberFocusNode.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _connectionSubscription.cancel();
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

  // METHOD THAT WILL GET THE USER DATA
  Future _getUserData() async {
    final data = await UserProfileService()
        .getUserData(userID!, 'personal_information', 'info');
    if (mounted) {
      setState(() {
        // ASSIGN THE INITIAL VALUE TO THE CONTROLLERS
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _displayNameController.text = data['displayName'] ?? '';
        _accountNameController.text = data['accountName'] ?? '';
        _accountNumberController.text = data['accountNumber'] ?? '';
      });
    }
  }

  // ENCAPSULATES THE CLOSING KEYBOARD AND CALLING SUBMISSION HELPER
  void handleSubmit() {
    // CLOSE THE KEYBOARD
    FocusScope.of(context).unfocus();

    // CALL THE  _submitForm METHOD
    UserProfileService.updateProfileData(
      context,
      formKey,
      displayNameController: _displayNameController,
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      accountNameController: _accountNameController,
      accountNumberController: _accountNumberController,
    );
    Navigator.pop(context);
    showFloatingSnackBar(
      context,
      'Data updated successfully.',
      const Color(0xFF193147),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(!_isConnectedToInternet) {
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
          const ServiceProviderProfile(),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(AppBar().preferredSize.height),
          child: CustomAppBar(
            backgroundColor: Colors.white,
            titleText: "Account information",
            onLeadingPressed: () => showConfirmationModal(
              context,
              'You are about to discard this update.',
              'Discard',
              const ServiceProviderProfile(),
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            // FORM
            Form(
              key: formKey,
              child: FutureBuilder(
                future: UserProfileService().getUserData(
                    userID!, 'personal_information', 'info'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // DISPLAY CUSTOM LOADING INDICATOR
                    return const CustomLoadingIndicator();
                  } else if (snapshot.hasError) {
                    // HANDLE ERROR IF FETCHING DATA FAILS
                    return Center(
                        child: Text('Error: ${snapshot.hasError.toString()}'));
                  } else {
                    // DISPLAY USER DATA ONCE FETCHED
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // SCREEN TITLE
                          Container(
                            margin: const EdgeInsets.only(
                              top: 10,
                              bottom: 5,
                            ),
                            child: const CustomTextDisplay(
                              receivedText: "Personal information",
                              receivedTextSize: 20,
                              receivedTextWeight: FontWeight.w700,
                              receivedLetterSpacing: 0,
                              receivedTextColor: Color(0xFF3C3C40),
                            ),
                          ),

                          // DESCRIPTION
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 25,
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "${widget.text} ",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF8C8C8C),
                                    ),
                                  ),
                                  const TextSpan(
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

                          // ACCOUNT INFORMATION
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // LABEL: DISPLAY NAME
                              const CustomTextDisplay(
                                receivedText: "Display Name",
                                receivedTextSize: 15,
                                receivedTextWeight: FontWeight.w500,
                                receivedLetterSpacing: 0,
                                receivedTextColor: Color(0xFF242424),
                              ),

                              // SIZED BOX: SPACING
                              const SizedBox(height: 2),

                              // TEXT FIELD: DISPLAY NAME
                              CustomTextField(
                                controller: _displayNameController,
                                currentFocusNode: _displayNameFocusNode,
                                nextFocusNode: _firstNameFocusNode,
                                keyBoardType: null,
                                inputFormatters: null,
                                validatorText: "Display name is required",
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Display name is required";
                                  }
                                  return null;
                                },
                                hintText: "Enter display name",
                                minLines: 1,
                                maxLines: 1,
                                isPassword: false,
                              ),

                              // SIZED BOX: SPACING
                              const SizedBox(height: 10),

                              // LABEL: FIRST NAME
                              const CustomTextDisplay(
                                receivedText: "First Name",
                                receivedTextSize: 15,
                                receivedTextWeight: FontWeight.w500,
                                receivedLetterSpacing: 0,
                                receivedTextColor: Color(0xFF242424),
                              ),

                              // SIZED BOX: SPACING
                              const SizedBox(height: 2),

                              // TEXT FIELD: FIRST NAME
                              CustomTextField(
                                controller: _firstNameController,
                                currentFocusNode: _firstNameFocusNode,
                                nextFocusNode: _lastNameFocusNode,
                                keyBoardType: null,
                                inputFormatters: null,
                                validatorText: "First name is required",
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "First name is required";
                                  }
                                  return null;
                                },
                                hintText: "Enter your first name",
                                minLines: 1,
                                maxLines: 1,
                                isPassword: false,
                              ),

                              // SIZED BOX: SPACING
                              const SizedBox(height: 10),

                              // LABEL: LAST NAME
                              const CustomTextDisplay(
                                receivedText: "Last Name",
                                receivedTextSize: 15,
                                receivedTextWeight: FontWeight.w500,
                                receivedLetterSpacing: 0,
                                receivedTextColor: Color(0xFF242424),
                              ),

                              // SIZED BOX: SPACING
                              const SizedBox(height: 2),

                              // TEXT FIELD: LAST NAME
                              CustomTextField(
                                controller: _lastNameController,
                                currentFocusNode: _lastNameFocusNode,
                                nextFocusNode: null,
                                keyBoardType: null,
                                inputFormatters: null,
                                validatorText: "Last name is required",
                                validator: (value) {
                                  if (value!.isEmpty && value == '') {
                                    return "Last name is required";
                                  }
                                  return null;
                                },
                                hintText: "Enter your last name",
                                minLines: 1,
                                maxLines: 1,
                                isPassword: false,
                              ),
                            ],
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // LABEL: ACCOUNT NAME
                          const CustomTextDisplay(
                            receivedText: "GCash account name",
                            receivedTextSize: 15,
                            receivedTextWeight: FontWeight.w500,
                            receivedLetterSpacing: 0,
                            receivedTextColor: Color(0xFF242424),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 2),

                          // TEXT FIELD: GCASH ACCOUNT NAME
                          CustomTextField(
                            controller: _accountNameController,
                            currentFocusNode: _accountNameFocusNode,
                            nextFocusNode: _accountNumberFocusNode,
                            keyBoardType: null,
                            inputFormatters: null,
                            validatorText: "GCash account name is required",
                            validator: (value) {
                              if (value!.isEmpty && value == '') {
                                return "GCash account name is required";
                              }
                              return null;
                            },
                            hintText: "e.g Juan Dela Cruz",
                            minLines: 1,
                            maxLines: 1,
                            isPassword: false,
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 10),

                          // LABEL: ACCOUNT NAME
                          const CustomTextDisplay(
                            receivedText: "GCash account number",
                            receivedTextSize: 15,
                            receivedTextWeight: FontWeight.w500,
                            receivedLetterSpacing: 0,
                            receivedTextColor: Color(0xFF242424),
                          ),

                          // SIZED BOX: SPACING
                          const SizedBox(height: 2),

                          // TEXT FIELD: GCASH ACCOUNT NUMBER
                          CustomTextField(
                            controller: _accountNumberController,
                            currentFocusNode: _accountNumberFocusNode,
                            nextFocusNode: null,
                            keyBoardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[0-9]+$')),
                            ],
                            validatorText: "GCash account number is required",
                            validator: (value) {
                              if (value!.isEmpty && value == '') {
                                return "GCash account number is required";
                              }
                              return null;
                            },
                            hintText: "e.g 09123456789",
                            minLines: 1,
                            maxLines: 1,
                            isPassword: false,
                          ),


                          // SIZED BOX: SPACING
                          const SizedBox(height: 20),

                          // BUTTON: SAVE INFORMATION
                          PrimaryCustomButton(
                            buttonText: "Save",
                            onPressed: () {
                              if (_displayNameController.text.isEmpty ||
                                  _firstNameController.text.isEmpty ||
                                  _lastNameController.text.isEmpty ||
                                  _accountNameController.text.isEmpty ||
                                  _accountNumberController.text.isEmpty ) {
                                showFloatingSnackBar(
                                  context,
                                  'Personal information is required.',
                                  const Color(0xFFe91b4f),
                                );
                              } else {
                                handleSubmit();
                              }
                            },
                            buttonHeight: 55,
                            buttonColor: const Color(0xFF193147),
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            fontColor: Colors.white,
                            elevation: 1,
                            borderRadius: 10,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
