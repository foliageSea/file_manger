import 'package:core/core.dart';
import 'package:file_manger/app/common/global.dart';
import 'package:file_manger/db/models/video_history.dart';
import 'package:file_manger/db/services/video_history_service.dart';
import 'package:get/get.dart';

class HistoryPageController extends GetxController with AppMessageMixin {
  final VideoHistoryService videoHistoryService = Global.getIt();

  final history = <VideoHistoryItem>[].obs;

  void getHistory() {
    history.value = videoHistoryService.getHistoryItems();
    history.refresh();
  }

  @override
  void onInit() {
    super.onInit();
    getHistory();
  }

  Future<void> deleteHistory(VideoHistory his) async {
    try {
      await videoHistoryService.deleteHistory(his);
      getHistory();
      await showToast('删除成功');
    } catch (_) {
      await showToast('删除失败');
      rethrow;
    }
  }
}
