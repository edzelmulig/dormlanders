import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:dormlanders/services/auth_service.dart';
import 'package:dormlanders/widgets/custom_button.dart';
import 'package:dormlanders/widgets/custom_image_display.dart';
import 'package:dormlanders/widgets/custom_social_media_button.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _forgotEmailController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _forgotEmailController.dispose();
    super.dispose();
  }

  void handleSubmit() {
    // CALL THE  _submitForm METHOD
    AuthService().passwordReset(
      context,
      formKey,
      _forgotEmailController,
    );
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
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
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
                text: const TextSpan(children: <TextSpan>[
                  TextSpan(
                    text: "Mental",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3C3C40),
                    ),
                  ),
                  TextSpan(
                    text: "Boost",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3C3C40),
                    ),
                  ),
                ]),
              ),
              const SizedBox(
                width: 20.0,
              ),
            ],
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new),
            iconSize: 25,
          ),
          backgroundColor: const Color(0xFFF7F5F5),
        ),
        body: ListView(
          children: <Widget>[
            Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    const CustomImageDisplay(
                      receivedImageLocation: "images/email_icon.png",
                      receivedPaddingLeft: 0,
                      receivedPaddingRight: 0,
                      receivedPaddingTop: 20,
                      receivedPaddingBottom: 10,
                      receivedImageWidth: 200,
                      receivedImageHeight: 200,
                    ),

                    // Forgot password text
                    const Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Center(
                        child: CustomTextDisplay(
                          receivedText: "Update your password",
                          receivedTextSize: 25,
                          receivedTextWeight: FontWeight.bold,
                          receivedLetterSpacing: 0,
                          receivedTextColor: Color(0xFF3C3C40),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: RichText(
                          text: const TextSpan(children: <TextSpan>[
                            TextSpan(
                              text: "Enter your email address and select ",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF3C3C40),
                              ),
                            ),
                            TextSpan(
                              text: "Reset Password.",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3C3C40),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),

                    Container(
                      margin:
                          const EdgeInsets.only(left: 25, top: 15, right: 25),
                      child: TextFormField(
                        cursorColor: const Color(0xFF6c7687),
                        controller: _forgotEmailController,
                        validator: (forgotEmailController) {
                          if (forgotEmailController!.isEmpty) {
                            return "Email is required";
                          } else if (!EmailValidator.validate(
                              forgotEmailController)) {
                            return "Invalid email format";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          fillColor: const Color(0xFF279778).withOpacity(.2),
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
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(height: 10),

                    // RESET PASSWORD BUTTON
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: PrimaryCustomButton(
                        buttonText: "Reset Password",
                        onPressed: handleSubmit,
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
                      margin: const EdgeInsets.only(top: 15, bottom: 10),
                      alignment: Alignment.center,
                      child: const CustomTextDisplay(
                        receivedText: "or",
                        receivedTextSize: 20,
                        receivedTextWeight: FontWeight.w400,
                        receivedLetterSpacing: 0,
                        receivedTextColor: Color(0xFF3C3C40),
                      ),
                    ),

                    Container(
                      margin:
                          const EdgeInsets.only(left: 25, right: 25, top: 5),
                      width: MediaQuery.of(context).size.width,
                      child: FractionallySizedBox(
                        widthFactor: 1.0,
                        child: SizedBox(
                          height: 50,
                          child: SocialMediaButton(
                            receivedLogo: 'images/google_logo.png',
                            receivedText: "Log in with Google",
                            receivedTextSize: 18,
                            receivedBorderRadius: 10,
                            receivedFontWeight: FontWeight.normal,
                            receivedColor: const Color(0xFFD83026),
                            receivedCallback: () {
                              // Continue to facebook
                            },
                          ),
                        ),
                      ),
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(height: 10),

                    Container(
                      margin: const EdgeInsets.only(left: 25, right: 25),
                      width: MediaQuery.of(context).size.width,
                      child: FractionallySizedBox(
                        widthFactor: 1.0,
                        child: SizedBox(
                          height: 50,
                          child: SocialMediaButton(
                            receivedLogo: 'images/facebook_logo.png',
                            receivedText: "Log in with Facebook",
                            receivedTextSize: 18,
                            receivedBorderRadius: 10,
                            receivedFontWeight: FontWeight.normal,
                            receivedColor: const Color(0xFF3C5A99),
                            receivedCallback: () {
                              // Continue to facebook
                            },
                          ),
                        ),
                      ),
                    ),

                    // SIZED BOX: SPACING
                    const SizedBox(height: 10),

                    const Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: CustomTextDisplay(
                        receivedText:
                            "If you used Facebook or Google to join MentalBoost, "
                            "please use the appropriate button above to log in.",
                        receivedTextSize: 13,
                        receivedTextWeight: FontWeight.w400,
                        receivedLetterSpacing: 0,
                        receivedTextColor: Color(0xFF3C3C40),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
