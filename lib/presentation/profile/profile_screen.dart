import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_texts.dart';
import 'widgets/profile_header.dart';
import 'widgets/stats_cards.dart';
import 'widgets/settings_section.dart';
import 'widgets/logout_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: AppColors.surface,
            title: const Text(
              AppTexts.profile,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
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
                    const Text(
                      AppTexts.appName,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppTexts.appVersionWithTech,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
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
