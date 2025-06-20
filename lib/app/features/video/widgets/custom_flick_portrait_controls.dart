import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';

class CustomFlickPortraitControls extends StatelessWidget {
  const CustomFlickPortraitControls({
    super.key,
    this.iconSize = 20,
    this.fontSize = 12,
    this.progressBarSettings,
    this.maxWidth,
  });

  /// Icon size.
  ///
  /// This size is used for all the player icons.
  final double iconSize;

  /// Font size.
  ///
  /// This size is used for all the text.
  final double fontSize;

  /// [FlickProgressBarSettings] settings.
  final FlickProgressBarSettings? progressBarSettings;

  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Positioned(child: _buildPlay()),
        Positioned(bottom: 8, child: _buildControls(width)),
      ],
    );
  }

  Widget _buildPlay() {
    return FlickShowControlsAction(
      child: FlickSeekVideoAction(
        child: Center(
          child: FlickVideoBuffer(
            child: FlickAutoHideChild(
              showIfVideoNotInitialized: false,
              child: FlickPlayToggle(
                size: 30,
                color: Colors.black,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(double width) {
    return SizedBox(
      height: 90,
      child: FlickAutoHideChild(
        child: Container(
          width: (maxWidth ?? width) * 0.95,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Column(
            children: <Widget>[
              FlickVideoProgressBar(
                flickProgressBarSettings: progressBarSettings,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlickPlayToggle(size: iconSize),
                  SizedBox(width: iconSize / 2),
                  GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.skip_next, size: iconSize),
                  ),
                  SizedBox(width: iconSize / 2),
                  FlickSoundToggle(size: iconSize),
                  SizedBox(width: iconSize / 2),
                  Row(
                    children: <Widget>[
                      FlickCurrentPosition(fontSize: fontSize),
                      FlickAutoHideChild(
                        child: Text(
                          ' / ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                      FlickTotalDuration(fontSize: fontSize),
                    ],
                  ),
                  Expanded(child: Container()),
                  FlickSubtitleToggle(size: iconSize),
                  SizedBox(width: iconSize / 2),
                  FlickFullScreenToggle(size: iconSize),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
