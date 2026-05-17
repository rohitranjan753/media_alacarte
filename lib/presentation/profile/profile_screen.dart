import 'package:flutter/material.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_texts.dart';
import 'widgets/profile_header.dart';
import 'widgets/stats_cards.dart';
import 'widgets/settings_section.dart';
import 'widgets/logout_button.dart';

/// Displays user profile information and app settings.
///
/// The screen is organized into sections:
///
/// 1. **Profile Header**:
///    - User avatar with verified badge
///    - Name and email
///    - Role badge
///    - Quick action buttons (Message, Share, QR Code)
///
/// 2. **Performance Stats**:
///    - Four KPI cards showing campaigns, spend, impressions, and CTR
///    - Color-coded icons for visual distinction
///
/// 3. **Settings Sections**:
///    - Account: Edit profile, change password, organization
///    - Preferences: Notifications toggle, language, theme switcher
///    - Support: Help center, report bug, about dialog
///    - Legal: Privacy policy, terms of service
///
/// 4. **Actions**:
///    - Logout button with confirmation dialog
///    - Version info at bottom
///
/// Most settings are placeholders showing "Coming Soon" snackbars,
/// except for the theme toggle which is fully functional.
///
/// Route: `/profile`
/// Navigation: Accessible via bottom navigation bar
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              AppTexts.profile,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit_outlined),
                color: AppColors.primary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppTexts.editProfileComingSoon),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),

          // Profile Header
          const SliverToBoxAdapter(
            child: ProfileHeader(),
          ),

          // Stats Cards
          const SliverToBoxAdapter(
            child: StatsCards(),
          ),

          // Settings Sections
          const SliverToBoxAdapter(
            child: SettingsSection(),
          ),

          // Logout Button
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: LogoutButton(),
            ),
          ),

          // Version Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      AppTexts.appName,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppTexts.appVersionWithTech,
                      style: TextStyle(
                        color: context.textSecondary.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
