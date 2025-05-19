import 'dart:io';
import 'package:flutter/material.dart';

class BuildDisplayImage extends StatelessWidget {
  const BuildDisplayImage({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60.0,
          backgroundColor: Colors.grey[200],
          backgroundImage: AssetImage(imagePath),
        ),
      ],
    );
  }
}