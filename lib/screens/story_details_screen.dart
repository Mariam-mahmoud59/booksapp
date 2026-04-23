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

    final story = _story;
    if (story == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Story not found',
                  style: TextStyle(color: AppColors.mutedForeground)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/app'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

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
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        story.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.white,
                        size: 22,
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
                            color: AppColors.accent.withOpacity(0.15),
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
                  if (story.description != null &&
                      story.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      story.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _StatItem(
                        value: '${story.pageCount}',
                        label: 'Pages',
                      ),
                      _StatItem(
                        value: story.status,
                        label: 'Status',
                      ),
                      if (story.genre != null)
                        _StatItem(
                          value: story.genre!,
                          label: 'Genre',
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await context
                            .push('/app/story/${story.id}/read');
                        _loadStory();
                      },
                      icon: const Icon(Icons.menu_book_rounded, size: 20),
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
                                _deleteStory();
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
