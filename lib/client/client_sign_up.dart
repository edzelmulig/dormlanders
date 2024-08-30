import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dormlanders/services/auth_service.dart';
import 'package:dormlanders/utils/custom_snackbar.dart';
import 'package:dormlanders/widgets/custom_app_bar.dart';
import 'package:dormlanders/widgets/custom_button.dart';
import 'package:dormlanders/widgets/custom_social_media_button.dart';
import 'package:dormlanders/widgets/custom_text_display.dart';
import 'package:dormlanders/widgets/custom_text_field.dart';
import 'package:dormlanders/widgets/terms_and_conditions.dart';

class ClientSignUp extends StatefulWidget {
  const ClientSignUp({
    super.key,
    required this.userType,
  });

  final String userType;

  @override
  State<ClientSignUp> createState() => _ClientSignUp();
}

class _ClientSignUp extends State<ClientSignUp> {
  // TextEditingController declarations
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isVisiblePassword = false;
  bool isVisibleConfirmPassword = false;

  // FORM KEY DECLARATION
  final formKey = GlobalKey<FormState>();

  // FOCUS NODE DECLARATION
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _phoneNumberFocusNode = FocusNode();
  final _emailAddressFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // SIGN UP
  Future<void> performSignUp() async {
    try {
      if (formKey.currentState!.validate()) {
        await AuthService.signUp(
          context: context,
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          displayName: "",
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
          userType: widget.userType,
        );
      } else {
        // Show error message if terms are not checked
        showFloatingSnackBar(
          context,
          "Please agree to the Terms and Conditions",
          const Color(0xFFe91b4f),
        );
      }
    } catch (error) {
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          "Error updating service: ${error.toString()}",
          const Color(0xFFe91b4f),
        );
      }
    }
  }

  // DISPOSE
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(AppBar().preferredSize.height),
          child: CustomAppBar(
              backgroundColor: const Color(0xFFFEFFFE),
              onLeadingPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Container(
          color: const Color(0xFFFEFFFE),
          child: ListView(
            children: <Widget>[
              const Center(
                child: CustomTextDisplay(
                  receivedText: "Join DormLanders",
                  receivedTextSize: 35,
                  receivedTextWeight: FontWeight.w800,
                  receivedLetterSpacing: 0,
                  receivedTextColor: Color(0xFF3C3C40),
                ),
              ),

              Container(
                padding: const EdgeInsets.only(left: 35, right: 35, bottom: 5),
                child: const Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                          color: Color(0xFF3C3C40)), // Divider line on the left
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Your ideal dorm, right at your fingertips.',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3C3C40),
                        ),
                      ),
                    ), // Text in the middle
                    Expanded(
                      child: Divider(
                        color: Color(0xFF3C3C40),
                      ), // Divider line on the right
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CONTAINER FOR FORM
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(left: 10, right: 10),
                width: MediaQuery.of(context).size.width,
                child: Form(
                  // Trigger validation along with the changes in the text field
                  autovalidateMode: AutovalidateMode.disabled,
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      // CLIENT'S FIRST NAME
                      Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // LABEL: DISPLAY NAME
                            const CustomTextDisplay(
                              receivedText: "First Name",
                              receivedTextSize: 14,
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
                              nextFocusNode: _phoneNumberFocusNode,
                              keyBoardType: null,
                              inputFormatters: null,
                              validatorText: "Last name is required",
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Last name is required";
                                }
                                return null;
                              },
                              hintText: "Enter your last name",
                              minLines: 1,
                              maxLines: 1,
                              isPassword: false,
                            ),

                            // SIZED BOX: SPACING
                            const SizedBox(height: 10),

                            // LABEL: LAST NAME
                            const CustomTextDisplay(
                              receivedText: "Phone Number",
                              receivedTextSize: 15,
                              receivedTextWeight: FontWeight.w500,
                              receivedLetterSpacing: 0,
                              receivedTextColor: Color(0xFF242424),
                            ),

                            // SIZED BOX: SPACING
                            const SizedBox(height: 2),

                            // TEXT FIELD: PHONE NUMBER
                            CustomTextField(
                              controller: _phoneNumberController,
                              currentFocusNode: _phoneNumberFocusNode,
                              nextFocusNode: _emailAddressFocusNode,
                              validatorText: "Phone number is required",
                              keyBoardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^[0-9]+$')),
                              ],
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Phone number is required";
                                }
                                return null;
                              },
                              hintText: "Enter your phone number",
                              minLines: 1,
                              maxLines: 1,
                              isPassword: false,
                            ),

                            // SIZED BOX: SPACING
                            const SizedBox(height: 10),

                            // LABEL: EMAIL ADDRESS
                            const CustomTextDisplay(
                              receivedText: "Email Address",
                              receivedTextSize: 15,
                              receivedTextWeight: FontWeight.w500,
                              receivedLetterSpacing: 0,
                              receivedTextColor: Color(0xFF242424),
                            ),

                            // SIZED BOX: SPACING
                            const SizedBox(height: 2),

                            // TEXT FIELD: EMAIL ADDRESS
                            CustomTextField(
                              controller: _emailController,
                              currentFocusNode: _emailAddressFocusNode,
                              nextFocusNode: _passwordFocusNode,
                              keyBoardType: null,
                              inputFormatters: null,
                              validatorText: "Email address is required",
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Email is required";
                                } else if (!EmailValidator.validate(value)) {
                                  return "Invalid email format";
                                }
                                return null;
                              },
                              hintText: "Enter email address",
                              minLines: 1,
                              maxLines: 1,
                              isPassword: false,
                            ),

                            // SIZED BOX: SPACING
                            const SizedBox(height: 10),

                            // LABEL: PASSWORD
                            const CustomTextDisplay(
                              receivedText: "Password",
                              receivedTextSize: 15,
                              receivedTextWeight: FontWeight.w500,
                              receivedLetterSpacing: 0,
                              receivedTextColor: Color(0xFF242424),
                            ),

                            // SIZED BOX: SPACING
                            const SizedBox(height: 2),

                            // TEXT FIELD: PASSWORD
                            CustomTextField(
                              controller: _passwordController,
                              currentFocusNode: _passwordFocusNode,
                              nextFocusNode: _confirmPasswordFocusNode,
                              keyBoardType: null,
                              inputFormatters: null,
                              validatorText: "Password is required",
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Password is required";
                                }
                                return null;
                              },
                              hintText: "Enter your password",
                              minLines: 1,
                              maxLines: 1,
                              isPassword: true,
                            ),

                            // SIZED BOX: SPACING
                            const SizedBox(height: 10),

                            // LABEL: CONFIRM PASSWORD
                            const CustomTextDisplay(
                              receivedText: "Confirm Password",
                              receivedTextSize: 15,
                              receivedTextWeight: FontWeight.w500,
                              receivedLetterSpacing: 0,
                              receivedTextColor: Color(0xFF242424),
                            ),

                            // SIZED BOX: SPACING
                            const SizedBox(height: 2),

                            // TEXT FIELD: CONFIRM PASSWORD
                            CustomTextField(
                              controller: _confirmPasswordController,
                              currentFocusNode: _confirmPasswordFocusNode,
                              nextFocusNode: null,
                              keyBoardType: null,
                              inputFormatters: null,
                              validatorText: "Password does not match",
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Password is required";
                                } else if (_passwordController.text != value) {
                                  return "Password does not match";
                                }
                                return null;
                              },
                              hintText: "Confirm your password",
                              minLines: 1,
                              maxLines: 1,
                              isPassword: true,
                            ),

                            // SIZED BOX: SPACING
                            const SizedBox(height: 20),

                            // CREATE ACCOUNT BUTTON
                            PrimaryCustomButton(
                              buttonText: "Create account",
                              onPressed: performSignUp,
                              buttonHeight: 55,
                              buttonColor: const Color(0xFF193147),
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              fontColor: Colors.white,
                              elevation: 1,
                              borderRadius: 10,
                            ),

                            // SIZED BOX: SPACING
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
