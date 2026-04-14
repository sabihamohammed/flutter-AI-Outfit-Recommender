import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/outfit_model.dart';

class SavedOutfitsService {
  static final List<OutfitModel> _savedOutfits = [];

  static List<OutfitModel> get savedOutfits => _savedOutfits;

  static const String _key = "saved_outfits";

  // 🔥 LOAD from storage
  static Future<void> loadOutfits() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? data = prefs.getStringList(_key);

    if (data != null) {
      _savedOutfits.clear();

      for (var item in data) {
        final jsonData = jsonDecode(item);
        _savedOutfits.add(OutfitModel.fromJson(jsonData));
      }
    }
  }

  // 🔥 SAVE to storage
  static Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> data = _savedOutfits
        .map((e) => jsonEncode(e.toJson()))
        .toList();

    await prefs.setStringList(_key, data);
  }

  // 🔥 Add new outfit
  static bool containsOutfit(OutfitModel outfit) {
    return _savedOutfits.any((saved) => saved.isSameLook(outfit));
  }

  static Future<bool> saveOutfit(OutfitModel outfit) async {
    if (containsOutfit(outfit)) {
      return false;
    }

    _savedOutfits.add(outfit);
    await _saveToStorage();
    return true;
  }

  static Future<void> deleteOutfitAt(int index) async {
    if (index < 0 || index >= _savedOutfits.length) return;
    _savedOutfits.removeAt(index);
    await _saveToStorage();
  }
}
