import 'package:flutter/material.dart';

import '../theme/brutal_theme.dart';
import '../widgets/brutal_card.dart';
import '../widgets/brutal_placeholder_scaffold.dart';

class EvaluationsScreen extends StatelessWidget {
  const EvaluationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalPlaceholderScaffold(
      title: 'Evaluaciones',
      subtitle: 'Historial de calidad de tu voz clonada (MOS / MCD).',
      icon: Icons.insights_rounded,
      accentColor: BrutalColors.purple,
      child: Row(
        children: [
          Expanded(
            child: _ScoreCard(
              label: 'MOS',
              value: '4.2',
              hint: 'Calidad percibida (1-5, ejemplo)',
              fill: BrutalColors.purple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ScoreCard(
              label: 'MCD',
              value: '5.8',
              hint: 'Distorsión espectral (ejemplo)',
              fill: BrutalColors.pink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final Color fill;

  const _ScoreCard({required this.label, required this.value, required this.hint, required this.fill});

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: BrutalColors.ink, width: 2),
            ),
            child: Text(
              label,
              style: const TextStyle(color: BrutalColors.ink, fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: BrutalColors.ink, fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(hint, style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.6), fontSize: 11.5)),
        ],
      ),
    );
  }
}
