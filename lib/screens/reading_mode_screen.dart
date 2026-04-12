import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

const _mockPages = [
  'Once upon a time, in a small village nestled between rolling hills, there was a garden that nobody knew about. It was hidden behind an old stone wall, covered in ivy and forgotten by time...',
  'One day, a curious young girl named Luna discovered a small gap in the wall. Intrigued, she squeezed through and found herself in the most beautiful garden she had ever seen.',
  'Flowers of every color bloomed in wild abundance. Ancient trees stretched their branches toward the sky, creating a canopy of dappled light. In the center, a crystal-clear fountain bubbled softly.',
];

class ReadingModeScreen extends StatefulWidget {
  final String storyId;

  const ReadingModeScreen({super.key, required this.storyId});

  @override
  State<ReadingModeScreen> createState() => _ReadingModeScreenState();
}

class _ReadingModeScreenState extends State<ReadingModeScreen> {
  int _currentPage = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _mockPages.length - 1) {
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      'Page ${_currentPage + 1} of ${_mockPages.length}',
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
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _mockPages.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 24),
                        child: Text(
                          _mockPages[index],
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.foreground,
                            height: 1.7,
                          ),
                          textAlign: TextAlign.left,
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
                      children: List.generate(_mockPages.length, (i) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
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
                          color: _currentPage < _mockPages.length - 1
                              ? AppColors.accent
                              : AppColors.secondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          size: 24,
                          color: _currentPage < _mockPages.length - 1
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
