import 'package:flutter/material.dart';
import 'package:dormlanders/client/client_sign_up.dart';
import 'package:dormlanders/service_providers/service_provider_sign_up.dart';
import 'package:dormlanders/utils/navigation_utils.dart';
import 'package:dormlanders/widgets/custom_button.dart';
import 'package:dormlanders/widgets/custom_image_display.dart';
import 'package:dormlanders/widgets/custom_role_selection_button.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class SelectRole extends StatefulWidget {
  const SelectRole({super.key});

  @override
  State<SelectRole> createState() => _SelectRoleState();
}

class _SelectRoleState extends State<SelectRole> {
  bool isClientSelected = true;
  bool isProviderSelected = false;
  String selectedRole = 'Client';
  bool privacyAccepted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPrivacyDialog(context);
    });
  }

  @override
  void dispose() {
    // Clear the values of the variables when the screen is disposed
    isClientSelected = true;
    isProviderSelected = false;
    selectedRole = 'Client';
    privacyAccepted = false;
    super.dispose();
  }

  // FUNCTION THAT WILL UPDATE THE VALUE OF TERMS OF USE
  updateSelected(bool value) {
    if (value != privacyAccepted) {
      // Only update if the value actually changes
      setState(() {
        privacyAccepted = value;
        debugPrint("VALUE: ${privacyAccepted}");
      });
    }
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false, // User must tap button!
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: EdgeInsets.all(20.0),
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Privacy and Security Notice',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Data Privacy Statement",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Welcome to MentalBoost! We are committed to protecting your privacy and ensuring the security of your personal data. Before you complete your sign-up process, please read and understand how we handle the data you provide us.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Collection of Data:",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "MentalBoost collects personal data such as your name, email address, and other relevant information necessary for the creation and maintenance of your account. We may also collect data related to your usage of our services to enhance your experience.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Use of Data:",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "The data you provide to MentalBoost will be used for the following purposes:",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      "• To create and manage your user account;",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      "• To personalize and enhance your experience within the application;",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      "• To communicate important notices, such as changes to our terms, conditions, and policies;",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      "• To provide customer support and respond to your requests and inquiries;",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      "• To conduct research and analysis to improve the functionality and services offered by MentalBoost.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Data Protection:",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "We implement a variety of security measures to maintain the safety of your personal information. Access to your personal data is restricted to authorized MentalBoost personnel only and is subject to confidentiality obligations.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Compliance:",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "All data handling practices are designed to comply with the 'Data Privacy Act of 2012' and other applicable laws and regulations concerning data privacy and protection.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Consent:",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "By clicking 'Agree' and proceeding with the sign-up process, you consent to the collection, use, and disclosure of your personal information as described in this Data Privacy Statement.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // CHECK BOX
                    PrimaryCustomButton(
                      buttonText: "Agree",
                      onPressed:
                          () {
                        setState(() {
                          updateSelected(true);
                          Navigator.pop(context);
                        });
                      },
                      buttonHeight: 55,
                      buttonColor: const Color(0xFF279778),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: Colors.white,
                      elevation: 0,
                      borderRadius: 10,
                    ),
                    const SizedBox(height: 5),
                    // CHECK BOX
                    PrimaryCustomButton(
                      buttonText: "Decline",
                      onPressed:
                          () {
                        setState(() {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        });
                      },
                      buttonHeight: 55,
                      buttonColor: const Color(0xFFe91b4f),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: Colors.white,
                      elevation: 0,
                      borderRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
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
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F5F5),
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 5),
                child: const CustomImageDisplay(
                  receivedImageLocation: "images/mentalboost_logo_no_bg.png",
                  receivedPaddingLeft: 0,
                  receivedPaddingRight: 0,
                  receivedPaddingTop: 0,
                  receivedPaddingBottom: 0,
                  receivedImageWidth: 35,
                  receivedImageHeight: 35,
                ),
              ),
              RichText(
                text: const TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "Mental",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3C3C40),
                      ),
                    ),
                    TextSpan(
                      text: "Boost",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3C3C40),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: ListView(
          children: <Widget>[
            //1. Select account type text
            Container(
              margin: const EdgeInsets.only(top: 30, bottom: 15),
              alignment: Alignment.center,
              child: const CustomTextDisplay(
                receivedText: "Select account type",
                receivedTextSize: 30,
                receivedTextWeight: FontWeight.w800,
                receivedLetterSpacing: 0,
                receivedTextColor: Color(0xFF3C3C40),
              ),
            ),

            // BUTTON FOR CLIENT
            CustomRoleSelectionButton(
              isSelected: isClientSelected,
              role: "Client",
              firstText: "I'm a client, seeking mental",
              secondText: "health support.",
              icon: Icons.person,
              onPressed: () {
                setState(() {
                  isClientSelected = true;
                  isProviderSelected = false;
                  selectedRole = "Client";
                });
              },
            ),

            // SIZED BOX: SPACING
            const SizedBox(height: 15),

            // BUTTON FOR MENTAL HEALTH SERVICE PROVIDER
            CustomRoleSelectionButton(
              isSelected: isProviderSelected,
              role: "Provider",
              firstText: "I'm a mental health service",
              secondText: "provider.",
              icon: Icons.person_pin_rounded,
              onPressed: () {
                setState(() {
                  isClientSelected = false;
                  isProviderSelected = true;
                  selectedRole = "Provider";
                });
              },
            ),

            // SIZED BOX: SPACING
            const SizedBox(height: 20),

            // JOIN BUTTON
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: PrimaryCustomButton(
                buttonText: "Join as $selectedRole",
                onPressed: () {
                  // NAVIGATE TO DESIRED SIGN UP PAGE
                  if (selectedRole == 'Client' && privacyAccepted == true) {
                    navigateWithSlideFromRight(
                      context,
                      ClientSignUp(userType: selectedRole),
                      1.0,
                      0.0,
                    );
                  } else if (selectedRole != 'Client' &&
                      privacyAccepted == true) {
                    navigateWithSlideFromRight(
                      context,
                      ServiceProviderSignUp(userType: selectedRole),
                      1.0,
                      0.0,
                    );
                  } else if(privacyAccepted == false) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showPrivacyDialog(context);
                    });
                  }
                },
                buttonHeight: 55,
                buttonColor: const Color(0xFF279778),
                fontWeight: FontWeight.w500,
                fontSize: 17,
                fontColor: Colors.white,
                elevation: 1,
                borderRadius: 10,
              ),
            ),

            Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CustomTextDisplay(
                    receivedText: "Already have an account?",
                    receivedTextSize: 15,
                    receivedTextWeight: FontWeight.normal,
                    receivedLetterSpacing: 0,
                    receivedTextColor: Color(0xFF6c7687),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF279778),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
