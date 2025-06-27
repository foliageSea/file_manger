import 'package:file_manger/db/database.dart';
import 'package:get/get.dart';
import 'package:realm/realm.dart';

import '../models/video_history.dart';
import '../repositories/video_history_repository.dart';

part 'impl/video_history_service_impl.dart';

abstract class VideoHistoryService {
  Future addHistory(VideoHistory history);

  Future updateHistory(VideoHistory history);

  Future deleteHistory(VideoHistory history);

  List<VideoHistory> getHistories();

  VideoHistory? getHistoryById(ObjectId id);

  VideoHistory? getHistoryByUrl(String url);
}
