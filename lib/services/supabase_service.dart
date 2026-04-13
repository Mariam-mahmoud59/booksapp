import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Thin wrapper around the Supabase client.
/// Handles initialization, authentication, and raw table operations.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _initialized = false;

  /// Initialize Supabase. Call once at app startup.
  Future<void> initialize() async {
    if (_initialized) return;
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    _initialized = true;
  }

  SupabaseClient get client => Supabase.instance.client;

  // ─────────────────────── AUTH ───────────────────────

  /// Current authenticated user's ID, or null if not signed in.
  String? get currentUserId => client.auth.currentUser?.id;

  /// Whether a user is currently authenticated.
  bool get isAuthenticated => client.auth.currentUser != null;

  /// Sign up with email and password.
  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Listen to auth state changes.
  Stream<AuthState> get onAuthStateChange => client.auth.onAuthStateChange;

  // ─────────────────────── TABLE OPERATIONS ───────────────────────

  /// Upsert a row into a Supabase table.
  Future<void> upsertRow(String table, Map<String, dynamic> data) async {
    await client.from(table).upsert(data);
  }

  /// Soft-delete: update a row to set deleted_at.
  Future<void> softDeleteRow(
      String table, String id, String deletedAt) async {
    await client
        .from(table)
        .update({'deleted_at': deletedAt})
        .eq('id', id);
  }

  /// Fetch rows updated after a given timestamp.
  Future<List<Map<String, dynamic>>> fetchRowsAfter(
      String table, DateTime? after) async {
    var query = client.from(table).select();
    if (after != null) {
      query = query.gt('updated_at', after.toIso8601String());
    }
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch rows updated after a given timestamp for a specific user.
  Future<List<Map<String, dynamic>>> fetchUserRowsAfter(
      String table, String userId, DateTime? after) async {
    var query = client.from(table).select().eq('user_id', userId);
    if (after != null) {
      query = query.gt('updated_at', after.toIso8601String());
    }
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch favorites updated after a given timestamp for a user.
  /// Favorites table uses created_at as its comparable timestamp.
  Future<List<Map<String, dynamic>>> fetchFavoritesAfter(
      String userId, DateTime? after) async {
    var query = client.from('favorites').select().eq('user_id', userId);
    if (after != null) {
      query = query.gt('created_at', after.toIso8601String());
    }
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }
}
