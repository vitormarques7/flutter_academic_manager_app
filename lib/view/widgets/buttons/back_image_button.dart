import 'package:flutter/material.dart';

class BackImageButton extends StatelessWidget {
  final VoidCallback? onTap;

  const BackImageButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/view/assets/image_white_back.webp'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
