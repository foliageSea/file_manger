import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';

import 'custom_flick_portrait_controls.dart';

class CustomFlickLandscapeControls extends StatelessWidget {
  const CustomFlickLandscapeControls({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var maxWidth = constraints.maxWidth;
        return CustomFlickPortraitControls(
          maxWidth: maxWidth,
          fontSize: 20,
          iconSize: 30,
          progressBarSettings: FlickProgressBarSettings(
            height: 10,
            handleRadius: 10.5,
          ),
        );
      },
    );
  }
}
