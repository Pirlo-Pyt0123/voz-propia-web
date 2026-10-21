import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_exception.dart';
import '../services/app_preferences.dart';
import '../services/auth_controller.dart';
import '../theme/brutal_theme.dart';
import '../widgets/brutal_background.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_card.dart';
import '../widgets/brutal_icon_button.dart';
import '../widgets/brutal_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSaveAudio = false;
  bool _loadingPref = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final value = await AppPreferences.getAutoSaveAudio();
    if (mounted) {
      setState(() {
        _autoSaveAudio = value;
        _loadingPref = false;
      });
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editProfile() async {
    final auth = context.read<AuthController>();
    final nameController = TextEditingController(text: auth.currentUser?.name ?? '');
    final emailController = TextEditingController(text: auth.currentUser?.email ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: BrutalColors.ink.withValues(alpha: 0.55),
      builder: (ctx) => _BrutalDialog(
        title: 'Editar perfil',
        confirmLabel: 'Guardar',
        confirmColor: BrutalColors.purple,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BrutalTextField(controller: nameController, hintText: 'Nombre', icon: Icons.person_outline_rounded),
            const SizedBox(height: 12),
            BrutalTextField(controller: emailController, hintText: 'Email', icon: Icons.email_outlined),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await auth.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
      );
      if (mounted) _showSnack('Perfil actualizado.');
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message);
    }
  }

  Future<void> _changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: BrutalColors.ink.withValues(alpha: 0.55),
      builder: (ctx) => _BrutalDialog(
        title: 'Cambiar contraseña',
        confirmLabel: 'Cambiar',
        confirmColor: BrutalColors.purple,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BrutalTextField(
              controller: currentController,
              hintText: 'Contraseña actual',
              icon: Icons.lock_outline_rounded,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            BrutalTextField(
              controller: newController,
              hintText: 'Contraseña nueva (mín. 8 caracteres)',
              icon: Icons.lock_reset_rounded,
              obscureText: true,
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    if (newController.text.trim().length < 8) {
      _showSnack('La contraseña nueva debe tener al menos 8 caracteres.');
      return;
    }

    try {
      await context.read<AuthController>().changePassword(
            currentPassword: currentController.text,
            newPassword: newController.text.trim(),
          );
      if (mounted) _showSnack('Contraseña actualizada.');
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message);
    }
  }

  Future<void> _confirmDeleteAccount() async {
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
                const Text(
                  '¿Borrar tu cuenta?',
                  style: TextStyle(color: BrutalColors.ink, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Se van a borrar todos tus perfiles de voz, grabaciones, modelos '
                  'entrenados y frases sintetizadas. No se puede deshacer.',
                  style: TextStyle(color: BrutalColors.ink, fontSize: 13.5),
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
                        'Borrar todo',
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
      await context.read<AuthController>().deleteAccount();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;

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
              const SizedBox(height: 16),
              const Text(
                'Ajustes',
                style: TextStyle(color: BrutalColors.ink, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Tu cuenta y preferencias.',
                style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7), fontSize: 14),
              ),
              const SizedBox(height: 20),
              BrutalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Cuenta',
                            style: TextStyle(color: BrutalColors.ink, fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                        GestureDetector(
                          onTap: _editProfile,
                          child: Icon(Icons.edit_rounded, color: BrutalColors.ink.withValues(alpha: 0.6), size: 20),
                        ),
                      ],
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
              BrutalCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                radius: 16,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Guardar audio generado en el dispositivo',
                        style: TextStyle(color: BrutalColors.ink, fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    _loadingPref
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: BrutalColors.ink),
                          )
                        : Switch(
                            value: _autoSaveAudio,
                            onChanged: (value) async {
                              setState(() => _autoSaveAudio = value);
                              await AppPreferences.setAutoSaveAudio(value);
                            },
                            activeThumbColor: BrutalColors.purple,
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Cada frase que generes en Síntesis se guarda también como archivo '
                'en una carpeta "VozPropia" del dispositivo.',
                style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.55), fontSize: 11.5),
              ),
              const SizedBox(height: 20),
              BrutalButton(
                label: 'Cambiar contraseña',
                color: BrutalColors.cream,
                textColor: BrutalColors.ink,
                onPressed: _changePassword,
              ),
              const SizedBox(height: 10),
              BrutalButton(
                label: 'Cerrar sesión',
                color: BrutalColors.red,
                textColor: BrutalColors.cream,
                onPressed: () {
                  context.read<AuthController>().logout();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 10),
              BrutalButton(
                label: 'Borrar mi cuenta',
                color: BrutalColors.red,
                textColor: BrutalColors.cream,
                onPressed: _confirmDeleteAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrutalDialog extends StatelessWidget {
  final String title;
  final String confirmLabel;
  final Color confirmColor;
  final Widget child;

  const _BrutalDialog({
    required this.title,
    required this.confirmLabel,
    required this.confirmColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                title,
                style: const TextStyle(color: BrutalColors.ink, fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              child,
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: BrutalColors.ink, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      confirmLabel,
                      style: TextStyle(color: confirmColor, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
