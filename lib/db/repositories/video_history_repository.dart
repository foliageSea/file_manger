import 'package:file_manger/db/models/video_history.dart';
import 'package:file_manger/db/repositories/base_repository.dart';

class VideoHistoryRepository extends BaseRepository {
  VideoHistoryRepository(super.db);

  Future<void> addHistory(VideoHistory history) async {
    await db.writeAsync(() {
      db.add<VideoHistory>(history);
    });
  }

  Future<void> deleteHistory(VideoHistory history) async {
    await db.writeAsync(() {
      db.delete<VideoHistory>(history);
    });
  }

  List<VideoHistory> getHistories() {
    return db.all<VideoHistory>().toList();
  }

  Future<void> updateHistory(VideoHistory history) async {
    await db.writeAsync(() {
      db.add<VideoHistory>(history, update: true);
    });
  }
}
