import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/story.dart';

class StoryCreationScreen extends StatefulWidget {
  const StoryCreationScreen({super.key});

  @override
  State<StoryCreationScreen> createState() => _StoryCreationScreenState();
}

class _StoryCreationScreenState extends State<StoryCreationScreen> {
  final _titleController = TextEditingController();
  final List<StoryPage> _pages = [StoryPage(id: '1')];
  String _activePageId = '1';
  bool _isSyncing = false;
  TextEditingController? _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: _activePage?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController?.dispose();
    super.dispose();
  }

  StoryPage? get _activePage =>
      _pages.where((p) => p.id == _activePageId).firstOrNull;

  void _addPage() {
    final newPage = StoryPage(id: DateTime.now().millisecondsSinceEpoch.toString());
    setState(() {
      _pages.add(newPage);
      _activePageId = newPage.id;
    });
    _contentController?.text = '';
  }

  void _updateContent(String content) {
    _activePage?.content = content;
    setState(() => _isSyncing = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isSyncing = false);
    });
  }

  void _deletePage(String pageId) {
    if (_pages.length > 1) {
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.card,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/app'),
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
                          'Syncing...',
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
                                  border: Border.all(color: AppColors.border),
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
                        onChanged: _updateContent,
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
                        onPressed: () => _deletePage(_activePageId),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete Page'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD4183D),
                          side: const BorderSide(color: Color(0xFFD4183D)),
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
