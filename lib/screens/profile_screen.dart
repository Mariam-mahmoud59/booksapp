import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/profile.dart';
import '../repositories/story_repository.dart';
import '../services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StoryRepository _repo = StoryRepository();
  Profile? _profile;
  int _storyCount = 0;
  int _wordCount = 0;
  int _favoriteCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _repo.getProfile();
    final storyCount = await _repo.getStoryCount();
    final wordCount = await _repo.getTotalWordCount();
    final favCount = await _repo.getFavoriteCount();

    if (mounted) {
      setState(() {
        _profile = profile;
        _storyCount = storyCount;
        _wordCount = wordCount;
        _favoriteCount = favCount;
        _isLoading = false;
      });
    }
  }

  String _formatWordCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
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

    final username = _profile?.username ?? 'Writer';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'W';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 28,
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.go('/app/settings'),
                    icon: const Icon(Icons.settings_outlined,
                        size: 24, color: AppColors.foreground),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.accent, AppColors.primary],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 22,
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      SupabaseService().isAuthenticated
                          ? 'Synced ✓'
                          : 'Offline Mode',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _StatCard(
                    icon: Icons.menu_book_outlined,
                    value: '$_storyCount',
                    label: 'Stories',
                  ),
                  _StatCard(
                    icon: Icons.favorite_outlined,
                    value: '$_favoriteCount',
                    label: 'Favorites',
                  ),
                  _StatCard(
                    icon: Icons.trending_up,
                    value: _formatWordCount(_wordCount),
                    label: 'Words Written',
                  ),
                  _StatCard(
                    icon: Icons.cloud_done_outlined,
                    value: SupabaseService().isAuthenticated
                        ? 'Active'
                        : 'Off',
                    label: 'Sync Status',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              if (!SupabaseService().isAuthenticated)
                _ActionItem(
                  icon: Icons.login,
                  title: 'Sign In',
                  subtitle: 'Enable cloud sync',
                  color: AppColors.accent,
                  onTap: () => context.go('/login'),
                )
              else
                _ActionItem(
                  icon: Icons.sync,
                  title: 'Sync Now',
                  subtitle: 'Push & pull latest changes',
                  color: AppColors.accent,
                  onTap: () async {
                    await _repo.triggerSync();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sync triggered'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: AppColors.accent),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              color: AppColors.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
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

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
