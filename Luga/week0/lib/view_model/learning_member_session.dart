import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearningMemberSession extends ChangeNotifier {
    static const _key = 'learning_member_id';

    int? _memberId;
    int? get memberId => _memberId;

    bool get isSignedUp => _memberId != null;

    Future<void> restore() async {
        final prefs = await SharedPreferences.getInstance();
        _memberId = prefs.getInt(_key);
        notifyListeners();
    }

    Future<void> setMemberId(int id) async {
        _memberId = id;
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_key, id);
    }

    Future<void> clear() async {
        _memberId = null;
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_key);
    }
}