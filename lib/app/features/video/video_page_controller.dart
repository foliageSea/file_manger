import 'dart:io';

import 'package:core/core.dart';
import 'package:file_manger/app/constants/constants.dart';
import 'package:file_manger/app/utils/shaders_util.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPageController extends GetxController with AppLogMixin {
  var superResolutionType = 1.obs;
  var hAenable = true;
  var hardwareDecoder = 'auto-safe';
  var autoPlay = true;
  var lowMemoryMode = false;
  late Player mediaPlayer;
  late VideoController videoController;
  var videoUrl = '';

  void setVideoUrl(String url) {
    videoUrl = url;
  }

  Future<Player> createVideoController({int offset = 0, String? token}) async {
    mediaPlayer = Player(
      configuration: PlayerConfiguration(
        bufferSize: lowMemoryMode ? 15 * 1024 * 1024 : 1500 * 1024 * 1024,
        osc: false,
        logLevel: MPVLogLevel.info,
      ),
    );
    var pp = mediaPlayer.platform as NativePlayer;
    // media-kit 默认启用硬盘作为双重缓存，这可以维持大缓存的前提下减轻内存压力
    // media-kit 内部硬盘缓存目录按照 Linux 配置，这导致该功能在其他平台上被损坏
    // 该设置可以在所有平台上正确启用双重缓存
    await pp.setProperty(
      "demuxer-cache-dir",
      await ShadersUtil.getPlayerTempPath(),
    );
    await pp.setProperty("af", "scaletempo2=max-speed=8");
    if (Platform.isAndroid) {
      await pp.setProperty("volume-max", "100");
      await pp.setProperty("ao", "opensles");
    }

    await mediaPlayer.setAudioTrack(AudioTrack.auto());

    videoController = VideoController(
      mediaPlayer,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: hAenable,
        hwdec: hAenable ? hardwareDecoder : 'no',
        androidAttachSurfaceAfterVideoParameters: false,
      ),
    );
    await mediaPlayer.setPlaylistMode(PlaylistMode.none);

    mediaPlayer.stream.error.listen((event) {});
    if (superResolutionType.value != 1) {
      await setShader(superResolutionType.value);
    }

    await mediaPlayer.setVolume(0);

    await mediaPlayer.open(
      Media(
        videoUrl,
        start: Duration(seconds: offset),
        httpHeaders: {'authorization': token ?? ''},
      ),
      play: autoPlay,
    );

    return mediaPlayer;
  }

  Future<void> setShader(int type, {bool synchronized = true}) async {
    var pp = mediaPlayer.platform as NativePlayer;
    await pp.waitForPlayerInitialization;
    await pp.waitForVideoControllerInitializationIfAttached;
    if (type == SuperResolutionType.lite) {
      await pp.command([
        'change-list',
        'glsl-shaders',
        'set',
        ShadersUtil.buildShadersAbsolutePath(
          ShadersUtil.shadersDirectory.path,
          mpvAnime4KShadersLite,
        ),
      ]);
      log('开启效率模式');
      superResolutionType.value = type;
      return;
    }
    if (type == SuperResolutionType.full) {
      await pp.command([
        'change-list',
        'glsl-shaders',
        'set',
        ShadersUtil.buildShadersAbsolutePath(
          ShadersUtil.shadersDirectory.path,
          mpvAnime4KShaders,
        ),
      ]);
      log('开启质量模式');
      superResolutionType.value = type;

      return;
    }
    await pp.command(['change-list', 'glsl-shaders', 'clr', '']);
    superResolutionType.value = type;

    log('关闭超分辨率');
  }

  @override
  void onClose() {
    mediaPlayer.dispose();
    super.onClose();
  }
}
