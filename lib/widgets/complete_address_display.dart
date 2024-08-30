import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CompleteAddressDisplay extends StatelessWidget {
  final Map<String, String> placeDetails;

  const CompleteAddressDisplay({
    Key? key,
    required this.placeDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 15,
        bottom: 15,
        right: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF193147),
          width: 1.5,
        ),
        color: const Color(0xFFe8eaed),
      ),
      child: Row(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: Icon(
              Icons.location_on_sharp,
              color: Color(0xFF193147),
              size: 30,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AutoSizeText(
                  "${placeDetails['street']}, "
                      "${placeDetails['barangay']}, "
                      "${placeDetails['city']},",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                  minFontSize: 15,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AutoSizeText(
                  "${placeDetails['province']}, "
                      "${placeDetails['region']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                  minFontSize: 14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
