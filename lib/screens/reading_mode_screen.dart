import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/story.dart';
import '../providers/story_provider.dart';

class ReadingModeScreen extends StatefulWidget {
  final String storyId;

  const ReadingModeScreen({super.key, required this.storyId});

  @override
  State<ReadingModeScreen> createState() => _ReadingModeScreenState();
}

class _ReadingModeScreenState extends State<ReadingModeScreen> {
  int _currentPage = 0;
  final _pageController = PageController();
  List<StoryPage> _pages = [];
  bool _isLoading = true;
  Story? _story;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final provider = context.read<StoryProvider>();
      final story = await provider.getStory(widget.storyId);
      final pages = await provider.getStoryPages(widget.storyId);
      if (mounted) {
        setState(() {
          _story = story;
          _pages = pages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load story pages';
        });
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  double get _progress =>
      _pages.isEmpty ? 0 : (_currentPage + 1) / _pages.length;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: AppColors.mutedForeground),
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: AppColors.mutedForeground)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => context.go('/app/story/${widget.storyId}'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pages.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article_outlined,
                  size: 48, color: AppColors.mutedForeground),
              const SizedBox(height: 16),
              Text('No pages to display',
                  style: TextStyle(color: AppColors.mutedForeground)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => context.go('/app/story/${widget.storyId}'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Color(0xFFEDE0CE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── Reading Progress Bar ───
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 3,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(AppColors.accent),
                  );
                },
              ),

              // ─── Header ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          context.go('/app/story/${widget.storyId}'),
                      icon: Icon(Icons.chevron_left,
                          size: 28, color: AppColors.foreground),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_story != null)
                            Text(
                              _story!.title,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.foreground,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            'Page ${_currentPage + 1} of ${_pages.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit shortcut
                    IconButton(
                      onPressed: () =>
                          context.go('/app/story/${widget.storyId}/edit'),
                      icon: Icon(Icons.edit_outlined,
                          size: 20, color: AppColors.mutedForeground),
                      tooltip: 'Edit Story',
                    ),
                  ],
                ),
              ),

              // ─── Page Content ───
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return _ReadingPageView(
                      page: page,
                      pageIndex: index,
                    );
                  },
                ),
              ),

              // ─── Bottom Navigation ───
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous
                    GestureDetector(
                      onTap: _prevPage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _currentPage > 0
                              ? AppColors.card
                              : AppColors.secondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          size: 24,
                          color: _currentPage > 0
                              ? AppColors.foreground
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ),

                    // Page indicator (compact text instead of dots)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '${_currentPage + 1} / ${_pages.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Next
                    GestureDetector(
                      onTap: _nextPage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _currentPage < _pages.length - 1
                              ? AppColors.accent
                              : AppColors.secondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          size: 24,
                          color: _currentPage < _pages.length - 1
                              ? Colors.white
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual reading page with enhanced typography.
class _ReadingPageView extends StatelessWidget {
  final StoryPage page;
  final int pageIndex;

  const _ReadingPageView({required this.page, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    final content = page.content.trim();
    final isEmpty = content.isEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page title
          if (page.title != null && page.title!.isNotEmpty) ...[
            Text(
              page.title!,
              style: TextStyle(
                fontSize: 24,
                color: AppColors.foreground,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Content with drop cap for first page
          if (isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(
                child: Text(
                  '(Empty page)',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.mutedForeground,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else if (pageIndex == 0 && content.length > 1)
            _buildDropCapContent(content)
          else
            Text(
              content,
              style: TextStyle(
                fontSize: 19,
                color: AppColors.foreground,
                height: 1.8,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.left,
            ),
        ],
      ),
    );
  }

  /// Builds first-page content with a decorative initial letter.
  Widget _buildDropCapContent(String content) {
    if (content.isEmpty) return const SizedBox.shrink();

    final firstChar = content[0];
    final rest = content.substring(1);

    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 19,
          color: AppColors.foreground,
          height: 1.8,
          letterSpacing: 0.1,
        ),
        children: [
          TextSpan(
            text: firstChar,
            style: TextStyle(
              fontSize: 34,
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: rest),
        ],
      ),
      textAlign: TextAlign.left,
    );
  }
}
