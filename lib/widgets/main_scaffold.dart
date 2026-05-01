import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/app') return 0;
    if (location.startsWith('/app/stories')) return 1;
    if (location.startsWith('/app/favorites')) return 3;
    if (location.startsWith('/app/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => context.go('/app'),
                ),
                _NavItem(
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                  label: 'Stories',
                  isActive: currentIndex == 1,
                  onTap: () => context.go('/app/stories'),
                ),
                _NavItem(
                  icon: Icons.edit_outlined,
                  activeIcon: Icons.edit,
                  label: 'Create',
                  isActive: currentIndex == 2,
                  onTap: () => context.go('/app/create'),
                ),
                _NavItem(
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  label: 'Favorites',
                  isActive: currentIndex == 3,
                  onTap: () => context.go('/app/favorites'),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isActive: currentIndex == 4,
                  onTap: () => context.go('/app/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? AppColors.accent : AppColors.mutedForeground,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? AppColors.accent : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
