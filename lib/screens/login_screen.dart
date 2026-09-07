import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_exception.dart';
import '../services/auth_controller.dart';
import '../theme/brutal_theme.dart';
import '../widgets/brutal_background.dart';
import '../widgets/brutal_button.dart';
import '../widgets/brutal_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorText = 'Completá tu correo y contraseña.');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await context.read<AuthController>().login(email, password);
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
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: brutalDecoration(
                              fill: BrutalColors.purple,
                              radius: 12,
                              borderWidth: 2.5,
                              shadowOffset: const Offset(3, 3),
                            ),
                            child: const Icon(Icons.graphic_eq_rounded, color: BrutalColors.cream),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'PROPIA VOZ',
                            style: TextStyle(
                              color: BrutalColors.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Bienvenido',
                        style: TextStyle(color: BrutalColors.ink, fontSize: 34, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Iniciá sesión para acceder a tu banco de voz',
                        style: TextStyle(color: BrutalColors.ink.withValues(alpha: 0.7), fontSize: 15),
                      ),
                      const SizedBox(height: 28),
                      BrutalTextField(
                        controller: _emailController,
                        hintText: 'Correo electrónico',
                        icon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      BrutalTextField(
                        controller: _passwordController,
                        hintText: 'Contraseña',
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
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _rememberMe = !_rememberMe),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _rememberMe ? BrutalColors.purple : BrutalColors.cream,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: BrutalColors.ink, width: 2),
                              ),
                              child: _rememberMe
                                  ? const Icon(Icons.check_rounded, size: 16, color: BrutalColors.cream)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => setState(() => _rememberMe = !_rememberMe),
                            child: Text(
                              'Recordarme',
                              style: TextStyle(
                                color: BrutalColors.ink.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
                      BrutalButton(label: 'Ingresar', onPressed: _submit, loading: _loading),
                      const SizedBox(height: 22),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              '¿No tenés cuenta? ',
                              style: TextStyle(
                                color: BrutalColors.ink.withValues(alpha: 0.75),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                );
                              },
                              child: const Text(
                                'Registrate',
                                style: TextStyle(
                                  color: BrutalColors.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  decorationColor: BrutalColors.ink,
                                  decorationThickness: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
