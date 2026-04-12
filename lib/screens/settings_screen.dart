import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSync = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/app/profile'),
                    child: const Icon(Icons.chevron_left,
                        size: 28, color: AppColors.foreground),
                  ),
                  const SizedBox(width: 16),
                  const Text(
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
                    _SectionLabel('APPEARANCE'),
                    const SizedBox(height: 12),
                    _SettingRow(
                      icon: Icons.dark_mode_outlined,
                      label: 'Theme',
                      trailing: const _TrailingText('Light'),
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _SettingRow(
                      icon: Icons.text_fields,
                      label: 'Font Size',
                      trailing: const _TrailingText('Medium'),
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('SYNC'),
                    const SizedBox(height: 12),
                    _SettingToggle(
                      icon: Icons.sync,
                      label: 'Auto Sync',
                      value: _autoSync,
                      onChanged: (v) => setState(() => _autoSync = v),
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('ACCOUNT'),
                    const SizedBox(height: 12),
                    _SettingRow(
                      icon: Icons.person_outline,
                      label: 'Edit Profile',
                      onTap: () {},
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
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('OTHER'),
                    const SizedBox(height: 12),
                    _SettingRow(
                      icon: Icons.info_outline,
                      label: 'About',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _SettingRow(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/welcome'),
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
      style: const TextStyle(
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
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.foreground,
                ),
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right,
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
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.foreground,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
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
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right,
            size: 20, color: AppColors.mutedForeground),
      ],
    );
  }
}
