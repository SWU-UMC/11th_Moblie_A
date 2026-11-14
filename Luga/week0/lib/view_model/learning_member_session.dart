import 'package:flutter/foundation.dart';

class LearningMemberSession extends ChangeNotifier {
    int? _memberId;
    int? get memberId => _memberId;

    bool get isSignedUp => _memberId != null;

    void setMemberId(int id) {
        _memberId = id;
        notifyListeners();
    }

    void clear() {
        _memberId = null;
        notifyListeners();
    }
}