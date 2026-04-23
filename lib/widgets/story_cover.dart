import 'package:flutter/material.dart';

class StoryCover extends StatelessWidget {
  final List<Color> colors;
  final double width;
  final double height;
  final double borderRadius;

  const StoryCover({
    super.key,
    required this.colors,
    this.width = 80,
    this.height = 80,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }
}
