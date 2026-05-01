import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/story.dart';
import '../widgets/story_cover.dart';
import '../providers/story_provider.dart';

class MyStoriesScreen extends StatefulWidget {
  const MyStoriesScreen({super.key});

  @override
  State<MyStoriesScreen> createState() => _MyStoriesScreenState();
}

class _MyStoriesScreenState extends State<MyStoriesScreen> {
  bool _isGridView = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<StoryProvider>().loadStories();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context.read<StoryProvider>().searchStories(value);
  }

  Future<void> _onRefresh() async {
    await context.read<StoryProvider>().triggerSync();
  }

  void _confirmDelete(BuildContext context, Story story) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Story',
          style: TextStyle(color: AppColors.foreground),
        ),
        content: Text(
          'Are you sure you want to delete this story?',
          style: TextStyle(color: AppColors.mutedForeground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<StoryProvider>().deleteStory(story.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${story.title}" deleted'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFD4183D)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final stories = storyProvider.filteredStories;
    final isLoading = storyProvider.isLoading;
    final error = storyProvider.error;
    final statusFilter = storyProvider.statusFilter;
    final sortOrder = storyProvider.sortOrder;
    final totalCount = storyProvider.stories.length;

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
              children: [
                // ── Header Row ──
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'My Stories',
                            style: TextStyle(
                              fontSize: 28,
                              color: AppColors.foreground,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (totalCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    const Color.fromRGBO(200, 162, 124, 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$totalCount',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _ViewToggleButton(
                      icon: Icons.grid_view,
                      isActive: _isGridView,
                      onTap: () => setState(() => _isGridView = true),
                    ),
                    const SizedBox(width: 8),
                    _ViewToggleButton(
                      icon: Icons.list,
                      isActive: !_isGridView,
                      onTap: () => setState(() => _isGridView = false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Search Bar ──
                TextFormField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.mutedForeground,
                    ),
                    hintText: 'Search stories...',
                  ),
                ),
                const SizedBox(height: 16),

                // ── Filter Chips ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: statusFilter == 'all',
                        onTap: () => storyProvider.setStatusFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Draft',
                        isSelected: statusFilter == 'draft',
                        onTap: () => storyProvider.setStatusFilter('draft'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Published',
                        isSelected: statusFilter == 'published',
                        onTap: () => storyProvider.setStatusFilter('published'),
                      ),
                      const SizedBox(width: 16),
                      // Sort dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 0),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: sortOrder,
                            icon: Icon(Icons.sort,
                                size: 18, color: AppColors.mutedForeground),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.foreground,
                              fontFamily: 'Georgia',
                            ),
                            dropdownColor: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            items: const [
                              DropdownMenuItem(
                                  value: 'recent', child: Text('Recent')),
                              DropdownMenuItem(
                                  value: 'oldest', child: Text('Oldest')),
                              DropdownMenuItem(
                                  value: 'alpha', child: Text('A–Z')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                storyProvider.setSortOrder(value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Content Area ──
                Expanded(
                  child: error != null
                      ? _ErrorWidget(
                          message: error,
                          onRetry: () {
                            storyProvider.clearError();
                            storyProvider.loadStories();
                          },
                        )
                      : isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(AppColors.accent),
                              ),
                            )
                          : stories.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.menu_book_outlined,
                                        size: 64,
                                        color: AppColors.mutedForeground
                                            .withValues(alpha: 102),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        storyProvider.searchQuery.isNotEmpty
                                            ? 'No stories match your search'
                                            : statusFilter != 'all'
                                                ? 'No $statusFilter stories'
                                                : 'No stories found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: AppColors.mutedForeground,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        storyProvider.searchQuery.isNotEmpty
                                            ? 'Try a different keyword'
                                            : 'Tap + to create your first story',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _isGridView
                                  ? _StoryGridView(
                                      stories: stories,
                                      onDelete: _confirmDelete,
                                    )
                                  : _StoryListView(
                                      stories: stories,
                                      onDelete: _confirmDelete,
                                    ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final provider = context.read<StoryProvider>();
          await context.push('/app/create');
          if (mounted) {
            provider.loadStories();
          }
        },
        backgroundColor: AppColors.accent,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ─────────────────── View Toggle ───────────────────

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.white : AppColors.foreground,
        ),
      ),
    );
  }
}

// ─────────────────── Filter Chip ───────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : AppColors.foreground,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─────────────────── Grid View ───────────────────

class _StoryGridView extends StatelessWidget {
  final List<Story> stories;
  final void Function(BuildContext, Story) onDelete;

  const _StoryGridView({required this.stories, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.9 + (0.1 * value),
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: () async {
              await context.push('/app/story/${story.id}');
              if (context.mounted) {
                context.read<StoryProvider>().loadStories();
              }
            },
            onLongPress: () => onDelete(context, story),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        StoryCover(
                          colors: story.coverColors,
                          imageUrl: story.coverImageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 14,
                        ),
                        // Favorite indicator
                        if (story.isFavorite)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite,
                                color: AppColors.accent,
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.foreground,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '${story.pageCount} pages',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                            if (!story.isSynced) ...[
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        _StatusBadge(status: story.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────── List View ───────────────────

class _StoryListView extends StatelessWidget {
  final List<Story> stories;
  final void Function(BuildContext, Story) onDelete;

  const _StoryListView({required this.stories, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: stories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final story = stories[index];
        return Dismissible(
          key: ValueKey(story.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            onDelete(context, story);
            return false; // Dialog handles the delete
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(212, 24, 61, 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline,
                color: Color(0xFFD4183D), size: 28),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(30 * (1 - value), 0),
                  child: child,
                ),
              );
            },
            child: GestureDetector(
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
                        colors: story.coverColors,
                        imageUrl: story.coverImageUrl),
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
                            '${story.pageCount} pages · ${story.lastEditedDisplay}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _StatusBadge(status: story.status),
                              if (!story.isSynced)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (story.isFavorite)
                                Icon(Icons.favorite,
                                    color: AppColors.accent, size: 14),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context
                          .read<StoryProvider>()
                          .toggleFavorite(story.id),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          story.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: story.isFavorite
                              ? AppColors.accent
                              : AppColors.mutedForeground,
                          size: 20,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────── Status Badge ───────────────────

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPublished = status == 'published';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPublished
            ? const Color.fromRGBO(200, 162, 124, 0.15)
            : const Color.fromRGBO(141, 110, 99, 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          fontSize: 11,
          color: isPublished ? AppColors.accent : AppColors.mutedForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────── Error Widget ───────────────────

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFD4183D)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 44),
            ),
          ),
        ],
      ),
    );
  }
}
