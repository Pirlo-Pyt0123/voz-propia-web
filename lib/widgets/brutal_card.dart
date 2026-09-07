import 'package:flutter/material.dart';

import '../theme/brutal_theme.dart';

/// Bloque de contenido genérico del estilo Neo-Brutalist: reemplaza a
/// [GlassContainer] para tarjetas de listas, estados vacíos, etc.
class BrutalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color fill;
  final Offset shadowOffset;

  const BrutalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
    this.fill = BrutalColors.cream,
    this.shadowOffset = const Offset(5, 5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: brutalDecoration(fill: fill, radius: radius, shadowOffset: shadowOffset),
      child: child,
    );
  }
}
