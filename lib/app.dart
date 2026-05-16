import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'data/services/onboarding_service.dart';
import 'injection.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'shell/app_shell.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Ad Campaign Dashboard',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            onGenerateRoute: onGenerateRoute,
            home: const _InitialScreen(),
          );
        },
      ),
    );
  }
}

class _InitialScreen extends StatefulWidget {
  const _InitialScreen();

  @override
  State<_InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<_InitialScreen> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final onboardingService = sl<OnboardingService>();
    final isCompleted = await onboardingService.isOnboardingCompleted();

    if (mounted) {
      setState(() {
        _showOnboarding = !isCompleted;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF111113),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1CB4BF),
          ),
        ),
      );
    }

    return _showOnboarding ? const OnboardingScreen() : const AppShell();
  }
}
