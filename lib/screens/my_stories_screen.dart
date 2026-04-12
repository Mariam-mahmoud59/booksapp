import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/story.dart';
import '../widgets/story_cover.dart';

class MyStoriesScreen extends StatefulWidget {
  const MyStoriesScreen({super.key});

  @override
  State<MyStoriesScreen> createState() => _MyStoriesScreenState();
}

class _MyStoriesScreenState extends State<MyStoriesScreen> {
  bool _isGridView = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Story> get _filteredStories {
    if (_searchQuery.isEmpty) return mockStories;
    return mockStories
        .where((s) =>
            s.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'My Stories',
                      style: TextStyle(
                        fontSize: 28,
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w400,
                      ),
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
              const SizedBox(height: 20),
              TextFormField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.mutedForeground,
                  ),
                  hintText: 'Search stories...',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isGridView
                    ? _GridView(stories: _filteredStories)
                    : _ListView(stories: _filteredStories),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/app/create'),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

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
      child: Container(
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

class _GridView extends StatelessWidget {
  final List<Story> stories;

  const _GridView({required this.stories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        return GestureDetector(
          onTap: () => context.go('/app/story/${story.id}'),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StoryCover(
                    colors: story.coverColors,
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 14,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${story.pages} pages',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: story.progress / 100,
                          backgroundColor: AppColors.secondary,
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.accent),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ListView extends StatelessWidget {
  final List<Story> stories;

  const _ListView({required this.stories});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: stories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final story = stories[index];
        return GestureDetector(
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
                        '${story.pages} pages · ${story.lastEdited}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: story.progress / 100,
                          backgroundColor: AppColors.secondary,
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.accent),
                          minHeight: 4,
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
        );
      },
    );
  }
}
