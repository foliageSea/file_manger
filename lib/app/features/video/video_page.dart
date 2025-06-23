import 'package:core/core.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'widgets/custom_flick_landscape_controls.dart';

class VideoPage extends StatefulWidget {
  final String url;
  final String? auth;

  const VideoPage({super.key, required this.url, this.auth});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController videoPlayerController;
  late FlickManager flickManager;
  Future? future;
  bool isBuffering = false;
  @override
  void initState() {
    super.initState();
    future = _initPlayer();
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  Future<bool> _initPlayer() async {
    var auth = widget.auth;
    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      httpHeaders: auth != null ? {'authorization': auth} : {},
    );
    flickManager = FlickManager(
      videoPlayerController: videoPlayerController,
      autoInitialize: false,
      autoPlay: false,
    );
    videoPlayerController.addListener(() {
      if (!videoPlayerController.value.isPlaying) {
        return;
      }
      if (videoPlayerController.value.isBuffering) {
        isBuffering = true;
      } else {
        isBuffering = false;
      }
      setState(() {});
    });
    flickManager.flickControlManager?.toggleMute();
    await videoPlayerController.initialize();
    await videoPlayerController.play();

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [Flexible(child: _buildPlayer())]),
    );
  }

  Widget _buildPlayer() {
    return CustomFutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return Center(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AspectRatio(
                aspectRatio: videoPlayerController.value.aspectRatio,
                child: FlickVideoPlayer(
                  flickManager: flickManager,
                  flickVideoWithControls: const FlickVideoWithControls(
                    controls: CustomFlickLandscapeControls(),
                  ),
                ),
              ),
              _buildBuffer(),
            ],
          ),
        );
      },
    );
  }

  SingleChildRenderObjectWidget _buildBuffer() {
    return isBuffering
        ? const Center(child: CircularProgressIndicator())
        : const SizedBox();
  }
}
