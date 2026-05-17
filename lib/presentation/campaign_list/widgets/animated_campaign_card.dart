import 'package:flutter/material.dart';
import '../../../data/models/campaign.dart';
import 'campaign_card.dart';

/// An animated wrapper around [CampaignCard] that provides staggered entry animations.
///
/// Creates a smooth entrance effect for campaign cards in the list with:
/// - Fade-in animation
/// - Slide-up animation
/// - Scale animation with elastic bounce
/// - Staggered timing based on card index for waterfall effect
/// - Hero animation support for smooth transitions to detail screen
///
/// The animations are controlled by an [AnimationController] with delays
/// calculated based on the card's [index] position in the list.
class AnimatedCampaignCard extends StatefulWidget {
  const AnimatedCampaignCard({
    super.key,
    required this.index,
    required this.campaign,
    required this.onTap,
  });

  /// The position of this card in the list, used to stagger animations.
  final int index;

  /// The campaign data to display.
  final Campaign campaign;

  /// Callback invoked when the card is tapped.
  final VoidCallback onTap;

  @override
  State<AnimatedCampaignCard> createState() => _AnimatedCampaignCardState();
}

class _AnimatedCampaignCardState extends State<AnimatedCampaignCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 50)),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    // Delay animation based on index
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
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
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Hero(
            tag: 'campaign_card_${widget.campaign.id}',
            child: Material(
              type: MaterialType.transparency,
              child: CampaignCard(
                campaign: widget.campaign,
                onTap: widget.onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
