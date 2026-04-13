import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/story.dart';
import '../repositories/story_repository.dart';

class StoryEditorScreen extends StatefulWidget {
  final String storyId;

  const StoryEditorScreen({super.key, required this.storyId});

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  final StoryRepository _repo = StoryRepository();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<StoryPage> _pages = [];
  String? _activePageId;
  bool _isSyncing = false;
  bool _isLoading = true;
  Story? _story;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _loadStory();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadStory() async {
    final story = await _repo.getStory(widget.storyId);
    final pages = await _repo.getStoryPages(widget.storyId);

    if (mounted) {
      setState(() {
        _story = story;
        _pages = pages;
        _titleController.text = story?.title ?? '';
        if (pages.isNotEmpty) {
          _activePageId = pages.first.id;
          _contentController.text = pages.first.content;
        }
        _isLoading = false;
      });
    }
  }

  StoryPage? get _activePage =>
      _pages.where((p) => p.id == _activePageId).firstOrNull;

  Future<void> _addPage() async {
    final page = await _repo.addPage(widget.storyId);
    setState(() {
      _pages.add(page);
      _activePageId = page.id;
    });
    _contentController.text = '';
  }

  Future<void> _updateContent(String content) async {
    final page = _activePage;
    if (page == null) return;

    page.content = content;
    setState(() => _isSyncing = true);

    await Future.delayed(const Duration(milliseconds: 500));
    if (page.content == content) {
      await _repo.updatePage(page.copyWith(
        content: content,
        updatedAt: DateTime.now(),
      ));
    }

    if (mounted) setState(() => _isSyncing = false);
  }

  Future<void> _updateTitle() async {
    if (_story == null) return;
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    await _repo.updateStory(_story!.copyWith(title: title));
    _story = _story!.copyWith(title: title);
  }

  Future<void> _deletePage(String pageId) async {
    if (_pages.length > 1) {
      await _repo.deletePage(pageId);
      setState(() {
        _pages.removeWhere((p) => p.id == pageId);
        if (_activePageId == pageId) {
          _activePageId = _pages.first.id;
          _contentController.text = _activePage?.content ?? '';
        }
      });
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
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
                    onPressed: () async {
                      await _updateTitle();
                      if (mounted) {
                        context.go('/app/story/${widget.storyId}');
                      }
                    },
                    icon: const Icon(Icons.chevron_left,
                        size: 28, color: AppColors.foreground),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      if (_isSyncing) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Saving...',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mutedForeground)),
                      ] else ...[
                        const Icon(Icons.check,
                            size: 16, color: AppColors.accent),
                        const SizedBox(width: 8),
                        const Text('Saved',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mutedForeground)),
                      ],
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () =>
                        context.go('/app/story/${widget.storyId}/read'),
                    icon: const Icon(Icons.visibility_outlined,
                        size: 22, color: AppColors.foreground),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
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
                        contentPadding: EdgeInsets.zero,
                        hintStyle: TextStyle(
                          fontSize: 28,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: AppColors.border),
                                ),
                                child: const Icon(Icons.add,
                                    size: 20, color: AppColors.foreground),
                              ),
                            );
                          }
                          final page = _pages[i];
                          final isActive = page.id == _activePageId;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _activePageId = page.id);
                              _contentController.text = page.content;
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.accent
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.accent
                                      : AppColors.border,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 14,
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
                        onChanged: _updateContent,
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.foreground,
                          height: 1.7,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Continue your story...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(
                              color: AppColors.mutedForeground),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_pages.length > 1)
                      OutlinedButton.icon(
                        onPressed: () {
                          if (_activePageId != null) {
                            _deletePage(_activePageId!);
                          }
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete Page'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD4183D),
                          side: const BorderSide(
                              color: Color(0xFFD4183D)),
                          minimumSize: const Size(0, 44),
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
}
