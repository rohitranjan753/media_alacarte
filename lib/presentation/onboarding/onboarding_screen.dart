import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../data/services/onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<AnimationController> _controllers;
  final _onboardingService = OnboardingService();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      2,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      ),
    );
    _controllers[0].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _controllers[page].forward();
  }

  Future<void> _completeOnboarding() async {
    await _onboardingService.setOnboardingCompleted();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.campaignList);
    }
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated gradient background
          const _AnimatedBackground(),

          // Floating particles
          const _FloatingParticles(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                if (_currentPage == 0)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      _OnboardingPage1(controller: _controllers[0]),
                      _OnboardingPage2(controller: _controllers[1]),
                    ],
                  ),
                ),

                // Bottom section
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          2,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == 0
                                    ? 'Next'
                                    : 'Get Started',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == 0
                                    ? Icons.arrow_forward_rounded
                                    : Icons.rocket_launch_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 1: Welcome ──────────────────────────────────────────────────────────

class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo/icon
              Transform.scale(
                scale: 0.5 + (0.5 * controller.value),
                child: Opacity(
                  opacity: controller.value,
                  child: Transform.rotate(
                    angle: (1 - controller.value) * 0.5,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Title
              Transform.translate(
                offset: Offset(0, 30 * (1 - controller.value)),
                child: Opacity(
                  opacity: controller.value,
                  child: const Text(
                    'Welcome to\nMedia Alacarte',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Description
              Transform.translate(
                offset: Offset(0, 30 * (1 - controller.value)),
                child: Opacity(
                  opacity: controller.value * 0.8,
                  child: const Text(
                    'Your intelligent companion for monitoring\nad campaign performance with real-time\ninsights and ML-powered predictions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Feature highlights
              Transform.translate(
                offset: Offset(0, 30 * (1 - controller.value)),
                child: Opacity(
                  opacity: controller.value,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _FeatureChip(
                        icon: Icons.analytics_outlined,
                        label: 'Real-time Analytics',
                        delay: 0.0,
                      ),
                      _FeatureChip(
                        icon: Icons.psychology_outlined,
                        label: 'ML Forecasting',
                        delay: 0.1,
                      ),
                      _FeatureChip(
                        icon: Icons.notifications_active_outlined,
                        label: 'Smart Alerts',
                        delay: 0.2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Page 2: Features ─────────────────────────────────────────────────────────

class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Transform.translate(
                offset: Offset(0, 30 * (1 - controller.value)),
                child: Opacity(
                  opacity: controller.value,
                  child: const Text(
                    'Powerful Features',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Transform.translate(
                offset: Offset(0, 30 * (1 - controller.value)),
                child: Opacity(
                  opacity: controller.value * 0.8,
                  child: const Text(
                    'Everything you need to optimize\nyour ad campaigns',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Feature cards
              _FeatureCard(
                icon: Icons.show_chart_rounded,
                title: 'CTR Forecasting',
                description:
                    '7-day ML predictions with confidence intervals',
                color: AppColors.primary,
                animation: controller,
                delay: 0.0,
              ),
              const SizedBox(height: 16),
              _FeatureCard(
                icon: Icons.monitor_heart_outlined,
                title: 'Anomaly Detection',
                description:
                    'Real-time alerts for spend spikes and CTR drops',
                color: AppColors.chartSocial,
                animation: controller,
                delay: 0.1,
              ),
              const SizedBox(height: 16),
              _FeatureCard(
                icon: Icons.pie_chart_rounded,
                title: 'Spend Analytics',
                description:
                    'Detailed breakdown by channel and performance',
                color: AppColors.chartDisplay,
                animation: controller,
                delay: 0.2,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Feature Card ─────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.animation,
    required this.delay,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Animation<double> animation;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final delayedAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          delay,
          1.0,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - delayedAnimation.value)),
          child: Opacity(
            opacity: delayedAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Feature Chip ─────────────────────────────────────────────────────────────

class _FeatureChip extends StatefulWidget {
  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.delay,
  });

  final IconData icon;
  final String label;
  final double delay;

  @override
  State<_FeatureChip> createState() => _FeatureChipState();
}

class _FeatureChipState extends State<_FeatureChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated Background ──────────────────────────────────────────────────────

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                -0.5 + (_controller.value * 0.5),
                -0.5 + (_controller.value * 0.3),
              ),
              radius: 1.5,
              colors: [
                AppColors.primary.withValues(alpha: 0.05),
                AppColors.background,
                AppColors.background,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// ── Floating Particles ───────────────────────────────────────────────────────

class _FloatingParticles extends StatefulWidget {
  const _FloatingParticles();

  @override
  State<_FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<_FloatingParticles>
    with TickerProviderStateMixin {
  late List<AnimationController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 4000 + (index * 500)),
        vsync: this,
      )..repeat(reverse: true),
    );
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return IgnorePointer(
      child: Stack(
        children: [
          _buildParticle(size, 0, 0.2, 0.3, 60, AppColors.primary),
          _buildParticle(size, 1, 0.7, 0.5, 80, AppColors.chartSocial),
          _buildParticle(size, 2, 0.4, 0.7, 70, AppColors.chartDisplay),
        ],
      ),
    );
  }

  Widget _buildParticle(
    Size size,
    int index,
    double x,
    double y,
    double particleSize,
    Color color,
  ) {
    return AnimatedBuilder(
      animation: controllers[index],
      builder: (context, child) {
        final offsetY = 30 * controllers[index].value;
        return Positioned(
          left: size.width * x,
          top: size.height * y + offsetY,
          child: Opacity(
            opacity: 0.3 + (0.5 * controllers[index].value),
            child: Container(
              width: particleSize,
              height: particleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
