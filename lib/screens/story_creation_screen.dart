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

class _StoryCreationScreenState extends State<StoryCreationScreen> {
  StoryProvider get _provider => context.read<StoryProvider>();
  final _titleController = TextEditingController();
  List<StoryPage> _pages = [];
  String? _activePageId;
  bool _isSyncing = false;
  TextEditingController? _contentController;
  Story? _createdStory;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController?.dispose();
    super.dispose();
  }

  StoryPage? get _activePage =>
      _pages.where((p) => p.id == _activePageId).firstOrNull;

  /// Create the story in SQLite on first content change.
  Future<void> _ensureStoryCreated() async {
    if (_createdStory != null) return;

    final title = _titleController.text.trim().isEmpty
        ? 'Untitled Story'
        : _titleController.text.trim();

    _createdStory = await _provider.createStory(title: title);

    // Load the auto-created first page
    final pages = await _provider.getStoryPages(_createdStory!.id);
    if (mounted) {
      setState(() {
        _pages = pages;
        _activePageId = pages.isNotEmpty ? pages.first.id : null;
        if (_activePageId != null) {
          _contentController?.text = _activePage?.content ?? '';
        }
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
    _contentController?.text = '';
  }

  Future<void> _updateContent(String content) async {
    final page = _activePage;
    if (page == null) return;

    page.content = content;
    setState(() => _isSyncing = true);

    // Debounced save
    await Future.delayed(const Duration(milliseconds: 500));
    if (page.content == content) {
      await _provider.updatePage(page.copyWith(
        content: content,
        updatedAt: DateTime.now(),
      ));
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

  Future<void> _deletePage(String pageId) async {
    if (_pages.length > 1) {
      await _provider.deletePage(pageId);
      setState(() {
        _pages.removeWhere((p) => p.id == pageId);
        if (_activePageId == pageId) {
          _activePageId = _pages.first.id;
          _contentController?.text = _activePage?.content ?? '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.card,
                border:
                    Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      // Save title before leaving
                      if (_createdStory != null) await _updateTitle();
                      if (mounted) context.go('/app');
                    },
                    icon: const Icon(Icons.chevron_left,
                        size: 28, color: AppColors.foreground),
                    padding: EdgeInsets.zero,
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
                        const Text(
                          'Saving...',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Saved',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ],
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
                      onChanged: (_) {
                        // Auto-create story on first title change
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
                    const SizedBox(height: 24),
                    const Text(
                      'Pages',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedForeground,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                              setState(() => _activePageId = page.id);
                              _contentController?.text = page.content;
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
                        onChanged: (content) async {
                          await _ensureStoryCreated();
                          _updateContent(content);
                        },
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.foreground,
                          height: 1.7,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Start writing your story...',
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
                          side:
                              const BorderSide(color: Color(0xFFD4183D)),
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
