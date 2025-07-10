import 'package:core/core.dart';
import 'package:file_manger/app/common/global.dart';
import 'package:file_manger/db/models/server_model.dart';
import 'package:file_manger/db/models/star_model.dart';
import 'package:file_manger/db/services/server_service.dart';
import 'package:file_manger/db/services/star_service.dart';
import 'package:get/get.dart';
import 'package:realm/realm.dart';

class HomeController extends GetxController with AppMessageMixin, AppLogMixin {
  final servers = <ServerModel>[].obs;
  ServerService serverService = Global.getIt();
  StarService starService = Global.getIt();

  final stars = <StarModel>[].obs;

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

    await serverService.updateServer(updateServer);
    getServers();
    showToast('修改成功');
  }

  void getServers() {
    servers.value = serverService.getServers();
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
