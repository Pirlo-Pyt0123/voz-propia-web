import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_controller.dart';
import 'theme/brutal_theme.dart';
import 'widgets/brutal_background.dart';

void main() {
  runApp(const VozPropiaApp());
}

class VozPropiaApp extends StatelessWidget {
  const VozPropiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController()..bootstrap(),
      child: MaterialApp(
        title: 'Propia Voz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: BrutalColors.purple,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: BrutalColors.bgBase,
          textTheme: GoogleFonts.manropeTextTheme(ThemeData(brightness: Brightness.light).textTheme),
        ),
        home: const _RootRouter(),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthController>().status;

    switch (status) {
      case AuthStatus.unknown:
        return Scaffold(
          body: BrutalBackground(
            child: const Center(child: CircularProgressIndicator(color: BrutalColors.ink)),
          ),
        );
      case AuthStatus.authenticated:
        return const DashboardScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}
