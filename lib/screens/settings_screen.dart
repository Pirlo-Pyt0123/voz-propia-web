import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_controller.dart';
import '../theme/brutal_theme.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_card.dart';
import '../widgets/brutal_placeholder_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;

    return BrutalPlaceholderScaffold(
      title: 'Ajustes',
      subtitle: 'Tu cuenta y preferencias.',
      icon: Icons.settings_rounded,
      accentColor: BrutalColors.yellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cuenta',
                  style: TextStyle(color: BrutalColors.ink, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.name ?? '',
                  style: const TextStyle(color: BrutalColors.ink, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.65), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _MockToggleRow(label: 'Notificaciones de entrenamiento'),
          const SizedBox(height: 10),
          const _MockToggleRow(label: 'Guardar audio en el dispositivo'),
          const SizedBox(height: 20),
          BrutalButton(
            label: 'Cerrar sesión',
            color: BrutalColors.red,
            textColor: BrutalColors.cream,
            onPressed: () {
              context.read<AuthController>().logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}

class _MockToggleRow extends StatelessWidget {
  final String label;

  const _MockToggleRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      radius: 16,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: BrutalColors.ink, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
          IgnorePointer(
            child: Switch(value: false, onChanged: (_) {}, activeThumbColor: BrutalColors.purple),
          ),
        ],
      ),
    );
  }
}
