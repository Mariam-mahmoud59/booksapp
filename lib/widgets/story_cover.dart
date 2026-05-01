import 'dart:io';
import 'package:flutter/material.dart';

class StoryCover extends StatelessWidget {
  final List<Color> colors;
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;

  const StoryCover({
    super.key,
    required this.colors,
    this.imageUrl,
    this.width = 80,
    this.height = 80,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    Widget? imageContent;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('http')) {
        imageContent = Image.network(imageUrl!, fit: BoxFit.cover);
      } else {
        imageContent = Image.file(File(imageUrl!), fit: BoxFit.cover);
      }
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: imageContent == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageContent,
    );
  }
}
