import 'package:core/core.dart';
import 'package:file_manger/app/interfaces/file_storage.dart';
import 'package:file_manger/db/models/server_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart'
    hide AdaptiveVideoControls;

import 'video_page_controller.dart';
import 'widgets/controls.dart';

class VideoPage extends StatefulWidget {
  final String url;
  final String? token;
  final String? title;
  final ServerModel? server;
  final FileItem? fileItem;

  const VideoPage({
    super.key,
    required this.url,
    this.token,
    this.title,
    this.server,
    this.fileItem,
  });

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final controller = Get.put(VideoPageController());

  Future? future;

  @override
  void initState() {
    super.initState();

    controller.setServer(widget.server);
    controller.setFileItem(widget.fileItem);
    controller.setVideoUrl(widget.url);
    var position = controller.getVideoPosition();

    future = controller
        .createVideoController(token: widget.token, offset: position)
        .then((c) {
          controller.mediaPlayer = c;
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? '视频')),
      body: Center(
        child: CustomFutureBuilder(
          future: future,
          skipHasData: true,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            var videoController = controller.videoController;
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 9.0 / 16.0,
              child: Video(
                controller: videoController,
                controls: AdaptiveVideoControls,
              ),
            );
          },
        ),
      ),
    );
  }
}
