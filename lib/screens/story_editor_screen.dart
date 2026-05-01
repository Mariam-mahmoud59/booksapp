import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/story.dart';
import '../providers/story_provider.dart';

class StoryEditorScreen extends StatefulWidget {
  final String storyId;

  const StoryEditorScreen({super.key, required this.storyId});

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  StoryProvider get _provider => context.read<StoryProvider>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _descriptionController;
  List<StoryPage> _pages = [];
  String? _activePageId;
  bool _isSyncing = false;
  bool _isLoading = true;
  Story? _story;
  String? _selectedGenre;
  Timer? _debounceTimer;
  int _wordCount = 0;
  bool _showMetaSection = false;

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
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadStory();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }



  Future<void> _loadStory() async {
    try {
      final story = await _provider.getStory(widget.storyId);
      final pages = await _provider.getStoryPages(widget.storyId);

      if (mounted) {
        setState(() {
          _story = story;
          _pages = pages;
          _titleController.text = story?.title ?? '';
          _descriptionController.text = story?.description ?? '';
          _selectedGenre = story?.genre != null
              ? '${story!.genre![0].toUpperCase()}${story.genre!.substring(1)}'
              : null;

          if (pages.isNotEmpty) {
            _activePageId = pages.first.id;
            _contentController.text = pages.first.content;
            _updateWordCount();
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load story: $e'),
            backgroundColor: const Color(0xFFD4183D),
          ),
        );
      }
    }
  }

  StoryPage? get _activePage =>
      _pages.where((p) => p.id == _activePageId).firstOrNull;

  void _updateWordCount() {
    final text = _contentController.text.trim();
    setState(() {
      _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  Future<void> _addPage() async {
    try {
      final page = await _provider.addPage(widget.storyId);
      setState(() {
        _pages.add(page);
        _activePageId = page.id;
      });
      _contentController.text = '';
      _updateWordCount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add page: $e'),
            backgroundColor: const Color(0xFFD4183D),
          ),
        );
      }
    }
  }

  void _onContentChanged(String content) {
    _updateWordCount();

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
          const SnackBar(
            content: Text('Failed to save changes'),
          ),
        );
      }
    }

    if (mounted) setState(() => _isSyncing = false);
  }

  Future<void> _updateTitle() async {
    if (_story == null) return;
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    await _provider.updateStory(_story!.copyWith(title: title));
    _story = _story!.copyWith(title: title);
  }

  Future<void> _updateDescription() async {
    if (_story == null) return;
    final description = _descriptionController.text.trim();
    await _provider.updateStory(_story!.copyWith(description: description));
    _story = _story!.copyWith(description: description);
  }

  Future<void> _updateGenre(String? genre) async {
    setState(() => _selectedGenre = genre);
    if (_story == null) return;
    await _provider
        .updateStory(_story!.copyWith(genre: genre?.toLowerCase()));
    _story = _story!.copyWith(genre: genre?.toLowerCase());
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

  Future<bool> _handleBack() async {
    // Flush any pending debounce
    _debounceTimer?.cancel();
    final page = _activePage;
    if (page != null && _contentController.text != page.content) {
      await _saveContent(_contentController.text);
    }
    await _updateTitle();
    await _updateDescription();
    return true;
  }

  void _navigateBack() async {
    await _handleBack();
    if (mounted) {
      context.go('/app/story/${widget.storyId}');
    }
  }

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _navigateBack,
                    icon: Icon(Icons.chevron_left,
                        size: 28, color: AppColors.foreground),
                  ),
                  const Spacer(),
                  _SyncIndicator(isSyncing: _isSyncing),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      final router = GoRouter.of(context);
                      await _handleBack();
                      if (mounted) {
                        router.go('/app/story/${widget.storyId}/read');
                      }
                    },
                    icon: Icon(Icons.visibility_outlined,
                        size: 22, color: AppColors.foreground),
                    tooltip: 'Preview',
                  ),
                ],
              ),
            ),

            // ─── Content ───
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextField(
                      controller: _titleController,
                      onEditingComplete: _updateTitle,
                      style: TextStyle(
                        fontSize: 28,
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Story Title',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        hintStyle: TextStyle(
                          fontSize: 28,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),

                    // Meta toggle
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showMetaSection = !_showMetaSection),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              _showMetaSection
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 18,
                              color: AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _showMetaSection
                                  ? 'Hide details'
                                  : 'Description & Genre',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Collapsible meta section
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      crossFadeState: _showMetaSection
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          TextField(
                            controller: _descriptionController,
                            onEditingComplete: _updateDescription,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedForeground,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
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

                          const SizedBox(height: 8),

                          // Genre chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _genres.map((genre) {
                              final isSelected = _selectedGenre == genre;
                              final colors = Story(
                                id: '',
                                userId: '',
                                title: '',
                                genre: genre.toLowerCase(),
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ).coverColors;
                              return GestureDetector(
                                onTap: () =>
                                    _updateGenre(isSelected ? null : genre),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(colors: colors)
                                        : null,
                                    color: isSelected ? null : AppColors.card,
                                    borderRadius: BorderRadius.circular(20),
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
                                          gradient:
                                              LinearGradient(colors: colors),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        genre,
                                        style: TextStyle(
                                          fontSize: 12,
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
                          const SizedBox(height: 12),
                        ],
                      ),
                      secondChild: const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 16),

                    // Pages header with word count
                    Row(
                      children: [
                        Text(
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$_wordCount ${_wordCount == 1 ? 'word' : 'words'}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Page tabs
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
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Icon(Icons.add,
                                    size: 20, color: AppColors.foreground),
                              ),
                            );
                          }
                          final page = _pages[i];
                          final isActive = page.id == _activePageId;
                          return GestureDetector(
                            onTap: () {
                              // Save current page first
                              _debounceTimer?.cancel();
                              final currentPage = _activePage;
                              if (currentPage != null) {
                                _saveContent(_contentController.text);
                              }
                              setState(() => _activePageId = page.id);
                              _contentController.text = page.content;
                              _updateWordCount();
                            },
                            onLongPress: _pages.length > 1
                                ? () => _showDeletePageDialog(page.id, i + 1)
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.accent
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.accent
                                      : AppColors.border,
                                ),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: AppColors.accent
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
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

                    // Content editor
                    Container(
                      constraints: const BoxConstraints(minHeight: 300),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _contentController,
                        onChanged: _onContentChanged,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.foreground,
                          height: 1.7,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Continue your story...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          hintStyle:
                              TextStyle(color: AppColors.mutedForeground),
                        ),
                      ),
                    ),
                  ],
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
            style: TextStyle(color: AppColors.foreground)),
        content: Text('This action cannot be undone.',
            style: TextStyle(color: AppColors.mutedForeground)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
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
                    valueColor: AlwaysStoppedAnimation(
                        AppColors.accent.withValues(alpha: 0.7)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Saving...',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                ),
              ],
            )
          : Row(
              key: ValueKey('saved'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 16, color: AppColors.accent),
                SizedBox(width: 6),
                Text(
                  'Saved',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                ),
              ],
            ),
    );
  }
}
