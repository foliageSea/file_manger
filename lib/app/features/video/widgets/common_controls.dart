import 'package:core/core.dart';
import 'package:file_manger/app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../video_page_controller.dart';

abstract class CommonControls {
  static Row buildBottomButtonBar(
    BuildContext context,
    List<Widget> bottomButtonBar,
  ) {
    bottomButtonBar.addAll([
      Obx(() => _buildSuperResolution()),
      const SizedBox(width: 16),
      _buildSubtitles(),
      const SizedBox(width: 16),
      _buildAudios(),
    ]);

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: bottomButtonBar,
    );
  }

  static Widget _buildSuperResolution() {
    var controller = Get.find<VideoPageController>();

    var superResolutionType = controller.superResolutionType;
    var mode = '';
    if (superResolutionType.value == SuperResolutionType.off) {
      mode = '开启超分';
    } else if (superResolutionType.value == SuperResolutionType.lite) {
      mode = '效率模式';
    } else if (superResolutionType.value == SuperResolutionType.full) {
      mode = '质量模式';
    }

    return PopupMenuButton(
      tooltip: '超分',
      constraints: const BoxConstraints(minWidth: 200),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            child: const Text('关闭超分'),
            onTap: () {
              controller.setShader(SuperResolutionType.off);
              AppMessage().showToast('关闭超分');
            },
          ),
          PopupMenuItem(
            child: const Text('效率模式'),
            onTap: () {
              controller.setShader(SuperResolutionType.lite);
              AppMessage().showToast('效率模式');
            },
          ),
          PopupMenuItem(
            child: const Text('质量模式'),
            onTap: () {
              controller.setShader(SuperResolutionType.full);
              AppMessage().showToast('质量模式');
            },
          ),
        ];
      },
      child: Text(mode),
    );
  }

  static Widget _buildSubtitles() {
    var controller = Get.find<VideoPageController>();
    var subtitles = controller.subtitles;
    var subtitleIndex = controller.subtitleIndex;

    return PopupMenuButton(
      tooltip: '字幕',
      constraints: const BoxConstraints(minWidth: 200),
      itemBuilder: (BuildContext context) {
        return subtitles.map(((e) {
          var index = subtitles.indexOf(e);
          return PopupMenuItem(
            value: index,
            child: SizedBox(
              height: kMinInteractiveDimension,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.language ?? e.id),
                  index == subtitleIndex.value
                      ? const Icon(Icons.check)
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            onTap: () async {
              await controller.setSubtitleTrack(index);
              subtitleIndex.value = index;
              subtitleIndex.refresh();
            },
          );
        })).toList();
      },
      child: const Text('字幕'),
    );
  }

  static Widget _buildAudios() {
    var controller = Get.find<VideoPageController>();
    var audios = controller.audios;
    var audioIndex = controller.audioIndex;

    return PopupMenuButton(
      tooltip: '音轨',
      constraints: const BoxConstraints(minWidth: 200),
      itemBuilder: (BuildContext context) {
        return audios.map(((e) {
          var index = audios.indexOf(e);
          return PopupMenuItem(
            value: index,
            child: SizedBox(
              height: kMinInteractiveDimension,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.language ?? e.id),
                  index == audioIndex.value
                      ? const Icon(Icons.check)
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            onTap: () async {
              await controller.setAudioTrack(index);
              audioIndex.value = index;
              audioIndex.refresh();
            },
          );
        })).toList();
      },
      child: const Text('音轨'),
    );
  }
}
