import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Base shimmer widget that creates an interactive shimmer animation effect
/// with a sweeping flash animation from left to right
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = AppColors.surface,
    this.highlightColor,
    this.enabled = true,
  });

  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color? highlightColor;
  final bool enabled;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(min: 0.0, max: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    // More visible highlight color with higher opacity
    final highlightColor = widget.highlightColor ??
        AppColors.textSecondary.withValues(alpha: 0.15);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate the position of the shimmer sweep
        // -1.0 to 2.0 range ensures the shimmer starts off-screen and ends off-screen
        final percent = _controller.value;
        final start = -1.0 + (percent * 3.0); // Moves from -1 to 2
        final end = start + 0.5; // Width of the shimmer effect

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.baseColor,
                highlightColor,
                highlightColor.withValues(alpha: highlightColor.a * 1.5),
                highlightColor,
                widget.baseColor,
                widget.baseColor,
              ],
              stops: [
                // Create a smooth gradient with a bright center
                (start - 0.3).clamp(0.0, 1.0),
                (start - 0.1).clamp(0.0, 1.0),
                (start).clamp(0.0, 1.0),
                (start + 0.15).clamp(0.0, 1.0),
                (end - 0.1).clamp(0.0, 1.0),
                (end).clamp(0.0, 1.0),
                (end + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Simple shimmer box - the building block for shimmer layouts
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.withPulse = false,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final bool withPulse;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    if (withPulse) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.85, end: 1.0),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: 0.3 + (value * 0.5),
              child: child,
            ),
          );
        },
        onEnd: () {
          // Trigger rebuild to loop the animation
          if (context.mounted) {
            (context as Element).markNeedsBuild();
          }
        },
        child: box,
      );
    }

    return box;
  }
}

/// Shimmer circle - useful for avatars and icons
class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Shimmer line - useful for text placeholders
class ShimmerLine extends StatelessWidget {
  const ShimmerLine({
    super.key,
    this.width,
    this.height = 12,
    this.borderRadius = 6,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

/// Wave shimmer effect - Creates a more dynamic wave animation
/// Perfect for loading states that need extra attention
class WaveShimmer extends StatefulWidget {
  const WaveShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
  });

  final Widget child;
  final Duration duration;

  @override
  State<WaveShimmer> createState() => _WaveShimmerState();
}

class _WaveShimmerState extends State<WaveShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
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
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final percent = _controller.value;
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.surface,
                AppColors.textSecondary.withValues(alpha: 0.2),
                AppColors.surface,
              ],
              stops: [
                (percent - 0.3).clamp(0.0, 1.0),
                percent,
                (percent + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Pulse shimmer effect - Creates a subtle pulsing animation
/// Good for important elements like status indicators
class PulseShimmer extends StatefulWidget {
  const PulseShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minOpacity = 0.5,
    this.maxOpacity = 1.0,
  });

  final Widget child;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  @override
  State<PulseShimmer> createState() => _PulseShimmerState();
}

class _PulseShimmerState extends State<PulseShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
