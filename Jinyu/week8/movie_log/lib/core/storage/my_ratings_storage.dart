import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/rating_dto.dart';

abstract interface class MyRatingsStorage {
  Future<List<RatingDto>> readRatings();
  Future<void> upsertRating(RatingDto rating);
  Future<void> removeRating(int ratingId);
  Future<void> clear();
}

class SharedPrefsMyRatingsStorage implements MyRatingsStorage {
  static const _storageKey = 'movielog.my_ratings_cache_v1';

  @override
  Future<List<RatingDto>> readRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    return decoded
        .whereType()
        .map((item) => RatingDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> _writeRatings(List<RatingDto> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  @override
  Future<void> upsertRating(RatingDto rating) async {
    final current = await readRatings();
    final index = current.indexWhere((e) => e.ratingId == rating.ratingId);
    final updated = [...current];
    if (index >= 0) {
      updated[index] = rating;
    } else {
      updated.insert(0, rating);
    }
    await _writeRatings(updated);
  }

  @override
  Future<void> removeRating(int ratingId) async {
    final current = await readRatings();
    final updated = current.where((e) => e.ratingId != ratingId).toList();
    await _writeRatings(updated);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}