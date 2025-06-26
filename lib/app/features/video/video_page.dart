import 'package:core/core.dart';
import 'package:file_manger/app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'video_page_controller.dart';

class VideoPage extends StatefulWidget {
  final String url;
  final String? auth;
  final String? title;

  const VideoPage({super.key, required this.url, this.auth, this.title});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final controller = Get.put(VideoPageController());

  Future? future;

  @override
  void initState() {
    super.initState();
    controller.setVideoUrl(widget.url);
    future = controller.createVideoController(token: widget.auth).then((c) {
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
      appBar: AppBar(
        title: Text(widget.title ?? '视频'),
        actions: [
          TextButton(
            onPressed: () {
              var superResolutionType = controller.superResolutionType;
              superResolutionType.value = (superResolutionType.value % 3) + 1;
              controller.setShader(superResolutionType.value);
            },
            child: Obx(() => _buildMode()),
          ),
        ],
      ),
      body: Center(
        child: CustomFutureBuilder(
          future: future,
          skipHasData: true,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            var videoController = controller.videoController;
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 9.0 / 16.0,
              child: Video(controller: videoController),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMode() {
    var superResolutionType = controller.superResolutionType;
    if (superResolutionType.value == SuperResolutionType.lite) {
      return const Text('效率模式');
    } else if (superResolutionType.value == SuperResolutionType.full) {
      return const Text('质量模式');
    }
    return const Text('开启超分');
  }
}
