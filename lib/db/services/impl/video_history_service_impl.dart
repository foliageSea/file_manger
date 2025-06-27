part of '../video_history_service.dart';

class VideoHistoryServiceImpl
    with AppDatabaseMixin
    implements VideoHistoryService {
  late VideoHistoryRepository videoHistoryRepository;
  late ServerRepository serverRepository;

  VideoHistoryServiceImpl() {
    videoHistoryRepository = VideoHistoryRepository(db);
    serverRepository = ServerRepository(db);
  }

  @override
  Future addHistory(VideoHistory history) async {
    await videoHistoryRepository.addHistory(history);
  }

  @override
  Future deleteHistory(VideoHistory history) async {
    await videoHistoryRepository.deleteHistory(history);
  }

  @override
  List<VideoHistory> getHistories() {
    return videoHistoryRepository.getHistories();
  }

  @override
  Future updateHistory(VideoHistory history) async {
    await videoHistoryRepository.updateHistory(history);
  }

  @override
  VideoHistory? getHistoryById(ObjectId id) {
    return videoHistoryRepository.getHistories().firstWhereOrNull(
      (element) => element.id == id,
    );
  }

  @override
  VideoHistory? getHistoryByUrl(String url) {
    return videoHistoryRepository.getHistories().firstWhereOrNull(
      (element) => element.url == url,
    );
  }

  @override
  List<VideoHistoryItem> getHistoryItems() {
    return videoHistoryRepository
        .getHistories()
        .map(
          (e) =>
              VideoHistoryItem(e, serverRepository.getServerById(e.serverId)!),
        )
        .toList();
  }
}
