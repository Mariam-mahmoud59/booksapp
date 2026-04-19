import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../services/supabase_service.dart';
import '../services/database_helper.dart';
import '../repositories/story_repository.dart';

/// Centralized state for authentication, user profile, and stats.
class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  final DatabaseHelper _db = DatabaseHelper();
  final StoryRepository _repo = StoryRepository();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Profile? _profile;
  int _storyCount = 0;
  int _wordCount = 0;
  int _favoriteCount = 0;

  // ─────────────────── Getters ───────────────────

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Profile? get profile => _profile;
  int get storyCount => _storyCount;
  int get wordCount => _wordCount;
  int get favoriteCount => _favoriteCount;

  /// Initialize auth state from current Supabase session.
  void checkAuthState() {
    _isAuthenticated = _supabase.isAuthenticated;
    notifyListeners();
  }

  // ─────────────────── Auth ───────────────────

  /// Sign in with email and password.
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.signIn(email, password);
      _isAuthenticated = true;

      // Seed/load data for this user
      await _repo.seedIfNeeded();
      // Trigger initial sync
      _repo.triggerSync();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed. Check your credentials.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with name, email and password.
  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.signUp(email, password);
      final userId = response.user?.id;

      if (userId != null) {
        _isAuthenticated = true;

        // Create local profile
        final now = DateTime.now();
        await _db.insertProfile(Profile(
          id: userId,
          username: name,
          createdAt: now,
          updatedAt: now,
        ));

        // Seed data for this user
        await _repo.seedIfNeeded();

        // Trigger initial sync to push profile to Supabase
        await _db.enqueueSyncOperation(
          tableName: 'profiles',
          recordId: userId,
          operation: 'INSERT',
          payload: {
            'id': userId,
            'username': name,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
        );
        _repo.triggerSync();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sign up failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _supabase.signOut();
    } catch (e) {
      debugPrint('[AuthProvider] signOut error: $e');
    }
    _isAuthenticated = false;
    _profile = null;
    _storyCount = 0;
    _wordCount = 0;
    _favoriteCount = 0;
    notifyListeners();
  }

  // ─────────────────── Profile ───────────────────

  /// Load the current user's profile from local DB.
  Future<void> loadProfile() async {
    _profile = await _repo.getProfile();
    notifyListeners();
  }

  /// Update the current user's profile.
  Future<void> updateProfile({String? username, String? avatarUrl}) async {
    await _repo.updateProfile(username: username, avatarUrl: avatarUrl);
    await loadProfile();
  }

  // ─────────────────── Stats ───────────────────

  /// Load all stats for the profile screen.
  Future<void> loadStats() async {
    _storyCount = await _repo.getStoryCount();
    _wordCount = await _repo.getTotalWordCount();
    _favoriteCount = await _repo.getFavoriteCount();
    notifyListeners();
  }

  /// Clear any error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
