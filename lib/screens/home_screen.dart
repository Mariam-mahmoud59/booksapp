import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/story_cover.dart';
import '../providers/story_provider.dart';
import '../models/story.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _tipFadeController;
  late Animation<double> _tipFadeAnimation;
  int _currentTipIndex = 0;

  static const List<String> _writingTips = [
    '"The first draft of anything is garbage." — Ernest Hemingway\n\nStart writing without editing. Let your ideas flow freely.',
    '"You can always edit a bad page. You can\'t edit a blank page." — Jodi Picoult\n\nDon\'t wait for perfection — just begin.',
    '"Start writing, no matter what. The water does not flow until the faucet is turned on." — Louis L\'Amour\n\nOpen your story and type the first sentence.',
    '"There is no greater agony than bearing an untold story inside you." — Maya Angelou\n\nYour story deserves to be told.',
    '"A writer is someone for whom writing is more difficult than it is for other people." — Thomas Mann\n\nStruggling is part of the process.',
  ];

  @override
  void initState() {
    super.initState();
    // Ensure stories are loaded when screen is shown
    Future.microtask(() {
      if (mounted) {
        context.read<StoryProvider>().loadStories();
      }
    });

    _currentTipIndex = Random().nextInt(_writingTips.length);

    _tipFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _tipFadeAnimation = CurvedAnimation(
      parent: _tipFadeController,
      curve: Curves.easeIn,
    );
    _tipFadeController.forward();
  }

  @override
  void dispose() {
    _tipFadeController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _cycleTip() {
    _tipFadeController.reverse().then((_) {
      setState(() {
        _currentTipIndex = (_currentTipIndex + 1) % _writingTips.length;
      });
      _tipFadeController.forward();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<StoryProvider>().triggerSync();
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final recentStories = storyProvider.recentStories;
    final isLoading = storyProvider.isLoading;
    final error = storyProvider.error;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.accent,
      backgroundColor: AppColors.card,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Greeting ──
            Text(
              _getGreeting(),
              style: TextStyle(
                fontSize: 28,
                color: AppColors.foreground,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ready to write your story?',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 32),

            // ── Create New Story Banner ──
            GestureDetector(
              onTap: () => context.go('/app/create'),
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, AppColors.primary],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(200, 162, 124, 0.3),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 0.2),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.add, size: 32, color: Colors.white),
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
            // ── Suggested Stories Section ──
            Row(
              children: [
                Icon(Icons.explore_outlined,
                    size: 20, color: AppColors.mutedForeground),
                const SizedBox(width: 8),
                Text(
                  'Suggested For You',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _SuggestedStoryCard(
                    title: 'The Silent Echo',
                    author: 'By Elena Vance',
                    colors: [AppColors.cover1Start, AppColors.cover1End],
                    rating: '4.8',
                  ),
                  const SizedBox(width: 16),
                  _SuggestedStoryCard(
                    title: 'Midnight in Paris',
                    author: 'By Julian Frost',
                    colors: [AppColors.cover2Start, AppColors.cover2End],
                    rating: '4.6',
                  ),
                  const SizedBox(width: 16),
                  _SuggestedStoryCard(
                    title: 'Whispers of the Wind',
                    author: 'By Sarah Lin',
                    colors: [AppColors.cover3Start, AppColors.cover3End],
                    rating: '4.9',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Continue Writing Section ──
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 20, color: AppColors.mutedForeground),
                const SizedBox(width: 8),
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

            // ── Error State ──
            if (error != null)
              _ErrorBanner(
                message: error,
                onRetry: () {
                  storyProvider.clearError();
                  storyProvider.loadStories();
                },
              )
            // ── Loading State ──
            else if (isLoading)
              const _LoadingShimmer()
            // ── Empty State ──
            else if (recentStories.isEmpty)
              const _EmptyState()
            // ── Story Cards ──
            else
              ...recentStories.asMap().entries.map((entry) {
                final index = entry.key;
                final story = entry.value;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 150)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StoryCard(story: story),
                  ),
                );
              }),

            const SizedBox(height: 24),

            // ── Writing Tips Section ──
            GestureDetector(
              onTap: _cycleTip,
              child: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      size: 20, color: AppColors.mutedForeground),
                  const SizedBox(width: 8),
                  Text(
                    'Writing Tips',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.foreground,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.refresh,
                      size: 16, color: AppColors.mutedForeground),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _tipFadeAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(232, 220, 203, 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _writingTips[_currentTipIndex],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.foreground,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────── Story Card Widget ───────────────────

class _StoryCard extends StatelessWidget {
  final Story story;

  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await context.push('/app/story/${story.id}');
        if (context.mounted) {
          context.read<StoryProvider>().loadStories();
        }
      },
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
            Column(
              children: [
                if (story.isFavorite)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Icon(
                      Icons.favorite,
                      color: AppColors.accent,
                      size: 16,
                    ),
                  ),
                if (!story.isSynced)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────── Error Banner ───────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(212, 24, 61, 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromRGBO(212, 24, 61, 0.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 32, color: Color(0xFFD4183D)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFD4183D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD4183D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Loading Shimmer ───────────────────

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(2, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 96,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(232, 220, 203, 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(200, 162, 124, 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 140,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(200, 162, 124, 0.3),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(200, 162, 124, 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────── Empty State ───────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(232, 220, 203, 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 56,
            color: AppColors.mutedForeground.withValues(alpha: 102),
          ),
          const SizedBox(height: 16),
          Text(
            'No stories yet',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Create New Story" above to begin your first masterpiece!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SuggestedStoryCard extends StatelessWidget {
  final String title;
  final String author;
  final List<Color> colors;
  final String rating;

  const _SuggestedStoryCard({
    required this.title,
    required this.author,
    required this.colors,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            child: Center(
              child: Icon(Icons.auto_stories_rounded,
                  color: Colors.white.withValues(alpha: 0.5), size: 32),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foreground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    author,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Color(0xFFFFC107)),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
