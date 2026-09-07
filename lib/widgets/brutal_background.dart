import 'package:flutter/material.dart';

import '../theme/brutal_theme.dart';

/// Fondo plano de bloques de color sólido (sin blur), base del estilo
/// Neo-Brutalist: reemplaza los "blobs" difuminados de [AppBackground].
class BrutalBackground extends StatelessWidget {
  final Widget child;

  const BrutalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BrutalColors.bgBase,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            bottom: -160,
            right: -160,
            child: Transform.rotate(
              angle: 0.78,
              child: Container(width: 400, height: 400, color: BrutalColors.bgShapeLight),
            ),
          ),
          Positioned(
            top: -110,
            left: -110,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: BrutalColors.bgShapeDark),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
