import 'package:flutter/material.dart';

import '../theme/brutal_theme.dart';
import 'brutal_background.dart';
import 'brutal_card.dart';
import 'brutal_icon_button.dart';

/// Base compartida para las pantallas todavía no conectadas a funcionalidad
/// real (Grabaciones, Síntesis, Evaluaciones, Ajustes): header consistente
/// con ícono/color propios + badge "En construcción" + contenido mock.
class BrutalPlaceholderScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget child;

  const BrutalPlaceholderScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrutalBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  BrutalIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              BrutalCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: brutalDecoration(
                            fill: accentColor,
                            radius: 13,
                            borderWidth: 2.5,
                            shadowOffset: const Offset(3, 3),
                          ),
                          child: Icon(icon, color: BrutalColors.ink),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: BrutalColors.ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              child,
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: brutalDecoration(
                  fill: const Color(0xFFFFF3C4),
                  radius: 14,
                  borderWidth: 2.5,
                  shadowOffset: const Offset(3, 3),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: BrutalColors.ink, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Vista previa: todavía no está conectada a funcionalidad real.',
                        style: TextStyle(color: BrutalColors.ink, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
