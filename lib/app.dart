import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/watchlist_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_shell.dart';

class CoinScopeApp extends StatelessWidget {
  const CoinScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<ThemeProvider, ThemeMode>((t) => t.mode);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final email = auth.user?.email;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WatchlistProvider>().bindUser(email);
    });

    return auth.isLoggedIn ? const HomeShell() : const LoginScreen();
  }
}
