import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/story.dart';
import '../widgets/story_cover.dart';
import '../providers/story_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Story> _localFavorites = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadFavorites());
  }

  Future<void> _loadFavorites() async {
    await context.read<StoryProvider>().loadFavorites();
    if (mounted) {
      setState(() {
        _localFavorites =
            List.from(context.read<StoryProvider>().favoriteStories);
      });
    }
  }

  Future<void> _onRefresh() async {
    await context.read<StoryProvider>().triggerSync();
    if (mounted) {
      setState(() {
        _localFavorites =
            List.from(context.read<StoryProvider>().favoriteStories);
      });
    }
  }

  void _unfavoriteWithUndo(int index, Story story) {
    // Remove from local list with animation
    setState(() {
      _localFavorites.removeAt(index);
    });

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(story, animation),
      duration: const Duration(milliseconds: 350),
    );

    // Toggle in provider
    context.read<StoryProvider>().toggleFavorite(story.id);

    // Show undo snackbar
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${story.title}" removed from favorites',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.secondary,
          onPressed: () async {
            // Re-favorite
            await context.read<StoryProvider>().toggleFavorite(story.id);
            _loadFavorites();
          },
        ),
      ),
    );
  }

  Widget _buildRemovedItem(Story story, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FavoriteCard(
            story: story,
            onUnfavorite: () {},
            onTap: () {},
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final isLoading = storyProvider.isLoadingFavorites;
    final error = storyProvider.error;

    // Sync local list with provider data when not animating
    if (!isLoading &&
        _localFavorites.isEmpty &&
        storyProvider.favoriteStories.isNotEmpty) {
      _localFavorites = List.from(storyProvider.favoriteStories);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.accent,
          backgroundColor: AppColors.card,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Icon(Icons.favorite, size: 32, color: AppColors.accent),
                    const SizedBox(width: 12),
                    Text(
                      'Favorites',
                      style: TextStyle(
                        fontSize: 28,
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_localFavorites.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(200, 162, 124, 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_localFavorites.length}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Error State ──
                if (error != null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Color(0xFFD4183D)),
                          const SizedBox(height: 16),
                          Text(
                            error,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.mutedForeground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              storyProvider.clearError();
                              _loadFavorites();
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 44),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

                // ── Loading State ──
                else if (isLoading)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.accent),
                      ),
                    ),
                  )

                // ── Empty State ──
                else if (_localFavorites.isEmpty)
                  Expanded(
                    child: ListView(
                      // ListView enables pull-to-refresh when empty
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.8, end: 1.0),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                      scale: value, child: child);
                                },
                                child: Icon(
                                  Icons.favorite_border,
                                  size: 72,
                                  color: AppColors.mutedForeground
                                      .withValues(alpha: 102),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No favorites yet',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: AppColors.mutedForeground,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  'Tap the heart icon on any story to save it here for quick access',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.mutedForeground,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )

                // ── Favorites List ──
                else
                  Expanded(
                    child: AnimatedList(
                      key: _listKey,
                      initialItemCount: _localFavorites.length,
                      itemBuilder: (context, index, animation) {
                        if (index >= _localFavorites.length) {
                          return const SizedBox.shrink();
                        }
                        final story = _localFavorites[index];
                        return SizeTransition(
                          sizeFactor: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _FavoriteCard(
                                story: story,
                                onUnfavorite: () =>
                                    _unfavoriteWithUndo(index, story),
                                onTap: () async {
                                  await context.push('/app/story/${story.id}');
                                  if (mounted) _loadFavorites();
                                },
                              ),
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
      ),
    );
  }
}

// ─────────────────── Favorite Card ───────────────────

class _FavoriteCard extends StatelessWidget {
  final Story story;
  final VoidCallback onUnfavorite;
  final VoidCallback onTap;

  const _FavoriteCard({
    required this.story,
    required this.onUnfavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(141, 110, 99, 0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            StoryCover(
                colors: story.coverColors, imageUrl: story.coverImageUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${story.pageCount} pages',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        story.lastEditedDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      if (story.genre != null && story.genre!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(200, 162, 124, 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            story.genre!,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onUnfavorite,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(200, 162, 124, 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
