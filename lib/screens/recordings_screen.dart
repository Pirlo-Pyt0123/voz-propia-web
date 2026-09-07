import 'package:flutter/material.dart';

import '../theme/brutal_theme.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_card.dart';
import '../widgets/brutal_placeholder_scaffold.dart';

class RecordingsScreen extends StatelessWidget {
  const RecordingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalPlaceholderScaffold(
      title: 'Grabaciones',
      subtitle: 'Grabá las muestras de tu voz para armar tu banco de voz.',
      icon: Icons.mic_rounded,
      accentColor: BrutalColors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progreso hacia el entrenamiento',
                  style: TextStyle(color: BrutalColors.ink, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.4,
                    minHeight: 14,
                    backgroundColor: BrutalColors.cream,
                    valueColor: const AlwaysStoppedAnimation(BrutalColors.green),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '2 de 5 grabaciones validadas (ejemplo)',
                  style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.65), fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _MockRecordingRow(phrase: 'La voz propia es una forma de identidad.', validated: true),
          const SizedBox(height: 10),
          _MockRecordingRow(phrase: 'Hoy el cielo está despejado y hace frío.', validated: true),
          const SizedBox(height: 10),
          _MockRecordingRow(phrase: 'Necesito que me ayudes con esto, por favor.', validated: false),
          const SizedBox(height: 20),
          const BrutalButton(label: 'Grabar nueva frase', onPressed: null),
        ],
      ),
    );
  }
}

class _MockRecordingRow extends StatelessWidget {
  final String phrase;
  final bool validated;

  const _MockRecordingRow({required this.phrase, required this.validated});

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 16,
      child: Row(
        children: [
          Icon(Icons.graphic_eq_rounded, color: BrutalColors.ink.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              phrase,
              style: const TextStyle(color: BrutalColors.ink, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: validated ? BrutalColors.green : BrutalColors.gray,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BrutalColors.ink, width: 1.5),
            ),
            child: Text(
              validated ? 'Validada' : 'Pendiente',
              style: const TextStyle(color: BrutalColors.ink, fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
