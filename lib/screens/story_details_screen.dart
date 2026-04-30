import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/story.dart';
import '../providers/story_provider.dart';

class StoryDetailsScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailsScreen({super.key, required this.storyId});

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> {
  Story? _story;
  bool _isLoading = true;
  final bool _isDeleting = false;
  final int _wordCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  Future<void> _loadStory() async {
    final story =
        await context.read<StoryProvider>().getStory(widget.storyId);
    if (mounted) {
      setState(() {
        _story = story;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_story == null) return;
    final newState =
        await context.read<StoryProvider>().toggleFavorite(_story!.id);
    setState(() {
      _story = _story!.copyWith(isFavorite: newState);
    });
  }

  Future<void> _deleteStory() async {
    await context.read<StoryProvider>().deleteStory(widget.storyId);
    if (mounted) context.go('/app');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
      );
    }

    if (_error != null || _story == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.mutedForeground),
              const SizedBox(height: 16),
              Text(_error ?? 'Story not found',
                  style: const TextStyle(color: AppColors.mutedForeground)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => context.go('/app'),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final story = _story!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Cover Gradient Header ───
            Stack(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: story.coverColors,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => context.go('/app'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
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
                // Favorite button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                                scale: animation, child: child),
                        child: Icon(
                          story.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          key: ValueKey(story.isFavorite),
                          color: story.isFavorite
                              ? const Color(0xFFFF6B6B)
                              : Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                // Status badge
                if (story.status.isNotEmpty)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 64,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        story.status[0].toUpperCase() +
                            story.status.substring(1),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ─── Details Section ───
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + sync badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          story.title,
                          style: const TextStyle(
                            fontSize: 28,
                            color: AppColors.foreground,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      if (!story.isSynced)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cloud_off,
                                  size: 14, color: AppColors.accent),
                              SizedBox(width: 4),
                              Text('Offline',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.accent)),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Description
                  if (story.description != null &&
                      story.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      story.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Stats row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _StatItem(
                          value: '${story.pageCount}',
                          label: 'Pages',
                          icon: Icons.description_outlined,
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: AppColors.border,
                        ),
                        _StatItem(
                          value: _wordCount > 999
                              ? '${(_wordCount / 1000).toStringAsFixed(1)}k'
                              : '$_wordCount',
                          label: 'Words',
                          icon: Icons.text_fields,
                        ),
                        if (story.genre != null) ...[
                          Container(
                            width: 1,
                            height: 32,
                            color: AppColors.border,
                          ),
                          _StatItem(
                            value: story.genre!,
                            label: 'Genre',
                            icon: Icons.category_outlined,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info rows
                  _InfoRow(
                    icon: Icons.access_time,
                    text: 'Last edited ${story.lastEditedDisplay}',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text:
                        'Created ${story.createdAt.month}/${story.createdAt.day}/${story.createdAt.year}',
                  ),

                  const SizedBox(height: 32),

                  // Primary actions
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await context
                            .push('/app/story/${story.id}/read');
                        _loadStory();
                      },
                      icon:
                          const Icon(Icons.menu_book_rounded, size: 20),
                      label: const Text('Read Story'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await context
                            .push('/app/story/${story.id}/edit');
                        _loadStory();
                      },
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text('Edit Story'),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // More options
                  const Text(
                    'MORE OPTIONS',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedForeground,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _ActionButton(
                    icon: story.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    label: story.isFavorite
                        ? 'Remove from Favorites'
                        : 'Add to Favorites',
                    onTap: _toggleFavorite,
                  ),
                  const SizedBox(height: 8),
                  _ActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share Story',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Share coming soon!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    label: 'Delete Story',
                    isDestructive: true,
                    isLoading: _isDeleting,
                    onTap: () => _showDeleteDialog(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Story',
            style: TextStyle(color: AppColors.foreground)),
        content: Text(
          'Are you sure you want to delete "${_story?.title}"? This cannot be undone.',
          style: const TextStyle(color: AppColors.mutedForeground, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.mutedForeground)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteStory();
            },
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFFD4183D)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.foreground,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
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
  final bool isLoading;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? const Color(0xFFD4183D) : AppColors.foreground;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFD4183D).withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              )
            else
              Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 16, color: color),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
