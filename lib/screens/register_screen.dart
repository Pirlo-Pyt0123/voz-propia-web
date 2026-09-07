import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_exception.dart';
import '../services/auth_controller.dart';
import '../theme/brutal_theme.dart';
import '../widgets/brutal_background.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_icon_button.dart';
import '../widgets/brutal_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.length < 8) {
      setState(() => _errorText = 'Completá todos los campos (contraseña de al menos 8 caracteres).');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await context.read<AuthController>().register(name, email, password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Ahora podés iniciar sesión.')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() => _errorText = e.message);
    } catch (_) {
      setState(() => _errorText = 'No se pudo conectar con el servidor.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrutalBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: brutalDecoration(
                    fill: BrutalColors.cream,
                    radius: 24,
                    borderWidth: 3.5,
                    shadowOffset: const Offset(9, 9),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BrutalIconButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Crear cuenta',
                        style: TextStyle(color: BrutalColors.ink, fontSize: 30, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Registrate para armar tu banco de voz',
                        style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7), fontSize: 15),
                      ),
                      const SizedBox(height: 28),
                      BrutalTextField(
                        controller: _nameController,
                        hintText: 'Nombre completo',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),
                      BrutalTextField(
                        controller: _emailController,
                        hintText: 'Correo electrónico',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      BrutalTextField(
                        controller: _passwordController,
                        hintText: 'Contraseña (mín. 8 caracteres)',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: BrutalColors.ink,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      if (_errorText != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: brutalDecoration(
                            fill: const Color(0xFFFFE1E1),
                            radius: 12,
                            borderWidth: 2.5,
                            borderColor: BrutalColors.red,
                            shadowOffset: const Offset(3, 3),
                          ),
                          child: Text(
                            _errorText!,
                            style: const TextStyle(
                              color: BrutalColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 26),
                      BrutalButton(label: 'Crear cuenta', onPressed: _submit, loading: _loading),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
