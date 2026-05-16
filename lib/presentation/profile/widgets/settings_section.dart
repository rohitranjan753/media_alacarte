import 'package:flutter/material.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../shared/widgets/theme_toggle_button.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.settings,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Account Section
          _SettingsCard(
            title: AppTexts.account,
            items: [
              _SettingsItem(
                icon: Icons.person_outline_rounded,
                label: AppTexts.editProfile,
                onTap: () => _showComingSoon(context),
              ),
              _SettingsItem(
                icon: Icons.lock_outline_rounded,
                label: AppTexts.changePassword,
                onTap: () => _showComingSoon(context),
              ),
              _SettingsItem(
                icon: Icons.business_outlined,
                label: AppTexts.organization,
                subtitle: AppTexts.organizationName,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Preferences Section
          _SettingsCard(
            title: AppTexts.preferences,
            items: [
              _SettingsItem(
                icon: Icons.notifications_outlined,
                label: AppTexts.notifications,
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                onTap: null,
              ),
              _SettingsItem(
                icon: Icons.language_rounded,
                label: AppTexts.language,
                subtitle: AppTexts.languageEnglish,
                onTap: () => _showComingSoon(context),
              ),
              const _ThemeSettingsItem(),
            ],
          ),
          const SizedBox(height: 12),

          // Support Section
          _SettingsCard(
            title: AppTexts.support,
            items: [
              _SettingsItem(
                icon: Icons.help_outline_rounded,
                label: AppTexts.helpCenter,
                onTap: () => _showComingSoon(context),
              ),
              _SettingsItem(
                icon: Icons.bug_report_outlined,
                label: AppTexts.reportBug,
                onTap: () => _showComingSoon(context),
              ),
              _SettingsItem(
                icon: Icons.info_outline_rounded,
                label: AppTexts.about,
                onTap: () => _showAbout(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Legal Section
          _SettingsCard(
            title: AppTexts.legal,
            items: [
              _SettingsItem(
                icon: Icons.policy_outlined,
                label: AppTexts.privacyPolicy,
                onTap: () => _showComingSoon(context),
              ),
              _SettingsItem(
                icon: Icons.description_outlined,
                label: AppTexts.termsOfService,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppTexts.comingSoon),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          AppTexts.about,
          style: TextStyle(color: context.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTexts.appName,
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppTexts.appVersion,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppTexts.appDescription,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppTexts.copyright,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppTexts.close,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// Theme Settings Item with integrated toggle
class _ThemeSettingsItem extends StatelessWidget {
  const _ThemeSettingsItem();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.palette_outlined,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTexts.theme,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                const ThemeToggleButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (index > 0)
                  Divider(
                    color: context.cardBorderColor,
                    height: 1,
                    indent: 52,
                  ),
                item,
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.cardBorderColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: context.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: context.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
