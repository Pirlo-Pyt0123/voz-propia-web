import 'package:flutter/material.dart';

import '../theme/brutal_theme.dart';

/// Botón cuadrado con borde negro y sombra dura, como los íconos de header
/// del estilo Neo-Brutalist (ajustes, volver, cerrar sesión, etc.).
class BrutalIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color fill;
  final Color iconColor;

  const BrutalIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.fill = BrutalColors.cream,
    this.iconColor = BrutalColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: brutalDecoration(
          fill: fill,
          radius: 12,
          borderWidth: 2.5,
          shadowOffset: const Offset(3, 3),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}
