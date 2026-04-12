import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/story.dart';
import '../widgets/story_cover.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final recentStories = mockStories.take(2).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            _getGreeting(),
            style: const TextStyle(
              fontSize: 28,
              color: AppColors.foreground,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ready to write your story?',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.go('/app/create'),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accent, AppColors.primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Create New Story',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: const [
              Icon(Icons.access_time, size: 20, color: AppColors.mutedForeground),
              SizedBox(width: 8),
              Text(
                'Continue Writing',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recentStories.asMap().entries.map((entry) {
            final story = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => context.go('/app/story/${story.id}'),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      StoryCover(colors: story.coverColors),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.title,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${story.pages} pages',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              story.lastEdited,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          Row(
            children: const [
              Icon(Icons.auto_awesome, size: 20, color: AppColors.mutedForeground),
              SizedBox(width: 8),
              Text(
                'Writing Tips',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '"The first draft of anything is garbage." — Ernest Hemingway\n\nStart writing without editing. Let your ideas flow freely.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.foreground,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
