import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:file_manger/app/common/global.dart';
import 'package:file_manger/app/constants/constants.dart';
import 'package:file_manger/app/features/files/files_controller.dart';
import 'package:file_manger/app/features/history/history_page_controller.dart';
import 'package:file_manger/app/interfaces/file_storage.dart';
import 'package:file_manger/app/utils/shaders_util.dart';
import 'package:file_manger/db/models/server_model.dart';
import 'package:file_manger/db/models/video_history.dart';
import 'package:file_manger/db/services/video_history_service.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:realm/realm.dart';
import 'package:rxdart/rxdart.dart';

class VideoPageController extends GetxController with AppLogMixin {
  var superResolutionType = 1.obs;
  var hAenable = true;
  var hardwareDecoder = 'auto-safe';
  var autoPlay = false;
  var lowMemoryMode = false;
  late Player mediaPlayer;
  late VideoController videoController;
  var videoUrl = '';
  final VideoHistoryService videoHistoryService = Global.getIt();
  String? token;
  ServerModel? server;
  FileItem? fileItem;
  Duration cacheDuration = const Duration(seconds: 2);

  final subtitles = <SubtitleTrack>[].obs;
  final audios = <AudioTrack>[].obs;
  final subtitleIndex = 0.obs;
  final audioIndex = 0.obs;

  void setVideoUrl(String url) {
    videoUrl = url;
  }

  void setServer(ServerModel? server) {
    this.server = server;
  }

  void setFileItem(FileItem? fileItem) {
    this.fileItem = fileItem;
  }

  Future<Player> createVideoController({int offset = 0, String? token}) async {
    log('offset $offset');
    this.token = token;
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

    // mediaPlayer.stream.duration.listen((event) {});
    // mediaPlayer.stream.position.listen((event) {});
    mediaPlayer.stream.error.listen((error) {
      this.error(error);
    });

    Stream<Duration> throttlePosition = mediaPlayer.stream.position
        .throttleTime(cacheDuration);

    throttlePosition.listen((position) async {
      await cachePosition();
    });

    if (superResolutionType.value != SuperResolutionType.off) {
      await setShader(superResolutionType.value);
    }

    // await mediaPlayer.setVolume(0);

    await mediaPlayer.open(
      Media(
        videoUrl,
        start: Duration(seconds: offset),
        httpHeaders: {'authorization': token ?? ''},
      ),
      play: autoPlay,
    );

    mediaPlayer.stream.tracks.listen((event) {
      if (audios.isEmpty && subtitles.isEmpty) {
        getTracks();
      }
    });

    return mediaPlayer;
  }

  Future getTracks() async {
    subtitles.value = mediaPlayer.state.tracks.subtitle;
    subtitles.refresh();
    audios.value = mediaPlayer.state.tracks.audio;
    audios.refresh();
  }

  Future setSubtitleTrack(int index) async {
    // 禁用所有字幕
    // await mediaPlayer.setSubtitleTrack(SubtitleTrack.no());
    // 启用第1个字幕轨道（索引从0开始）
    await mediaPlayer.setSubtitleTrack(subtitles[index]);
  }

  Future setAudioTrack(int index) async {
    // 禁用所有音轨（静音）
    // await mediaPlayer.setAudioTrack(AudioTrack.no());
    // 启用第1个音轨
    await mediaPlayer.setAudioTrack(audios[index]);
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

  Future<void> _saveVideoProgress(int position, int duration) async {
    try {
      var serverId = server?.id;
      var path = fileItem?.path;

      if (serverId == null || path == null || token == null) {
        warning('跳过保存进度');
        return;
      }

      late VideoHistory history;

      var item = videoHistoryService.getHistoryByUrl(videoUrl);

      if (item != null) {
        DateTime updatedTime = DateTime.now();
        history = VideoHistory(
          item.id,
          item.path,
          item.url,
          item.token,
          duration,
          position,
          item.serverId,
          item.createdTime,
          updatedTime,
        );
        await videoHistoryService.updateHistory(history);
        log('更新进度 $position s');
      } else {
        DateTime createdTime = DateTime.now();
        history = VideoHistory(
          ObjectId(),
          path,
          videoUrl,
          token!,
          duration,
          position,
          serverId,
          createdTime,
          createdTime,
        );
        await videoHistoryService.addHistory(history);
        log('新增进度 $position');
      }
    } catch (e, st) {
      handle(e, st);
    }
  }

  int getVideoPosition() {
    var item = videoHistoryService.getHistoryByUrl(videoUrl);
    return item?.position ?? 0;
  }

  void refreshHistory() {
    try {
      Get.find<HistoryPageController>().getHistory();
    } catch (_) {}
    try {
      Get.find<FilesController>().loadHistoryByServerId();
    } catch (_) {}
  }

  Future cachePosition() async {
    // 检查视频是否已加载完成
    if (!mediaPlayer.state.playing) {
      log('视频未初始化完成，跳过进度保存');
      return;
    }

    var position = mediaPlayer.state.position.inSeconds;
    var duration = mediaPlayer.state.duration.inSeconds;

    // 确保视频时长有效
    if (duration <= 0) {
      log('视频时长无效，跳过进度保存');
      return;
    }

    await _saveVideoProgress(position, duration);
  }

  @override
  void onClose() async {
    await cachePosition();
    await mediaPlayer.dispose();
    refreshHistory();
    logger.info('注销视频播放器');
    super.onClose();
  }
}
