import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dormlanders/user_information/pin_location.dart';
import 'package:dormlanders/user_information/account_information.dart';
import 'package:dormlanders/user_information/email_address.dart';
import 'package:dormlanders/user_information/phone_number.dart';
import 'package:dormlanders/services/user_profile_service.dart';
import 'package:dormlanders/utils/custom_modals.dart';
import 'package:dormlanders/utils/custom_show_dialog.dart';
import 'package:dormlanders/utils/navigation_utils.dart';
import 'package:dormlanders/utils/no_internet_screen.dart';
import 'package:dormlanders/widgets/custom_navigation_button.dart';
import 'package:dormlanders/widgets/custom_text_description.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';
import 'package:dormlanders/widgets/custom_user_profile.dart';

class ServiceProviderProfile extends StatefulWidget {
  const ServiceProviderProfile({super.key});

  @override
  State<ServiceProviderProfile> createState() => _ServiceProviderProfileState();
}

class _ServiceProviderProfileState extends State<ServiceProviderProfile> {
  late StreamSubscription<InternetConnectionStatus> _connectionSubscription;
  bool _isConnectedToInternet = true;
  bool isDisconnectedSnackBarVisible = false;
  late Timer _exitTimer;


  // VARIABLE DECLARATIONS
  late Map<String, dynamic> userData = {};
  PlatformFile? selectedImage;
  String? imageURL;
  String? displayName;

  // INITIALIZATION
  @override
  void initState() {
    super.initState();
    _checkConnection();
    _exitTimer = Timer(const Duration(seconds: 15), () {});
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

  // METHOD THAT WILL ADD imageURL FIELD ON EXISTING DOCUMENT IN FIRESTORE
  void updateProfileImage(String downloadURL) async {
    await UserProfileService.updateProfileImage(downloadURL);
    if (mounted) {
      // Use your existing method or Flutter's built-in methods to show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully.")),
      );
    }
  }

  // METHOD FOR SELECTING THE IMAGE
  Future handleFileSelection() async {
    final result = await UserProfileService.selectImage();
    if (result != null) {
      setState(() {
        selectedImage = result.files.first;
      });

      if (mounted) {
        showUploadDialog(
          context: context,
          uploadFile: uploadProfileImage,
          selectedImage: selectedImage,
        );
      }
    }
  }

  // METHOD FOR UPLOADING THE IMAGE TO DATABASE
  Future uploadProfileImage() async {
    final downloadURL =
        await UserProfileService.uploadFile(selectedImage, imageURL);

    if (downloadURL != null) {
      setState(() {
        imageURL = downloadURL;
      });
      updateProfileImage(downloadURL);
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
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        // BODY OF ACCOUNT INFORMATION PAGE
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30),
              StreamBuilder<Map<String, dynamic>>(
                stream: UserProfileService().getUserDataStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }

                  // EXTRACT DATA FROM SNAPSHOT
                  userData = snapshot.data ?? {};
                  displayName = userData['displayName'] ?? 'No Name';
                  imageURL = userData['imageURL'];

                  return Column(
                    children: <Widget>[
                      CustomUpdateUserProfile(
                        imageURL: imageURL,
                        selectedImage: selectedImage,
                        imageWidth: 140,
                        imageHeight: 140,
                        onPressed: () {
                          handleFileSelection();
                        },
                      ),

                      // USER DISPLAY NAME
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(
                            top: 15,
                            left: 20,
                            right: 20,
                          ),
                          child: AutoSizeText(
                            displayName ?? 'No Name',
                            style: const TextStyle(
                              color: Color(0xFF3C3C40),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // SIZED BOX: SPACING
              const SizedBox(height: 60),

              // ACCOUNT INFORMATION TEXTS
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin:
                      const EdgeInsets.only(left: 25, right: 20, bottom: 10),
                  child: const CustomTextDisplay(
                    receivedText: "User information",
                    receivedTextSize: 15,
                    receivedTextWeight: FontWeight.w500,
                    receivedLetterSpacing: 0,
                    receivedTextColor: Color(0xFF8C8C8C),
                  ),
                ),
              ),

              // ACCOUNT INFORMATION
              CustomNavigationButton(
                textButton: "Personal information",
                textColor: const Color(0xFF3C3C40),
                onPressed: () {
                  navigateWithSlideFromRight(
                    context,
                    const UserAccountInformation(
                      text: "Your data, like first name, and last name"
                          "will be used to improve client discovery and more. ",
                    ),
                    1.0,
                    0.0,
                  );
                },
              ),

              // PHONE NUMBER
              CustomNavigationButton(
                textButton: "Phone number",
                textColor: const Color(0xFF3C3C40),
                onPressed: () {
                  navigateWithSlideFromRight(
                    context,
                    const UserPhoneNumber(
                      text: "Your phone number may be used to help"
                          "clients connect with you, improve ads, and more",
                    ),
                    1.0,
                    0.0,
                  );
                },
              ),

              // EMAIL ADDRESS
              CustomNavigationButton(
                textButton: "Email address",
                textColor: const Color(0xFF3C3C40),
                onPressed: () {
                  navigateWithSlideFromRight(
                    context,
                    const UserEmailAddress(
                      text:
                      "Your email address may be used to help clients "
                          "connect with you improve ads, and more. ",
                    ),
                    1.0,
                    0.0,
                  );
                },
              ),

              // LONG DESCRIPTIONS
              const CustomTextDescription(
                descriptionText:
                    "Your data will be saved and display for client "
                    "discovery purposes. Your data like name, email, phone number, "
                    "and address may be also be used to connect you to clients "
                    "that might looking for your services.",
                hasLearnMore: " Learn more",
              ),

              // SIZED BOX: SPACING
              const SizedBox(height: 10),

              // PIN EXACT LOCATION OR ADDRESS
              CustomNavigationButton(
                textButton: "Pin your exact location",
                textColor: const Color(0xFF3C3C40),
                onPressed: () {
                  navigateWithSlideFromRight(
                    context,
                    const PinLocation(),
                    1.0,
                    0.0,
                  );
                },
              ),

              // SHORT DESCRIPTIONS
              const CustomTextDescription(
                descriptionText:
                    "Pin point your location: Help us direct clients "
                    "straight to you by sharing your precise position.",
                hasLearnMore: "",
              ),

              // SIZED BOX: SPACING
              const SizedBox(height: 10),

              // LOG OUT BUTTON
              CustomNavigationButton(
                textButton: "Sign out",
                textColor: const Color(0xFFe91b4f),
                onPressed: () {
                  showLogoutModal(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
