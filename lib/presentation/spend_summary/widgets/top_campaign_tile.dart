import 'package:flutter/material.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/summary.dart';

/// A list tile displaying a top-performing campaign with ranking.
///
/// Shows:
/// - Rank badge (1, 2, 3) in a colored square container
/// - Campaign icon based on name/type
/// - Campaign name and spend amount
/// - CTR percentage with green upward arrow indicator
///
/// Icons are dynamically selected based on campaign name:
/// - Shopping cart for sale campaigns
/// - Gift card for loyalty/premium campaigns
/// - Campaign icon for promotional campaigns
///
/// Tapping the tile navigates to the campaign detail screen.
class TopCampaignTile extends StatelessWidget {
  const TopCampaignTile({
    super.key,
    required this.campaign,
    required this.rank,
    required this.maxCtr,
    this.onTap,
  });

  /// The campaign data to display.
  final TopCampaign campaign;

  /// The rank position (1-3) of this campaign.
  final int rank;

  /// The maximum CTR among all top campaigns (used for relative sizing).
  final double maxCtr;

  /// Optional callback invoked when the tile is tapped.
  final VoidCallback? onTap;

  IconData _getCampaignIcon() {
    final name = campaign.name.toLowerCase();

    if (name.contains('sale') || name.contains('school')) {
      return Icons.shopping_cart_rounded;
    } else if (name.contains('loyalty') || name.contains('premium') || name.contains('member')) {
      return Icons.card_giftcard_rounded;
    } else if (name.contains('ramadan') || name.contains('mega')) {
      return Icons.campaign_rounded;
    }
    return Icons.ads_click_rounded;
  }

  Color _getIconColor() {
    final name = campaign.name.toLowerCase();

    if (name.contains('sale') || name.contains('school')) {
      return const Color(0xFF10B981); // green
    } else if (name.contains('loyalty') || name.contains('premium')) {
      return const Color(0xFFF59E0B); // amber
    } else if (name.contains('ramadan') || name.contains('mega')) {
      return const Color(0xFF3B82F6); // blue
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Campaign Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _getIconColor().withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCampaignIcon(),
                color: _getIconColor(),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            // Campaign Name & Spend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.name,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(campaign.spend),
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // CTR with Arrow
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_upward_rounded,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  formatCTR(campaign.ctr),
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
