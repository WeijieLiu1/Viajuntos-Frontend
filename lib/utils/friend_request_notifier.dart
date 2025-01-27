import 'package:flutter/material.dart';

class RedDotNotifier extends ChangeNotifier {
  bool hasFriendRequest = false;

  void updateFriendRequests(dynamic requests) {
    hasFriendRequest =
        requests.where((request) => request["accepted"] == null).isNotEmpty;
    notifyListeners();
  }
}
