import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// TERMS AND CONDITIONS
class TermsAndConditions extends StatefulWidget {
  // PARAMETERS NEEDED
  final bool isChecked;

  const TermsAndConditions({
    super.key,
    required this.isChecked,
  });

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Theme(
          data: ThemeData(
            checkboxTheme: CheckboxThemeData(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(4.0),
              ),
            ),
          ),
          child: Checkbox(
            checkColor: const Color(0xFFFEFFFE),
            value: _isChecked,
            onChanged: (newValue) {
              if (mounted) {
                setState(() {
                  _isChecked = newValue!;
                });
              }
            },
            activeColor: const Color(0xFF3C3C40),
          ),
        ),

        RichText(
          text: TextSpan(
            children: <TextSpan>[
              const TextSpan(
                text: "I agree to the ",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF3C3C40),
                ),
              ),
              TextSpan(
                text: "Terms and Conditions",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C3C40),
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {},
              ),
            ],
          ),
        ),

        // Add an icon or message indicating that the checkbox is required
        if (!_isChecked)
          const Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              Icons.error,
              color: Colors.red,
            ),
          ),
      ],
    );
  }
}
