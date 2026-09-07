import 'package:flutter/material.dart';

import '../theme/brutal_theme.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_card.dart';
import '../widgets/brutal_placeholder_scaffold.dart';

class SynthesisScreen extends StatelessWidget {
  const SynthesisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalPlaceholderScaffold(
      title: 'Síntesis',
      subtitle: 'Escribí un texto y escuchalo con tu voz clonada.',
      icon: Icons.record_voice_over_rounded,
      accentColor: BrutalColors.pink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Texto a sintetizar',
                  style: TextStyle(color: BrutalColors.ink, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: BrutalColors.cream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: BrutalColors.ink, width: 2.5),
                    ),
                    child: Text(
                      'Escribí acá lo que querés escuchar con tu voz...',
                      style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.45), fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const BrutalButton(label: 'Generar audio', onPressed: null),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Historial',
            style: TextStyle(color: BrutalColors.ink, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          BrutalCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            radius: 16,
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BrutalColors.pink,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: BrutalColors.ink, width: 2),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: BrutalColors.ink, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '"Hola, esta es mi voz." (ejemplo)',
                    style: TextStyle(color: BrutalColors.ink, fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                ),
                Text('0:03', style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.6), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
