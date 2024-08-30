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
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomTextDisplay(
                receivedText: "Forgot Password?",
                receivedTextSize: 20,
                receivedTextWeight: FontWeight.w900,
                receivedLetterSpacing: 0,
                receivedTextColor: Color(0xFF193147),
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
                  const SizedBox(height: 20),

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
                    margin: const EdgeInsets.only(left: 25, top: 15, right: 25),
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
                        fillColor: const Color(0xFF193147).withOpacity(.2),
                        filled: true,
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(left: 5),
                          child: const Icon(
                            Icons.email_rounded,
                            color: Color(0xFF193147),
                          ),
                        ),
                        hintText: "Enter your email",
                        hintStyle: const TextStyle(
                          color: Color(0xFF193147),
                          fontWeight: FontWeight.normal,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF193147),
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
                  const SizedBox(height: 15),

                  // RESET PASSWORD BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: PrimaryCustomButton(
                      buttonText: "Reset Password",
                      onPressed: handleSubmit,
                      buttonHeight: 55,
                      buttonColor: const Color(0xFF193147),
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      fontColor: Colors.white,
                      elevation: 1,
                      borderRadius: 10,
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
