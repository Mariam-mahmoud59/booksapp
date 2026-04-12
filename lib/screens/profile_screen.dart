import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 28,
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.go('/app/settings'),
                    icon: const Icon(Icons.settings_outlined,
                        size: 24, color: AppColors.foreground),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.accent, AppColors.primary],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'L',
                          style: TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Luna Writer',
                      style: TextStyle(
                        fontSize: 22,
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Storyteller & Dreamer',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: const [
                  _StatCard(
                    icon: Icons.menu_book_outlined,
                    value: '24',
                    label: 'Stories',
                  ),
                  _StatCard(
                    icon: Icons.calendar_today_outlined,
                    value: '156',
                    label: 'Days Writing',
                  ),
                  _StatCard(
                    icon: Icons.trending_up,
                    value: '12.4K',
                    label: 'Words Written',
                  ),
                  _StatCard(
                    icon: Icons.emoji_events_outlined,
                    value: '8',
                    label: 'Achievements',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'RECENT ACHIEVEMENTS',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              _AchievementItem(
                icon: Icons.star_rounded,
                title: 'First Story',
                subtitle: 'Completed your first story',
                color: const Color(0xFFFFC107),
              ),
              const SizedBox(height: 8),
              _AchievementItem(
                icon: Icons.local_fire_department,
                title: '7-Day Streak',
                subtitle: 'Wrote every day for a week',
                color: const Color(0xFFFF5722),
              ),
              const SizedBox(height: 8),
              _AchievementItem(
                icon: Icons.auto_awesome,
                title: 'Prolific Writer',
                subtitle: 'Wrote over 10,000 words',
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: AppColors.accent),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              color: AppColors.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _AchievementItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
