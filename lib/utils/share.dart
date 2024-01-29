import 'package:flutter/material.dart';
import 'package:viajuntos/utils/share_menu.dart';
import 'package:viajuntos/utils/share_menu_friend.dart';
import 'package:viajuntos/utils/verify_event_code.dart';

showShareMenu(String url, BuildContext context) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      context: context,
      builder: (BuildContext context) {
        return ShareMenu(url: url);
      });
}

showShareMenuFriend(String url, BuildContext context) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      context: context,
      backgroundColor: Theme.of(context).colorScheme.background,
      builder: (BuildContext context) {
        return ShareMenuFriend(url: url);
      });
}

showVerifyCodeEvent(
    String idParticipant, String idEvent, BuildContext context) {
  showModalBottomSheet(
      scrollControlDisabledMaxHeightRatio: 0.4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      context: context,
      backgroundColor: Theme.of(context).colorScheme.background,
      builder: (BuildContext context) {
        return VerifyEventCode(idParticipant: idParticipant, idEvent: idEvent);
      });
}
