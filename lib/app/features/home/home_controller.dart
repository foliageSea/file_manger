import 'package:core/core.dart';
import 'package:dartx/dartx.dart';
import 'package:file_manger/app/common/global.dart';
import 'package:file_manger/app/constants/constants.dart';
import 'package:file_manger/app/features/video/video_page.dart';
import 'package:file_manger/app/interfaces/file_storage.dart';
import 'package:file_manger/db/models/server_model.dart';
import 'package:file_manger/db/models/star_model.dart';
import 'package:file_manger/db/services/server_service.dart';
import 'package:file_manger/db/services/star_service.dart';
import 'package:get/get.dart';
import 'package:realm/realm.dart';

class HomeController extends GetxController with AppMessageMixin, AppLogMixin {
  late FileStorage storage;
  var files = <StorageFileItem>[].obs;
  final history = <FilesHistory>[].obs;
  Future<List<StorageFileItem>>? future;
  StorageFileItem? currentFile;
  ServerService serverService = Global.getIt();
  StarService starService = Global.getIt();
  final servers = <ServerModel>[].obs;

  final Rx<SortBy> sortBy = SortBy.name.obs;
  final Rx<SortOrder> sortOrder = SortOrder.asc.obs;

  final stars = <StarModel>[].obs;

  Future initStorage(ServerModel server) async {
    storage = WebDavFileStorage();
    await storage.init(server);
    log('连接成功 ${server.url}');
  }

  Future<List<StorageFileItem>> readDir(
    StorageFileItem file, [
    String? path,
  ]) async {
    try {
      currentFile = file;
      var dirs = await storage.readDir(file);

      dirs = dirs.where((e) {
        for (var item in excludeStartWith) {
          if (e.name?.startsWith(item) == true) {
            return false;
          }
        }
        return true;
      }).toList();

      files.value = dirs;
      files.refresh();
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
        history.add(
          FilesHistory(path: file.path ?? '/', name: file.name ?? ''),
        );
      }

      history.refresh();
      log('加载目录 ${file.path}');
    } on Exception catch (e, st) {
      handle(e, st);
      rethrow;
    }
    return files;
  }

  Future jumpToDir(int index) async {
    if (history.length == 1) {
      return;
    }
    future = readDir(StorageFileItem()..path = history[index].path);
    await future;
    var list = history.slice(0, index);
    history.value = list;
    history.refresh();
  }

  Future openFile(StorageFileItem file) async {
    var url = await storage.getUrl(file);
    storage.getAuth();

    for (var element in supportVideoExtensions) {
      if (file.name?.endsWith(element) == true) {
        var auth = storage.getAuth();
        log('打开视频文件 $url');
        log('令牌 $auth');
        await Get.to(VideoPage(url: url, auth: auth, title: file.name));
        return;
      }
    }

    showToast('暂不支持该文件类型');
  }

  Future init(ServerModel server, [String? path]) async {
    reset();
    await initStorage(server);

    history.refresh();
    future = readDir(StorageFileItem()..path = path ?? '/', path);
    loadStarsByServerId();
  }

  void reset() {
    currentFile = null;
    history.value = [];
    history.refresh();
    files.value = [];
    files.refresh();
  }

  Future addServer(Map<String, String> formData) async {
    ServerModel server = ServerModel(
      ObjectId(),
      formData['server']!,
      formData['username']!,
      formData['password']!,
      formData['name']!,
    );

    await serverService.addServer(server);

    showToast('新增成功');

    getServers();
  }

  Future updateServer(ServerModel server, Map<String, String> formData) async {
    ServerModel updateServer = ServerModel(
      server.id,
      formData['server']!,
      formData['username']!,
      formData['password']!,
      formData['name']!,
    );

    log('${server.id}, ${updateServer.id}');

    // server.name = formData['name']!;
    // server.url = formData['server']!;
    // server.username = formData['username']!;
    // server.password = formData['password']!;

    await serverService.updateServer(updateServer);
    showToast('修改成功');
    getServers();
  }

  void getServers() {
    servers.value = serverService.getServers().map((e) => e).toList();
    servers.refresh();
  }

  Future deleteServer(ServerModel server) async {
    await serverService.deleteServer(server);
    getServers();
  }

  Future toggleStarDir(StorageFileItem file) async {
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
    var serverId = storage.getServerId();

    var model = StarModel(ObjectId(), name, path, serverId);
    await starService.addStar(model);
    showToast('收藏成功');
    loadStarsByServerId();
  }

  void loadStarsByServerId() {
    var stars = starService.getStars();
    var serverId = storage.getServerId();
    List<StarModel> list = stars.where((e) => e.serverId == serverId).toList();
    this.stars.value = list;
    this.stars.refresh();
  }

  @override
  void onInit() async {
    super.onInit();
    getServers();
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
}

class FilesHistory {
  FilesHistory({required this.path, required this.name});
  final String path;
  final String name;
}
