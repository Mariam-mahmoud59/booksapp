import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/story.dart';
import '../repositories/story_repository.dart';

class ReadingModeScreen extends StatefulWidget {
  final String storyId;

  const ReadingModeScreen({super.key, required this.storyId});

  @override
  State<ReadingModeScreen> createState() => _ReadingModeScreenState();
}

class _ReadingModeScreenState extends State<ReadingModeScreen> {
  final StoryRepository _repo = StoryRepository();
  int _currentPage = 0;
  final _pageController = PageController();
  List<StoryPage> _pages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPages() async {
    final pages = await _repo.getStoryPages(widget.storyId);
    if (mounted) {
      setState(() {
        _pages = pages;
        _isLoading = false;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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

    if (_pages.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No pages to display',
                  style: TextStyle(color: AppColors.mutedForeground)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    context.go('/app/story/${widget.storyId}'),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Color(0xFFEDE0CE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          context.go('/app/story/${widget.storyId}'),
                      icon: const Icon(Icons.chevron_left,
                          size: 28, color: AppColors.foreground),
                    ),
                    const Spacer(),
                    Text(
                      'Page ${_currentPage + 1} of ${_pages.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) =>
                      setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (page.title != null &&
                                page.title!.isNotEmpty) ...[
                              Text(
                                page.title!,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: AppColors.foreground,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Text(
                              page.content.isEmpty
                                  ? '(Empty page)'
                                  : page.content,
                              style: TextStyle(
                                fontSize: 20,
                                color: page.content.isEmpty
                                    ? AppColors.mutedForeground
                                    : AppColors.foreground,
                                height: 1.7,
                                fontStyle: page.content.isEmpty
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _prevPage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _currentPage > 0
                              ? AppColors.card
                              : AppColors.secondary.withOpacity(0.3),
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
                    Row(
                      children: List.generate(_pages.length, (i) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _currentPage
                                ? AppColors.accent
                                : AppColors.muted,
                          ),
                        );
                      }),
                    ),
                    GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _currentPage < _pages.length - 1
                              ? AppColors.accent
                              : AppColors.secondary.withOpacity(0.3),
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
