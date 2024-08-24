import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ServiceShimmer extends StatelessWidget {
  final int itemCount;
  final double containerHeight;

  const ServiceShimmer({
    super.key,
    required this.itemCount,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!, // Adjust the base color as needed
      highlightColor: Colors.grey[100]!, // Adjust the highlight color as needed
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: itemCount, // Adjust the number of items as needed
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 100.0,
                  height: containerHeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
