import 'package:core/core.dart';
import 'package:dartx/dartx.dart';
import 'package:file_manger/app/common/global.dart';
import 'package:file_manger/app/constants/constants.dart';
import 'package:file_manger/app/features/video/video_page.dart';
import 'package:file_manger/app/interfaces/file_storage.dart';
import 'package:file_manger/db/models/server_model.dart';
import 'package:file_manger/db/models/star_model.dart';
import 'package:file_manger/db/models/video_history.dart';
import 'package:file_manger/db/services/server_service.dart';
import 'package:file_manger/db/services/star_service.dart';
import 'package:file_manger/db/services/video_history_service.dart';
import 'package:get/get.dart';
import 'package:realm/realm.dart';

import 'files_page.dart';

class FilesController extends GetxController with AppLogMixin, AppMessageMixin {
  late FileStorage fileStorage;
  var files = <FileItem>[].obs;
  final history = <FilesHistory>[].obs;
  Future<List<FileItem>>? future;
  FileItem? currentFile;
  ServerService serverService = Global.getIt();
  StarService starService = Global.getIt();
  VideoHistoryService videoHistoryService = Global.getIt();

  final Rx<SortBy> sortBy = SortBy.name.obs;
  final Rx<SortOrder> sortOrder = SortOrder.asc.obs;

  final stars = <StarModel>[].obs;
  final histories = <VideoHistory>[].obs;
  CustomCancelToken? cancelToken;
  FilesPageState? state;

  void setState(FilesPageState state) {
    this.state = state;
  }

  Future initFileStorage(ServerModel server) async {
    fileStorage = WebDavFileStorage();
    await fileStorage.init(server);
    log('连接成功 ${server.url}');
  }

  Future<List<FileItem>> readDir(FileItem file, [String? path]) async {
    try {
      show(message: '加载中');
      cancelToken?.cancel();
      cancelToken = CustomCancelToken();
      currentFile = file;
      var dirs = await fileStorage.readDir(file, cancelToken);
      dirs = filterFiles(dirs);
      files.value = dirs;
      files.refresh();

      handlePushHistory(file, path);
      cancelToken = null;
      log('加载目录 ${file.path}');
      state?.animateToLast();
    } on Exception catch (e, st) {
      handle(e, st);
      rethrow;
    } finally {
      dismiss();
    }
    return files;
  }

  List<FileItem> filterFiles(List<FileItem> dirs) {
    dirs = dirs.where((e) {
      for (var item in excludeStartWith) {
        if (e.name?.startsWith(item) == true) {
          return false;
        }
      }
      return true;
    }).toList();
    return dirs;
  }

  void handlePushHistory(FileItem file, [String? path]) {
    if (path != null) {
      var list = path.split('/');
      if (list.length > 2) {
        var temp = '';
        for (var i = 0; i < list.length - 1; i++) {
          var e = list[i];
          if (e == '' && i == 0) {
            temp += '/';
            history.add(FilesHistory(path: temp, name: temp));
          } else if (e == '') {
            continue;
          } else {
            temp += '$e/';
            history.add(FilesHistory(path: temp, name: e));
          }
        }
      }
    } else {
      history.add(FilesHistory(path: file.path ?? '/', name: file.name ?? ''));
    }
    history.refresh();
  }

  Future jumpToDir(int index) async {
    if (history.length == 1) {
      return;
    }
    if (index == history.length - 1) {
      return;
    }
    future = readDir(FileItem()..path = history[index].path);
    await future;
    var list = history.slice(0, index);
    history.value = list;
    history.refresh();
  }

  Future openFile(FileItem file, {ServerModel? server}) async {
    var url = await fileStorage.getUrl(file);
    var auth = fileStorage.getAuth();

    for (var element in supportVideoExtensions) {
      if (file.name?.toLowerCase().endsWith(element) == true) {
        log('打开视频文件 $url');
        log('令牌 $auth');
        await Get.to(
          VideoPage(
            url: url,
            token: auth,
            title: file.name,
            server: server,
            fileItem: file,
          ),
        );
        return;
      }
    }

    showToast('暂不支持该文件类型');
  }

  Future init(ServerModel server, [String? path]) async {
    resetFilesPageState();
    await initFileStorage(server);
    future = readDir(FileItem()..path = path ?? '/', path);
    loadStarsByServerId();
    loadHistoryByServerId();
  }

  void resetFilesPageState() {
    currentFile = null;
    history.value = [];
    history.refresh();
    files.value = [];
    files.refresh();
  }

  void loadStarsByServerId() {
    var stars = starService.getStars();
    var serverId = fileStorage.getServerId();
    List<StarModel> list = stars.where((e) => e.serverId == serverId).toList();
    this.stars.value = list;
    this.stars.refresh();
  }

  void loadHistoryByServerId() {
    var histories = videoHistoryService.getHistories();
    var serverId = fileStorage.getServerId();
    List<VideoHistory> list = histories
        .where((e) => e.serverId == serverId)
        .toList();
    this.histories.value = list;
    this.histories.refresh();
  }

  @override
  void onInit() async {
    super.onInit();
    loadCache();
  }

  void loadCache() {
    var sortByStr = Storage().get(StorageKeys.sortBy);
    var sortOrderStr = Storage().get(StorageKeys.sortOrder);
    if (sortByStr != null) {
      sortBy.value = SortBy.values.firstWhere((e) => e.name == sortByStr);
      sortBy.refresh();
    }
    if (sortOrderStr != null) {
      sortOrder.value = SortOrder.values.firstWhere(
        (e) => e.name == sortOrderStr,
      );
      sortOrder.refresh();
    }
  }

  Future updateOrder(SortBy changeSortBy) async {
    sortBy.value = changeSortBy;
    sortOrder.value = sortOrder.value == SortOrder.asc
        ? SortOrder.desc
        : SortOrder.asc;
    sortBy.refresh();
    sortOrder.refresh();
    await Storage().set(StorageKeys.sortBy, sortBy.value.name);
    await Storage().set(StorageKeys.sortOrder, sortOrder.value.name);
  }

  Future toggleStarDir(FileItem file) async {
    var path = file.path ?? "";

    var isStar = stars.any((e) => e.path == path);
    if (isStar) {
      var star = stars.firstWhere((e) => e.path == path);
      await starService.removeStar(star);
      loadStarsByServerId();
      showToast('取消收藏');
      return;
    }

    var name = file.name ?? "";
    var serverId = fileStorage.getServerId();

    var model = StarModel(ObjectId(), name, path, serverId);
    await starService.addStar(model);
    showToast('收藏成功');
    loadStarsByServerId();
  }
}

class FilesHistory {
  final String path;
  final String name;

  FilesHistory({required this.path, required this.name});
}
