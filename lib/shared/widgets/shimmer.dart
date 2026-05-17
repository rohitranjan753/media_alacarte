import 'package:flutter/material.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/constants/app_colors.dart';

/// Base shimmer widget that creates a sweeping shimmer animation effect.
///
/// This widget applies a diagonal shimmer effect (flash animation) that moves
/// from left to right across its child widget, creating a polished loading state.
/// The animation uses a linear gradient with multiple color stops to create
/// a smooth, visible shimmer sweep.
///
/// **Usage:**
/// ```dart
/// // Wrap any widget with shimmer
/// Shimmer(
///   child: Container(
///     width: 200,
///     height: 100,
///     color: Colors.grey,
///   ),
/// )
///
/// // Custom duration and colors
/// Shimmer(
///   duration: Duration(seconds: 2),
///   baseColor: Colors.grey[300]!,
///   highlightColor: Colors.white,
///   child: YourWidget(),
/// )
///
/// // Conditionally enable/disable
/// Shimmer(
///   enabled: isLoading,
///   child: YourWidget(),
/// )
/// ```
///
/// **Animation details:**
/// - Sweeps from left to right diagonally
/// - Repeats infinitely while enabled
/// - Uses `ShaderMask` with `BlendMode.srcATop` for the effect
/// - Gradient moves from -1.0 to 2.0 (off-screen to off-screen)
///
/// **Best practices:**
/// - Use with placeholder UI that matches the shape of real content
/// - Combine with [ShimmerBox], [ShimmerCircle], and [ShimmerLine] for layouts
/// - See `shimmer_layouts.dart` for pre-built screen-specific layouts
///
/// **Where used:**
/// - Campaign List Screen (via [CampaignListShimmer])
/// - Campaign Detail Screen (via [CampaignDetailShimmer])
/// - Spend Summary Screen (via [SpendSummaryShimmer])
/// - Anomaly Alerts Screen (via [AnomalyAlertsShimmer])
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = AppColors.surface,
    this.highlightColor,
    this.enabled = true,
  });

  /// The widget to apply the shimmer effect to.
  ///
  /// This is typically a placeholder layout built with [ShimmerBox],
  /// [ShimmerCircle], and [ShimmerLine] widgets.
  final Widget child;

  /// Duration of one complete shimmer sweep animation.
  ///
  /// Defaults to 1500 milliseconds. Shorter durations create faster animations.
  final Duration duration;

  /// The base color of the shimmer effect.
  ///
  /// This is the "resting" color when the shimmer sweep is not passing over.
  /// Defaults to [AppColors.surface].
  final Color baseColor;

  /// The highlight color of the shimmer sweep.
  ///
  /// If not provided, uses theme-aware secondary text color with 0.15 opacity.
  /// This color is brightened at the center of the sweep for maximum visibility.
  final Color? highlightColor;

  /// Whether the shimmer animation is enabled.
  ///
  /// If false, the child is rendered without any shimmer effect.
  /// Useful for conditionally showing/hiding the loading state.
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
        context.textSecondary.withValues(alpha: 0.15);

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

/// A simple rectangular shimmer placeholder with rounded corners.
///
/// This is the primary building block for constructing shimmer loading layouts.
/// It creates a colored box with configurable dimensions and border radius.
/// Optionally can include a pulsing animation for enhanced visual effect.
///
/// **Usage:**
/// ```dart
/// // Simple box
/// ShimmerBox(
///   width: 100,
///   height: 100,
/// )
///
/// // Full width with custom radius
/// ShimmerBox(
///   width: double.infinity,
///   height: 50,
///   borderRadius: 12,
/// )
///
/// // With pulsing animation
/// ShimmerBox(
///   width: 80,
///   height: 80,
///   borderRadius: 16,
///   withPulse: true,
/// )
/// ```
///
/// **When to use:**
/// - As a placeholder for rectangular content (cards, buttons, images)
/// - Building complex shimmer layouts by combining multiple boxes
/// - Creating progress bars and dividers in loading states
///
/// **Pulse animation:**
/// When [withPulse] is true, the box will scale and fade in/out continuously,
/// creating a "breathing" effect that draws more attention.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.withPulse = false,
  });

  /// Width of the shimmer box.
  ///
  /// If null, the box will try to expand to fill available width.
  final double? width;

  /// Height of the shimmer box.
  ///
  /// If null, the box will try to expand to fill available height.
  final double? height;

  /// Corner radius of the shimmer box.
  ///
  /// Defaults to 8. Use higher values for more rounded corners.
  final double borderRadius;

  /// Whether to add a continuous pulsing/breathing animation.
  ///
  /// If true, the box will scale between 85% and 100% with opacity changes,
  /// creating an attention-grabbing pulsing effect. Defaults to false.
  final bool withPulse;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                context.textSecondary.withValues(alpha: 0.2),
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
