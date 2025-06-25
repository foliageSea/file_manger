import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

typedef KeyActionFunc = Function(FlickManager, VideoPlayerController);

Map<LogicalKeyboardKey, KeyActionFunc> keyActionHandlers = {
  LogicalKeyboardKey.arrowLeft: (flickManager, videoPlayerController) {
    videoPlayerController.seekTo(
      videoPlayerController.value.position - const Duration(seconds: 2),
    );
  },
  LogicalKeyboardKey.arrowRight: (flickManager, videoPlayerController) {
    videoPlayerController.seekTo(
      videoPlayerController.value.position + const Duration(seconds: 2),
    );
  },
  LogicalKeyboardKey.space: (flickManager, videoPlayerController) {
    if (videoPlayerController.value.isPlaying) {
      videoPlayerController.pause();
    } else {
      videoPlayerController.play();
    }
  },
  LogicalKeyboardKey.keyF: (flickManager, videoPlayerController) {
    var showPlayerControls =
        flickManager.flickDisplayManager?.showPlayerControls;
    if (showPlayerControls == true) {
      flickManager.flickDisplayManager?.hidePlayerControls();
    } else {
      flickManager.flickDisplayManager?.handleShowPlayerControls(
        showWithTimeout: false,
      );
    }
  },
};
