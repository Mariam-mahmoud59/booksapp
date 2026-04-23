import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/story_cover.dart';
import '../providers/story_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StoryProvider>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final favorites = storyProvider.favoriteStories;
    final isLoading = storyProvider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.favorite, size: 32, color: AppColors.accent),
                  SizedBox(width: 12),
                  Text(
                    'Favorites',
                    style: TextStyle(
                      fontSize: 28,
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                )
              else if (favorites.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: AppColors.mutedForeground.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No favorites yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mark stories as favorites to find them here',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: favorites.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final story = favorites[index];
                      return GestureDetector(
                        onTap: () async {
                          await context.push('/app/story/${story.id}');
                          if (mounted) {
                            context.read<StoryProvider>().loadFavorites();
                          }
                        },
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
                                      '${story.pageCount} pages',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      story.lastEditedDisplay,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context
                                    .read<StoryProvider>()
                                    .toggleFavorite(story.id),
                                child: const Icon(
                                  Icons.favorite,
                                  color: AppColors.accent,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
