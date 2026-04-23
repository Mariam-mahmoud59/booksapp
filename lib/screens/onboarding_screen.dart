import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });
}

const _slides = [
  OnboardingSlide(
    icon: Icons.menu_book_outlined,
    title: 'Create Your Own Stories',
    description: 'Write and craft unique stories at your own pace, page by page',
  ),
  OnboardingSlide(
    icon: Icons.image_outlined,
    title: 'Add Text & Images',
    description: 'Bring your stories to life with beautiful images and rich text',
  ),
  OnboardingSlide(
    icon: Icons.sync_rounded,
    title: 'Continue Anytime',
    description:
        'Your stories sync automatically so you can pick up where you left off',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _currentSlide = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentSlide < _slides.length - 1) {
      setState(() => _currentSlide++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/welcome'),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentSlide = i),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        key: ValueKey(index),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              slide.icon,
                              size: 64,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 48),
                          Text(
                            slide.title,
                            style: const TextStyle(
                              fontSize: 28,
                              color: AppColors.foreground,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            slide.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.mutedForeground,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final isActive = i == _currentSlide;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 32 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: isActive ? AppColors.accent : AppColors.muted,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _handleNext,
                  icon: const SizedBox.shrink(),
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentSlide < _slides.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
