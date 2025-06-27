import 'package:file_manger/app/common/global.dart';
import 'package:file_manger/db/services/video_history_service.dart';
import 'package:get/get.dart';

class HistoryPageController extends GetxController {
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
}
