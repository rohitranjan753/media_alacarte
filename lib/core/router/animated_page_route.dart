import 'package:flutter/material.dart';

/// Custom page route with slide and fade animations
class AnimatedPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final RouteSettings routeSettings;

  AnimatedPageRoute({
    required this.page,
    required this.routeSettings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          settings: routeSettings,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide from right with curve
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            final slideTween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            final slideAnimation = animation.drive(slideTween);

            // Fade in with delay
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: const Interval(0.2, 1.0, curve: Curves.easeIn)));
            final fadeAnimation = animation.drive(fadeTween);

            // Scale for subtle zoom effect
            final scaleTween = Tween<double>(begin: 0.95, end: 1.0)
                .chain(CurveTween(curve: curve));
            final scaleAnimation = animation.drive(scaleTween);

            // Reverse animation for previous page (subtle fade out)
            final reverseAnimation = Tween<double>(begin: 1.0, end: 0.95)
                .animate(secondaryAnimation);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Transform.scale(
                    scale: reverseAnimation.value,
                    child: child,
                  ),
                ),
              ),
            );
          },
        );
}
