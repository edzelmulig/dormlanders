import 'package:flutter/material.dart';
import 'package:dormlanders/auth/select_role.dart';
import 'package:dormlanders/auth/forgot_password_page.dart';
import 'package:dormlanders/services/auth_service.dart';
import 'package:dormlanders/services/shared_preferences.dart';
import 'package:dormlanders/utils/custom_snackbar.dart';
import 'package:dormlanders/widgets/custom_button.dart';
import 'package:dormlanders/widgets/custom_image_display.dart';
import 'package:dormlanders/widgets/custom_social_media_button.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // TextEditingController declarations
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Boolean variables
  bool isVisible = false;
  bool _isChecked = false;

  // Error message
  String? errorMessage;

  // INITIALIZATION
  @override
  void initState() {
    super.initState();
    loadCredentials();
  }

  // DISPOSE
  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  // LOAD ACCOUNT STORED IN SHARED PREFERENCES
  void loadCredentials() async {
    Map<String, String> credentials =
        await PreferenceService.retrieveSavedCredentials();

    if (!mounted) return;

    _loginEmailController.text = credentials['email'] ?? "";
    _loginPasswordController.text = credentials['password'] ?? "";

    setState(() {
      _isChecked = _loginEmailController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final logoMargin = screenHeight * 0.1; //

    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        Navigator.of(context).pop;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // MENTALBOOST LOGO
              Container(
                margin: EdgeInsets.only(top: logoMargin, bottom: 10),
                child: const CustomImageDisplay(
                  receivedImageLocation: "images/mentalboost_logo_no_bg.png",
                  receivedPaddingLeft: 0,
                  receivedPaddingRight: 0,
                  receivedPaddingTop: 0,
                  receivedPaddingBottom: 0,
                  receivedImageWidth: 200,
                  receivedImageHeight: 200,
                ),
              ),

              // MENTALBOOST TEXT
              const Align(
                alignment: Alignment.center,
                child: CustomTextDisplay(
                  receivedText: "MentalBoost",
                  receivedTextSize: 35,
                  receivedTextWeight: FontWeight.w800,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Color(0xFF3C3C40),
                ),
              ),

              // MENTALBOOST TEXT
              const Align(
                alignment: Alignment.center,
                child: CustomTextDisplay(
                  receivedText:
                      "Connecting Minds, Empowering Lives: MentalBoost",
                  receivedTextSize: 14.5,
                  receivedTextWeight: FontWeight.w600,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Color(0xFF3C3C40),
                ),
              ),

              // Sign In TEXT
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(left: 25, top: 30, bottom: 5),
                child: const CustomTextDisplay(
                  receivedText: "Sign In",
                  receivedTextSize: 25.0,
                  receivedTextWeight: FontWeight.w500,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Color(0xFF279778),
                ),
              ),

              Form(
                // Trigger validation along with the changes in the text field
                autovalidateMode: AutovalidateMode.disabled,
                key: formKey,
                child: Column(
                  children: <Widget>[
                    // EMAIL TEXT FIELD
                    Container(
                      margin: const EdgeInsets.only(left: 25, right: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // TEXT FIELD FIRST NAME
                          TextFormField(
                            cursorColor: const Color(0xFF6c7687),
                            controller: _loginEmailController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Email is required";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              fillColor:
                                  const Color(0xFF279778).withOpacity(.2),
                              filled: true,
                              prefixIcon: Container(
                                margin: const EdgeInsets.only(left: 5),
                                child: const Icon(
                                  Icons.email_rounded,
                                  color: Color(0xFF279778),
                                ),
                              ),
                              hintText: "Enter your email",
                              hintStyle: const TextStyle(
                                color: Color(0xFF279778),
                                fontWeight: FontWeight.normal,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFF279778),
                                  width: 1.5,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFe91b4f),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFe91b4f),
                                  width: 2.0,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 17.0,
                              ),
                            ),
                            onEditingComplete: () {
                              FocusScope.of(context).nextFocus();
                            },
                          ),
                        ],
                      ),
                    ),

                    // PASSWORD TEXT FIELD
                    Container(
                      margin:
                          const EdgeInsets.only(left: 25, right: 25, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // TEXT FIELD PASSWORD NAME
                          TextFormField(
                            cursorColor: const Color(0xFF6c7687),
                            controller: _loginPasswordController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Password is required";
                              }
                              return null;
                            },
                            obscureText: !isVisible,
                            decoration: InputDecoration(
                              fillColor:
                                  const Color(0xFF279778).withOpacity(.2),
                              filled: true,
                              prefixIcon: Container(
                                margin: const EdgeInsets.only(left: 5),
                                child: const Icon(
                                  Icons.lock,
                                  color: Color(0xFF279778),
                                ),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  //In here we will create a click to show and hide the password a toggle button
                                  setState(() {
                                    //toggle button
                                    isVisible = !isVisible;
                                  });
                                },
                                icon: Container(
                                  margin: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Icon(
                                    isVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xFF279778),
                                  ),
                                ),
                              ),
                              hintText: "Enter your password",
                              hintStyle: const TextStyle(
                                color: Color(0xFF279778),
                                fontWeight: FontWeight.normal,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFF279778),
                                  width: 1.5,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFe91b4f),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFe91b4f),
                                  width: 2.0,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 17.0,
                              ),
                            ),
                            onEditingComplete: () {
                              FocusScope.of(context).nextFocus();
                            },
                          ),
                        ],
                      ),
                    ),

                    // Remember me checkbox
                    Container(
                      padding: const EdgeInsets.only(left: 15.0, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Theme(
                            data: ThemeData(
                              checkboxTheme: CheckboxThemeData(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                            ),
                            child: Checkbox(
                              value: _isChecked,
                              onChanged: (newValue) {
                                if (mounted) {
                                  setState(() {
                                    _isChecked = newValue!;
                                    if (!_isChecked) {
                                      PreferenceService.saveCredentials('', '');
                                    }
                                  });
                                }
                              },
                              activeColor: const Color(0xFF279778),
                            ),
                          ),
                          const Text(
                            "Remember me",
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Color(
                                  0xFF279778), // Change the text color here
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 4. Login button
                    Container(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: PrimaryCustomButton(
                        buttonText: "Sign In",
                        onPressed: () async {
                          // Trigger form validation before signing in
                          if (formKey.currentState!.validate()) {
                            // Call the signIn here if the form is valid
                            await AuthService().signIn(
                              email: _loginEmailController.text,
                              password: _loginPasswordController.text,
                              context: context,
                              isChecked: _isChecked,
                            );
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

                    // Error message
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                          ),
                        ),
                      ),

                    // FORGET PASSWORD TEXT
                    Container(
                      alignment: Alignment.center,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          // Navigate to forgot password page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage()),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    // CONTINUE WITH SOCIAL MEDIA ACCOUNT
                    Container(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: const Row(
                        children: <Widget>[
                          Expanded(
                            child: Divider(
                                color: Color(
                                    0xFF279778)), // Divider line on the left
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Continue with social media',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF279778),
                              ),
                            ),
                          ), // Text in the middle
                          Expanded(
                            child: Divider(
                              color: Color(0xFF279778),
                            ), // Divider line on the right
                          ),
                        ],
                      ),
                    ),

                    // SOCIAL MEDIA BUTTONS
                    Container(
                      padding:
                          const EdgeInsets.only(left: 25, right: 25, top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SocialMediaButton(
                            receivedLogo: 'images/facebook_logo.png',
                            receivedText: "Facebook",
                            receivedTextSize: 12.0,
                            receivedBorderRadius: 10.0,
                            receivedFontWeight: FontWeight.bold,
                            receivedColor: const Color(0xFF3C5A99),
                            receivedCallback: () {
                              // Continue to Facebook
                              showFloatingSnackBar(
                                context,
                                "Feature Under Development",
                                const Color(0xFF3C3C40),
                              );
                            },
                          ),
                          SocialMediaButton(
                            receivedLogo: 'images/google_logo.png',
                            receivedText: "Google",
                            receivedTextSize: 12.0,
                            receivedBorderRadius: 10.0,
                            receivedFontWeight: FontWeight.bold,
                            receivedColor: const Color(0xFFD83026),
                            receivedCallback: () {
                              // Continue to Google
                              showFloatingSnackBar(
                                context,
                                "Feature Under Development",
                                const Color(0xFF3C3C40),
                              );
                            },
                          ),
                          SocialMediaButton(
                            receivedLogo: 'images/apple_logo.png',
                            receivedText: "Apple",
                            receivedTextSize: 12.0,
                            receivedBorderRadius: 10.0,
                            receivedFontWeight: FontWeight.bold,
                            receivedColor: Colors.black,
                            receivedCallback: () {
                              // Continue to Apple
                              showFloatingSnackBar(
                                context,
                                "Feature Under Development",
                                const Color(0xFF3C3C40),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // SIGN UP TEXT
                    Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SelectRole(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 15.0,
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
            ],
          ),
        ),
      ),
    );
  }
}
