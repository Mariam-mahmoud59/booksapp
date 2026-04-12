import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/story.dart';

class StoryDetailsScreen extends StatelessWidget {
  final String storyId;

  const StoryDetailsScreen({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    final story = mockStories.firstWhere(
      (s) => s.id == storyId,
      orElse: () => mockStories.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 256,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: story.coverColors,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => context.go('/app'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: const TextStyle(
                      fontSize: 28,
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _StatItem(
                        value: '${story.pages}',
                        label: 'Pages',
                      ),
                      _StatItem(
                        value: '${story.wordCount ?? 0}',
                        label: 'Words',
                      ),
                      _StatItem(
                        value: '${story.progress}%',
                        label: 'Complete',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _InfoRow(
                    icon: Icons.access_time,
                    text: 'Last edited ${story.lastEdited}',
                  ),
                  const SizedBox(height: 8),
                  if (story.created != null)
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      text: 'Created ${story.created}',
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.go('/app/story/${story.id}/read'),
                      icon: const Icon(Icons.menu_book_rounded, size: 20),
                      label: const Text('Read Story'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.go('/app/story/${story.id}/edit'),
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text('Edit Story'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'MORE OPTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    icon: Icons.copy_outlined,
                    label: 'Duplicate Story',
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _ActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share Story',
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    label: 'Delete Story',
                    isDestructive: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Story'),
                          content: const Text(
                              'Are you sure you want to delete this story? This cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.go('/app');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFD4183D),
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              color: AppColors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.mutedForeground),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? const Color(0xFFD4183D) : AppColors.foreground;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFD4183D).withOpacity(0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 16, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
