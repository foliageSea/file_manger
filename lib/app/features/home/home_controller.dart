import 'package:core/core.dart';
import 'package:dartx/dartx.dart';
import 'package:file_manger/app/constants/constants.dart';
import 'package:file_manger/app/features/video/video_page.dart';
import 'package:file_manger/app/interfaces/file_storage.dart';
import 'package:get/get.dart';

class HomeController extends GetxController with AppMessageMixin, AppLogMixin {
  late FileStorage storage;
  var files = <StorageFileItem>[].obs;
  final history = <FilesHistory>[].obs;
  Future<List<StorageFileItem>>? future;
  late StorageFileItem currentFile;

  Future initStorage() async {
    storage = WebDavFileStorage();
    await storage.init();
  }

  Future<List<StorageFileItem>> readDir(StorageFileItem file) async {
    try {
      currentFile = file;
      files.value = [];
      files.value = await storage.readDir(file);
      files.refresh();
      var list = files.map((e) => e.copy()).toList();
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
    files.value = history[index].files;
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

  Future init() async {
    await initStorage();
    future = readDir(StorageFileItem()..path = '/');
  }
}

class FilesHistory {
  FilesHistory({required this.path, required this.files});
  final String path;
  final List<StorageFileItem> files;
}
