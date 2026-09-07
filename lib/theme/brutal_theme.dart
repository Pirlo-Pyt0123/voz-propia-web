import 'package:flutter/material.dart';

class BrutalColors {
  static const Color ink = Color(0xFF141414);
  static const Color cream = Color(0xFFFBF4E6);
  static const Color yellow = Color(0xFFFFD60A);
  static const Color pink = Color(0xFFFF3D81);
  static const Color purple = Color(0xFF6C4CE0);
  static const Color green = Color(0xFF00C48C);
  static const Color red = Color(0xFFE8434B);
  static const Color gray = Color(0xFFC9C2B4);

  // Escala de verdes exclusiva del fondo (BrutalBackground / scaffold) — no
  // se usa en tarjetas, badges ni ningún otro componente.
  static const Color bgBase = Color(0xFF4ADE80);
  static const Color bgShapeDark = Color(0xFF15803D);
  static const Color bgShapeLight = Color(0xFFBBF7D0);
}

/// Decoración base del estilo Neo-Brutalist: borde negro grueso + sombra
/// dura (offset, sin blur) en vez del blur/translucidez del glassmorphism.
BoxDecoration brutalDecoration({
  required Color fill,
  double radius = 20,
  double borderWidth = 3,
  Offset shadowOffset = const Offset(6, 6),
  Color borderColor = BrutalColors.ink,
}) {
  return BoxDecoration(
    color: fill,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor, width: borderWidth),
    boxShadow: [
      BoxShadow(color: borderColor, offset: shadowOffset, blurRadius: 0),
    ],
  );
}
