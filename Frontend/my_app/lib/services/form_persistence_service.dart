import 'package:shared_preferences/shared_preferences.dart';

/// Service to persist form draft data across app restarts.
/// Uses shared_preferences with keys prefixed by screen name.
class FormPersistenceService {
  static const String _prefix = 'form_draft_';

  /// Save a single field draft.
  static Future<void> saveDraft(
    String screenKey,
    String fieldKey,
    String value,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix${screenKey}_$fieldKey', value);
  }

  /// Load a single field draft.
  static Future<String?> loadDraft(String screenKey, String fieldKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix${screenKey}_$fieldKey');
  }

  /// Load all drafts for a screen into a map.
  static Future<Map<String, String>> loadAllDrafts(
    String screenKey,
    List<String> fieldKeys,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, String>{};
    for (final key in fieldKeys) {
      final value = prefs.getString('$_prefix${screenKey}_$key');
      if (value != null) {
        result[key] = value;
      }
    }
    return result;
  }

  /// Clear a specific draft field.
  static Future<void> clearField(String screenKey, String fieldKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix${screenKey}_$fieldKey');
  }

  /// Clear all drafts for a given screen.
  static Future<void> clearDraft(
    String screenKey,
    List<String> fieldKeys,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in fieldKeys) {
      await prefs.remove('$_prefix${screenKey}_$key');
    }
  }
}
