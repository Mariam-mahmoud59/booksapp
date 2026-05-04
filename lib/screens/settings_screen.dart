import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/edit_profile_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSync = true;
  bool _notifications = true;

  void _showComingSoon() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('This feature is coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showFontSizePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Font Size',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.foreground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _FontSizeOption(
                label: 'Small',
                isSelected: themeProvider.fontSize == AppFontSize.small,
                onTap: () {
                  themeProvider.setFontSize(AppFontSize.small);
                  Navigator.pop(context);
                },
              ),
              _FontSizeOption(
                label: 'Medium',
                isSelected: themeProvider.fontSize == AppFontSize.medium,
                onTap: () {
                  themeProvider.setFontSize(AppFontSize.medium);
                  Navigator.pop(context);
                },
              ),
              _FontSizeOption(
                label: 'Large',
                isSelected: themeProvider.fontSize == AppFontSize.large,
                onTap: () {
                  themeProvider.setFontSize(AppFontSize.large);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/app/profile'),
                    child: Icon(Icons.chevron_left,
                        size: 28, color: AppColors.foreground),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 22,
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('APPEARANCE'),
                    const SizedBox(height: 12),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return _SettingToggle(
                          icon: Icons.dark_mode_outlined,
                          label: 'Dark Mode',
                          value: themeProvider.isDarkMode,
                          onChanged: (v) => themeProvider.toggleTheme(),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return _SettingRow(
                          icon: Icons.text_fields,
                          label: 'Font Size',
                          trailing: _TrailingText(themeProvider.fontSizeName),
                          onTap: _showFontSizePicker,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel('SYNC'),
                    const SizedBox(height: 12),
                    _SettingToggle(
                      icon: Icons.sync,
                      label: 'Auto Sync',
                      value: _autoSync,
                      onChanged: (v) => setState(() => _autoSync = v),
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel('ACCOUNT'),
                    const SizedBox(height: 12),
                    _SettingRow(
                      icon: Icons.person_outline,
                      label: 'Edit Profile',
                      onTap: () {
                        final authProvider = context.read<AuthProvider>();
                        final username = authProvider.profile?.username ?? 'Writer';
                        EditProfileSheet.show(context, authProvider, username);
                      },
                    ),
                    const SizedBox(height: 8),
                    _SettingToggle(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                    ),
                    const SizedBox(height: 8),
                    _SettingRow(
                      icon: Icons.lock_outline,
                      label: 'Change Password',
                      onTap: () => context.push('/app/settings/password'),
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel('OTHER'),
                    const SizedBox(height: 12),
                    _SettingRow(
                      icon: Icons.info_outline,
                      label: 'About',
                      onTap: () => context.push('/app/settings/about'),
                    ),
                    const SizedBox(height: 8),
                    _SettingRow(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      onTap: () => context.push('/app/settings/privacy'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.card,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              title: Text('Log Out',
                                  style:
                                      TextStyle(color: AppColors.foreground)),
                              content: Text('Are you sure you want to log out?',
                                  style: TextStyle(
                                      color: AppColors.mutedForeground)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          color: AppColors.mutedForeground)),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    await context
                                        .read<AuthProvider>()
                                        .signOut();
                                    if (!context.mounted) return;
                                    context.go('/welcome');
                                  },
                                  style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFFD4183D)),
                                  child: const Text('Log Out'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text('Log Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD4183D),
                          side: const BorderSide(
                              color: Color(0xFFD4183D), width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: AppColors.mutedForeground,
        letterSpacing: 1,
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.foreground,
                ),
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right,
                    size: 20, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.foreground,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _TrailingText extends StatelessWidget {
  final String text;

  const _TrailingText(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right, size: 20, color: AppColors.mutedForeground),
      ],
    );
  }
}

class _FontSizeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontSizeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? AppColors.accent : AppColors.foreground,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.accent, size: 20),
          ],
        ),
      ),
    );
  }
}
