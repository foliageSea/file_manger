import 'package:core/core.dart';
import 'package:dartx/dartx.dart';
import 'package:file_manger/app/common/global.dart';
import 'package:file_manger/app/constants/constants.dart';
import 'package:file_manger/app/features/video/video_page.dart';
import 'package:file_manger/app/interfaces/file_storage.dart';
import 'package:file_manger/db/models/server_model.dart';
import 'package:file_manger/db/services/server_service.dart';
import 'package:get/get.dart';
import 'package:realm/realm.dart';

class HomeController extends GetxController with AppMessageMixin, AppLogMixin {
  late FileStorage storage;
  var files = <StorageFileItem>[].obs;
  final history = <FilesHistory>[].obs;
  Future<List<StorageFileItem>>? future;
  StorageFileItem? currentFile;
  ServerService serverService = Global.getIt();
  final servers = <ServerModel>[].obs;

  Future initStorage(ServerModel server) async {
    storage = WebDavFileStorage();
    await storage.init(server);
    log('连接成功 ${server.url}');
  }

  Future<List<StorageFileItem>> readDir(StorageFileItem file) async {
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
      var list = dirs.map((e) => e.copy()).toList();
      history.add(FilesHistory(path: file.name ?? '主页', files: list));
      history.refresh();
      log('加载目录 ${file.path}');
    } on Exception catch (e, st) {
      handle(e, st);
      rethrow;
    }
    return files;
  }

  void jumpToDir(int index) {
    if (history.length == 1) {
      return;
    }
    files.value = history[index].files.map((e) => e.copy()).toList();
    files.refresh();
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
        Get.to(VideoPage(url: url, auth: auth));
        return;
      }
    }

    showToast('暂不支持该文件类型');
  }

  Future init(ServerModel server) async {
    reset();
    await initStorage(server);
    future = readDir(StorageFileItem()..path = '/');
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

  void getServers() {
    servers.value = serverService.getServers().map((e) => e).toList();
    servers.refresh();
  }

  Future deleteServer(ServerModel server) async {
    await serverService.deleteServer(server);
    getServers();
  }

  @override
  void onInit() async {
    super.onInit();
    getServers();
  }
}

class FilesHistory {
  FilesHistory({required this.path, required this.files});
  final String path;
  final List<StorageFileItem> files;
}
