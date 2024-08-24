import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  // PARAMETERS NEEDED
  final TextEditingController controller;
  final FocusNode? currentFocusNode;
  final FocusNode? nextFocusNode;
  final TextInputType? keyBoardType;
  final List<TextInputFormatter>? inputFormatters;
  final String validatorText;
  final String? Function(String?) validator;
  final bool isPasswordVisible;
  final bool isPassword;
  final String hintText;
  final int? minLines;
  final int? maxLines;

  // CONSTRUCTORS FOR CREATING NEW INSTANCE/OBJECT
  const CustomTextField({
    super.key,
    required this.controller,
    required this.currentFocusNode,
    required this.nextFocusNode,
    this.keyBoardType,
    required this.inputFormatters,
    required this.validatorText,
    required this.validator,
    this.isPasswordVisible = true,
    required this.isPassword,
    required this.hintText,
    required this.minLines,
    required this.maxLines,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isPasswordVisible;

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = !widget.isPasswordVisible;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        cursorColor: const Color(0xFF0D6D52),
        controller: widget.controller,
        keyboardType: widget.keyBoardType,
        inputFormatters: widget.inputFormatters,
        focusNode: widget.currentFocusNode,
        validator: widget.validator,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        obscureText:
            widget.isPassword ? !_isPasswordVisible : _isPasswordVisible,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF6c7687),
            fontWeight: FontWeight.normal,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: Color(0xFF0D6D52),
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
              color: Color(0xFFBDBDC7),
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
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Icon(
                      !_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    widget.controller.clear();
                  },
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: const Icon(
                        Icons.clear_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ),
        onEditingComplete: () {
          if (widget.nextFocusNode != null) {
            FocusScope.of(context).requestFocus(widget.nextFocusNode);
          } else {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
