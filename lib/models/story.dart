import 'package:flutter/material.dart';

class Story {
  final String id;
  final String title;
  final String lastEdited;
  final List<Color> coverColors;
  final int pages;
  final int progress;
  final bool isFavorite;
  final String? created;
  final int? wordCount;

  const Story({
    required this.id,
    required this.title,
    required this.lastEdited,
    required this.coverColors,
    required this.pages,
    this.progress = 0,
    this.isFavorite = false,
    this.created,
    this.wordCount,
  });
}

class StoryPage {
  final String id;
  String content;
  String? imageUrl;

  StoryPage({
    required this.id,
    this.content = '',
    this.imageUrl,
  });
}

final List<Story> mockStories = [
  const Story(
    id: '1',
    title: 'The Hidden Garden',
    lastEdited: '2 hours ago',
    coverColors: [Color(0xFFB08968), Color(0xFF8D6E63)],
    pages: 12,
    progress: 75,
    isFavorite: true,
    created: 'March 15, 2026',
    wordCount: 2456,
  ),
  const Story(
    id: '2',
    title: 'A Journey Through Time',
    lastEdited: 'Yesterday',
    coverColors: [Color(0xFFE8DCCB), Color(0xFFC8A27C)],
    pages: 8,
    progress: 40,
    isFavorite: false,
    created: 'March 10, 2026',
    wordCount: 1234,
  ),
  const Story(
    id: '3',
    title: 'Midnight Reflections',
    lastEdited: '3 days ago',
    coverColors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
    pages: 15,
    progress: 90,
    isFavorite: true,
    created: 'March 1, 2026',
    wordCount: 3567,
  ),
  const Story(
    id: '4',
    title: 'Summer Adventures',
    lastEdited: '1 week ago',
    coverColors: [Color(0xFFC8A27C), Color(0xFFB08968)],
    pages: 6,
    progress: 30,
    isFavorite: false,
    created: 'February 20, 2026',
    wordCount: 876,
  ),
];
