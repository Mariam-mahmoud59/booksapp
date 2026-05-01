import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/story_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    authProvider.loadProfile();
    authProvider.loadStats();

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (mounted) {
        setState(() {
          _isOnline = !results.contains(ConnectivityResult.none);
        });
      }
    });

    Connectivity().checkConnectivity().then((results) {
      if (mounted) {
        setState(() {
          _isOnline = !results.contains(ConnectivityResult.none);
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _editProfile(
      AuthProvider authProvider, String currentName) async {
    final TextEditingController nameController =
        TextEditingController(text: currentName);
    final TextEditingController bioController = TextEditingController(
      text: authProvider.profile?.bio ?? '',
    );
    String? newImagePath;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSheet) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 22,
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              // Avatar picker
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setStateSheet(() => newImagePath = image.path);
                    }
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.border,
                          image: newImagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(newImagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : (authProvider.profile?.avatarUrl != null &&
                                      authProvider
                                          .profile!.avatarUrl!.isNotEmpty)
                                  ? DecorationImage(
                                      image: authProvider
                                              .profile!.avatarUrl!
                                              .startsWith('http')
                                          ? NetworkImage(authProvider
                                              .profile!.avatarUrl!) as ImageProvider
                                          : FileImage(File(
                                              authProvider.profile!.avatarUrl!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: (newImagePath == null &&
                                (authProvider.profile?.avatarUrl == null ||
                                    authProvider.profile!.avatarUrl!.isEmpty))
                            ? Icon(Icons.camera_alt,
                                color: AppColors.mutedForeground, size: 28)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Name field
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: AppColors.mutedForeground),
                  prefixIcon:
                      Icon(Icons.person_outline, color: AppColors.accent),
                ),
              ),
              const SizedBox(height: 16),
              // Bio field
              TextField(
                controller: bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us a bit about yourself...',
                  labelStyle: TextStyle(color: AppColors.mutedForeground),
                  prefixIcon:
                      Icon(Icons.edit_note_outlined, color: AppColors.accent),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await authProvider.updateProfile(
                      username: nameController.text.trim().isNotEmpty
                          ? nameController.text.trim()
                          : currentName,
                      avatarUrl:
                          newImagePath ?? authProvider.profile?.avatarUrl,
                      bio: bioController.text.trim(),
                    );
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatWordCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;

    if (profile == null && authProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
      );
    }

    final username = profile?.username ?? 'Writer';
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
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 28,
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.go('/app/settings'),
                    icon: Icon(Icons.settings_outlined,
                        size: 24, color: AppColors.foreground),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _editProfile(authProvider, username),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: profile?.avatarUrl == null ||
                                      profile!.avatarUrl!.isEmpty
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.accent,
                                        AppColors.primary
                                      ],
                                    )
                                  : null,
                              image: profile?.avatarUrl != null &&
                                      profile!.avatarUrl!.isNotEmpty
                                  ? DecorationImage(
                                      image: profile.avatarUrl!
                                              .startsWith('http')
                                          ? NetworkImage(profile.avatarUrl!)
                                              as ImageProvider
                                          : FileImage(File(profile.avatarUrl!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: profile?.avatarUrl == null ||
                                    profile!.avatarUrl!.isEmpty
                                ? Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        fontSize: 36,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit,
                                size: 16, color: AppColors.accent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 22,
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isOnline
                          ? (authProvider.isAuthenticated
                              ? 'Online & Synced'
                              : 'Online Mode')
                          : 'Offline Mode',
                      style: TextStyle(
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
                childAspectRatio: 0.95,
                children: [
                  _StatCard(
                    icon: Icons.menu_book_outlined,
                    value: '${authProvider.storyCount}',
                    label: 'Stories',
                    onTap: () => context.go('/app/stories'),
                  ),
                  _StatCard(
                    icon: Icons.favorite_outlined,
                    value: '${authProvider.favoriteCount}',
                    label: 'Favorites',
                    onTap: () => context.go('/app/favorites'),
                  ),
                  _StatCard(
                    icon: Icons.trending_up,
                    value: _formatWordCount(authProvider.wordCount),
                    label: 'Words Written',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('You have written ${authProvider.wordCount} words!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  _StatCard(
                    icon: Icons.cloud_done_outlined,
                    value: (_isOnline && authProvider.isAuthenticated)
                        ? 'ON'
                        : 'Off',
                    label: 'Sync Status',
                    onTap: () {
                      if (!authProvider.isAuthenticated) {
                        context.go('/login');
                      } else {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(
                             content: Text('Account is active and syncing'),
                             duration: Duration(seconds: 2),
                           ),
                         );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              if (!authProvider.isAuthenticated)
                _ActionItem(
                  icon: Icons.login,
                  title: 'Sign In',
                  subtitle: 'Enable cloud sync',
                  color: AppColors.accent,
                  onTap: () => context.go('/login'),
                )
              else ...[
                _ActionItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Update your name, photo & bio',
                  color: AppColors.accent,
                  onTap: () => _editProfile(authProvider, username),
                ),
                const SizedBox(height: 12),
                _ActionItem(
                  icon: Icons.sync,
                  title: 'Sync Now',
                  subtitle: 'Push & pull latest changes',
                  color: AppColors.accent,
                  onTap: () async {
                    if (!_isOnline) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Cannot sync while offline')),
                      );
                      return;
                    }
                    await context.read<StoryProvider>().triggerSync();
                    if (!context.mounted) return;
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sync triggered'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    // Refresh stats after sync
                    context.read<AuthProvider>().loadStats();
                  },
                ),
                const SizedBox(height: 12),
                _ActionItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  color: const Color(0xFFD4183D),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.card,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: Text('Logout',
                            style: TextStyle(color: AppColors.foreground)),
                        content: Text('Are you sure you want to log out?',
                            style:
                                TextStyle(color: AppColors.mutedForeground)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: AppColors.mutedForeground)),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await context.read<AuthProvider>().signOut();
                              if (mounted) context.go('/welcome');
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFD4183D)),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
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
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              color: AppColors.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    )));
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
                color: color.withValues(alpha: 0.15),
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
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
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
