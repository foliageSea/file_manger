import 'package:flutter/services.dart';
import 'package:fvp/mdk.dart';

typedef KeyActionFunc = Function(Player);

Map<LogicalKeyboardKey, KeyActionFunc> keyActionHandlers = {
  LogicalKeyboardKey.arrowLeft: (player) {
    player.seek(position: player.position - 2000);
  },
  LogicalKeyboardKey.arrowRight: (player) {
    player.seek(position: player.position + 2000);
  },
  LogicalKeyboardKey.space: (player) {},
  LogicalKeyboardKey.keyF: (player) {},
};
