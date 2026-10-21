import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/voice_profile.dart';
import '../services/api_exception.dart';
import '../services/auth_controller.dart';
import '../theme/brutal_theme.dart';
import '../widgets/brutal_background.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_card.dart';
import '../widgets/brutal_icon_button.dart';
import '../widgets/brutal_text_field.dart';
import 'recordings_screen.dart';
import 'admin_screen.dart';
import 'settings_screen.dart';
import 'synthesis_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().refreshVoiceProfiles();
    });
  }

  Future<void> _showCreateProfileDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      barrierColor: BrutalColors.ink.withValues(alpha: 0.55),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: brutalDecoration(
              fill: BrutalColors.cream,
              radius: 20,
              borderWidth: 3,
              shadowOffset: const Offset(7, 7),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nuevo perfil de voz',
                  style: TextStyle(color: BrutalColors.ink, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                BrutalTextField(
                  controller: controller,
                  hintText: 'Ej. Mi voz',
                  icon: Icons.graphic_eq_rounded,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: BrutalColors.ink, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                      child: const Text(
                        'Crear',
                        style: TextStyle(color: BrutalColors.purple, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (name != null && name.isNotEmpty && mounted) {
      await context.read<AuthController>().createVoiceProfile(name);
    }
  }

  Future<void> _confirmDeleteProfile(VoiceProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: BrutalColors.ink.withValues(alpha: 0.55),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: brutalDecoration(
              fill: BrutalColors.cream,
              radius: 20,
              borderWidth: 3,
              shadowOffset: const Offset(7, 7),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Borrar "${profile.profileName}"?',
                  style: const TextStyle(color: BrutalColors.ink, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  'Se van a borrar todas sus grabaciones, el modelo de voz entrenado y '
                  'las frases sintetizadas. No se puede deshacer.',
                  style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7), fontSize: 13.5),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: BrutalColors.ink, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text(
                        'Borrar',
                        style: TextStyle(color: BrutalColors.red, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<AuthController>().deleteVoiceProfile(profile.id);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;

    return Scaffold(
      body: BrutalBackground(
        child: SafeArea(
          child: RefreshIndicator(
            color: BrutalColors.ink,
            onRefresh: () => context.read<AuthController>().refreshVoiceProfiles(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                BrutalCard(
                  padding: const EdgeInsets.all(16),
                  radius: 18,
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: BrutalColors.purple,
                          shape: BoxShape.circle,
                          border: Border.all(color: BrutalColors.ink, width: 2.5),
                          boxShadow: const [
                            BoxShadow(color: BrutalColors.ink, offset: Offset(3, 3), blurRadius: 0),
                          ],
                        ),
                        child: Text(
                          (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: BrutalColors.cream,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, ${user?.name.split(' ').first ?? ''}',
                              style: const TextStyle(
                                color: BrutalColors.ink,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.65), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      BrutalIconButton(
                        icon: Icons.logout_rounded,
                        onPressed: () => context.read<AuthController>().logout(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Tu banco de voz',
                  style: TextStyle(color: BrutalColors.ink, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Perfiles de voz creados y su estado de entrenamiento',
                  style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7), fontSize: 14),
                ),
                const SizedBox(height: 20),
                if (auth.loadingProfiles)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: BrutalColors.ink)),
                  )
                else if (auth.voiceProfiles.isEmpty)
                  BrutalCard(
                    child: Column(
                      children: [
                        Icon(Icons.mic_none_rounded, color: BrutalColors.ink.withValues(alpha: 0.7), size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          'Todavía no tenés perfiles de voz',
                          style: TextStyle(color: BrutalColors.ink, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Creá uno para empezar a grabar tu banco de voz.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7), fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        BrutalButton(label: 'Crear perfil de voz', onPressed: _showCreateProfileDialog),
                      ],
                    ),
                  )
                else ...[
                  ...auth.voiceProfiles.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => RecordingsScreen(profile: p)),
                        ),
                        child: _VoiceProfileCard(
                          profile: p,
                          onDelete: () => _confirmDeleteProfile(p),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  BrutalButton(
                    label: '+ Nuevo perfil de voz',
                    onPressed: _showCreateProfileDialog,
                    color: BrutalColors.cream,
                    textColor: BrutalColors.ink,
                  ),
                ],
                const SizedBox(height: 32),
                const Text(
                  'Próximamente',
                  style: TextStyle(color: BrutalColors.ink, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ComingSoonCard(
                        icon: Icons.mic_rounded,
                        label: 'Grabaciones',
                        fill: BrutalColors.green,
                        onTap: () => _openWithFirstProfile(
                          context,
                          auth,
                          (p) => RecordingsScreen(profile: p),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ComingSoonCard(
                        icon: Icons.record_voice_over_rounded,
                        label: 'Síntesis',
                        fill: BrutalColors.pink,
                        onTap: () => _openWithFirstProfile(
                          context,
                          auth,
                          (p) => SynthesisScreen(profile: p),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ComingSoonCard(
                  icon: Icons.settings_rounded,
                  label: 'Ajustes',
                  fill: BrutalColors.yellow,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
                if (auth.currentUser?.roleName == 'administrator') ...[
                  const SizedBox(height: 12),
                  _ComingSoonCard(
                    icon: Icons.admin_panel_settings_rounded,
                    label: 'Administración',
                    fill: BrutalColors.purple,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminScreen()),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _openWithFirstProfile(
  BuildContext context,
  AuthController auth,
  Widget Function(VoiceProfile) builder,
) {
  if (auth.voiceProfiles.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creá un perfil de voz primero.')),
    );
    return;
  }
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => builder(auth.voiceProfiles.first)));
}

class _VoiceProfileCard extends StatelessWidget {
  final VoiceProfile profile;
  final VoidCallback onDelete;

  const _VoiceProfileCard({required this.profile, required this.onDelete});

  Color get _statusColor {
    switch (profile.trainingStatus) {
      case 'ready':
        return BrutalColors.green;
      case 'training':
        return BrutalColors.yellow;
      case 'error':
        return BrutalColors.red;
      default:
        return BrutalColors.gray;
    }
  }

  String get _statusLabel {
    switch (profile.trainingStatus) {
      case 'ready':
        return 'Listo';
      case 'training':
        return 'Entrenando';
      case 'error':
        return 'Error';
      default:
        return 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BrutalCard(
      padding: const EdgeInsets.all(18),
      radius: 18,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: brutalDecoration(
              fill: BrutalColors.purple,
              radius: 13,
              borderWidth: 2,
              shadowOffset: const Offset(2, 2),
            ),
            child: const Icon(Icons.graphic_eq_rounded, color: BrutalColors.cream),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.profileName,
                  style: const TextStyle(color: BrutalColors.ink, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Creado el ${profile.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}',
                  style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.6), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BrutalColors.ink, width: 2),
            ),
            child: Text(
              _statusLabel,
              style: const TextStyle(color: BrutalColors.ink, fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.delete_outline_rounded, color: BrutalColors.ink.withValues(alpha: 0.55), size: 22),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color fill;
  final VoidCallback onTap;

  const _ComingSoonCard({
    required this.icon,
    required this.label,
    required this.fill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BrutalCard(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        radius: 16,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: BrutalColors.ink, width: 2),
              ),
              child: Icon(icon, color: BrutalColors.ink, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: BrutalColors.ink, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
