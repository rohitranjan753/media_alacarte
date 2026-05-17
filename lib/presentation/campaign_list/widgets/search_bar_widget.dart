import 'package:flutter/material.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';

/// A search bar widget for filtering campaigns by name.
///
/// Features:
/// - Search icon on the left
/// - Text input field with hint text
/// - Optional filter button on the right
/// - Themed styling matching the app's design system
///
/// The search is performed as the user types, with each character
/// change triggering the [onSearchChanged] callback.
class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    this.onFilterTap,
  });

  /// Callback invoked when the search text changes.
  /// Receives the current search query as a parameter.
  final ValueChanged<String> onSearchChanged;

  /// Optional callback for the filter button tap.
  /// If null, the filter button is not displayed.
  final VoidCallback? onFilterTap;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: context.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: AppTexts.searchCampaigns,
                hintStyle: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onSearchChanged,
            ),
          ),
          if (widget.onFilterTap != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: widget.onFilterTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.cardBorderColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: context.textSecondary,
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
