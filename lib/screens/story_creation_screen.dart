import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/story.dart';
import '../providers/story_provider.dart';

class StoryCreationScreen extends StatefulWidget {
  const StoryCreationScreen({super.key});

  @override
  State<StoryCreationScreen> createState() => _StoryCreationScreenState();
}

class _StoryCreationScreenState extends State<StoryCreationScreen>
    with SingleTickerProviderStateMixin {
  StoryProvider get _provider => context.read<StoryProvider>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late TextEditingController _contentController;
  List<StoryPage> _pages = [];
  String? _activePageId;
  bool _isSyncing = false;
  bool _isCreating = false;
  Story? _createdStory;
  String? _selectedGenre;
  Timer? _debounceTimer;
  int _wordCount = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const List<String> _genres = [
    'Fantasy',
    'Adventure',
    'Romance',
    'Mystery',
    'Sci-Fi',
    'Horror',
  ];

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  StoryPage? get _activePage =>
      _pages.where((p) => p.id == _activePageId).firstOrNull;

  void _updateWordCount() {
    final text = _contentController.text.trim();
    setState(() {
      _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  /// Create the story in SQLite on first content change.
  Future<void> _ensureStoryCreated() async {
    if (_createdStory != null) return;

    setState(() => _isCreating = true);

    final title = _titleController.text.trim();
    _createdStory = await _provider.createStory(title: title.isEmpty ? 'Untitled' : title);

    // Load the auto-created first page
    final pages = await _provider.getStoryPages(_createdStory!.id);
    if (mounted) {
      setState(() {
        _pages = pages;
        _activePageId = pages.isNotEmpty ? pages.first.id : null;
        if (_activePageId != null) {
          _contentController.text = _activePage?.content ?? '';
        }
        _isCreating = false;
      });
    }
  }

  Future<void> _addPage() async {
    await _ensureStoryCreated();
    if (_createdStory == null) return;

    final page = await _provider.addPage(_createdStory!.id);
    setState(() {
      _pages.add(page);
      _activePageId = page.id;
    });
    _contentController.text = '';
  }

  void _onContentChanged(String content) {
    _updateWordCount();
    _ensureStoryCreated();

    // Cancel previous debounce timer
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _saveContent(content);
    });
  }

  Future<void> _saveContent(String content) async {
    final page = _activePage;
    if (page == null) return;

    setState(() => _isSyncing = true);

    try {
      // Debounced save
      await Future.delayed(const Duration(milliseconds: 500));
      if (page.content != content) {
        await _provider.updatePage(page.copyWith(
          content: content,
          updatedAt: DateTime.now(),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save changes'),
            backgroundColor: const Color(0xFFD4183D),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }

    if (mounted) setState(() => _isSyncing = false);
  }

  Future<void> _updateTitle() async {
    if (_createdStory == null) return;
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    await _provider.updateStory(_createdStory!.copyWith(title: title));
    _createdStory = _createdStory!.copyWith(title: title);
  }

  Future<void> _updateDescription() async {
    if (_createdStory == null) return;
    final description = _descriptionController.text.trim();
    await _provider.updateStory(_createdStory!.copyWith(description: description));
    _createdStory = _createdStory!.copyWith(description: description);
  }

  Future<void> _updateGenre(String? genre) async {
    setState(() => _selectedGenre = genre);
    if (_createdStory == null) return;
    await _provider.updateStory(_createdStory!.copyWith(genre: genre?.toLowerCase()));
    _createdStory = _createdStory!.copyWith(genre: genre?.toLowerCase());
  }

  Future<void> _deletePage(String pageId) async {
    if (_pages.length > 1) {
      await _provider.deletePage(pageId);
      setState(() {
        _pages.removeWhere((p) => p.id == pageId);
        if (_activePageId == pageId) {
          _activePageId = _pages.first.id;
          _contentController.text = _activePage?.content ?? '';
        }
      });
    }
  }

  Future<void> _handleBack() async {
    // Flush any pending debounce
    _debounceTimer?.cancel();
    final page = _activePage;
    if (page != null && _contentController.text != page.content) {
      await _saveContent(_contentController.text);
    }
    if (_createdStory != null) {
      await _updateTitle();
      await _updateDescription();
    }
    if (mounted) context.go('/app');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ───
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.card,
                border:
                    Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _handleBack,
                    icon: const Icon(Icons.chevron_left,
                        size: 28, color: AppColors.foreground),
                    padding: EdgeInsets.zero,
                  ),
                  const Spacer(),
                  _SyncIndicator(isSyncing: _isSyncing),
                ],
              ),
            ),

            // ─── Content ───
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextField(
                        controller: _titleController,
                        onChanged: (_) {
                          if (_createdStory == null) _ensureStoryCreated();
                        },
                        onEditingComplete: _updateTitle,
                        style: const TextStyle(
                          fontSize: 28,
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Story Title',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          hintStyle: TextStyle(
                            fontSize: 28,
                            color: AppColors.mutedForeground,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Description
                      TextField(
                        controller: _descriptionController,
                        onEditingComplete: _updateDescription,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedForeground,
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Add a brief description...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: AppColors.muted,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Genre Picker
                      const Text(
                        'GENRE',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedForeground,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _genres.map((genre) {
                          final isSelected =
                              _selectedGenre == genre;
                          final colors = Story(
                            id: '',
                            userId: '',
                            title: '',
                            genre: genre.toLowerCase(),
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ).coverColors;
                          return GestureDetector(
                            onTap: () => _updateGenre(
                                isSelected ? null : genre),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: colors)
                                    : null,
                                color: isSelected
                                    ? null
                                    : AppColors.card,
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? colors.first
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                          colors: colors),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    genre,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.foreground,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Pages Label
                      Row(
                        children: [
                          const Text(
                            'PAGES',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedForeground,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (_wordCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_wordCount ${_wordCount == 1 ? 'word' : 'words'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Page Tabs
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _pages.length + 1,
                          itemBuilder: (context, i) {
                            if (i == _pages.length) {
                              return GestureDetector(
                                onTap: _addPage,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  margin:
                                      const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 20,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              );
                            }
                            final page = _pages[i];
                            final isActive = page.id == _activePageId;
                            return GestureDetector(
                              onTap: () {
                                // Save current page before switching
                                _debounceTimer?.cancel();
                                final currentPage = _activePage;
                                if (currentPage != null) {
                                  _saveContent(
                                      _contentController.text);
                                }
                                setState(
                                    () => _activePageId = page.id);
                                _contentController.text =
                                    page.content;
                                _updateWordCount();
                              },
                              onLongPress: _pages.length > 1
                                  ? () => _showDeletePageDialog(
                                      page.id, i + 1)
                                  : null,
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                width: 40,
                                height: 40,
                                margin:
                                    const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.accent
                                      : AppColors.card,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isActive
                                        ? AppColors.accent
                                        : AppColors.border,
                                  ),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: AppColors.accent
                                                .withValues(
                                                    alpha: 0.3),
                                            blurRadius: 8,
                                            offset:
                                                const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isActive
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isActive
                                          ? Colors.white
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Content Editor
                      if (_isCreating)
                        Container(
                          constraints:
                              const BoxConstraints(minHeight: 300),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                    AppColors.accent),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          constraints:
                              const BoxConstraints(minHeight: 300),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: AppColors.border),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _contentController,
                            onChanged: _onContentChanged,
                            maxLines: null,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.foreground,
                              height: 1.7,
                            ),
                            decoration: const InputDecoration(
                              hintText:
                                  'Start writing your story...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              hintStyle: TextStyle(
                                color: AppColors.mutedForeground,
                                height: 1.7,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeletePageDialog(String pageId, int pageNumber) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Page $pageNumber?',
            style: const TextStyle(color: AppColors.foreground)),
        content: const Text('This action cannot be undone.',
            style: TextStyle(color: AppColors.mutedForeground)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.mutedForeground)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deletePage(pageId);
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

class _SyncIndicator extends StatelessWidget {
  final bool isSyncing;
  const _SyncIndicator({required this.isSyncing});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isSyncing
          ? Row(
              key: const ValueKey('syncing'),
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation(AppColors.accent.withValues(alpha: 0.7)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Saving...',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.mutedForeground),
                ),
              ],
            )
          : const Row(
              key: ValueKey('saved'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 16, color: AppColors.accent),
                SizedBox(width: 6),
                Text(
                  'Saved',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.mutedForeground),
                ),
              ],
            ),
    );
  }
}
