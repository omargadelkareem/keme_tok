import 'package:flutter/material.dart';

/// Shared Keme Tok logo. Put the image at assets/images/keme_tok_logo.png.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 100, this.borderRadius = 22});
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: Image.asset(
      'assets/images/keme_tok_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: size,
        height: size,
        child: const Center(child: Icon(Icons.play_circle_fill,
          color: Color(0xFFFF4081), size: 58)),
      ),
    ),
  );
}
