import 'package:file_manger/app/common/global.dart';
import 'package:file_manger/db/models/star_model.dart';
import 'package:file_manger/db/services/star_service.dart';
import 'package:get/get.dart';

class StarController extends GetxController {
  StarService starService = Global.getIt();

  final starList = <StarFullItem>[].obs;

  void getStarList() {
    var list = starService.getStarsAndServer();
    starList.clear();
    starList.assignAll(list);
    starList.refresh();
  }

  @override
  void onInit() {
    super.onInit();
    getStarList();
  }

  Future deleteStar(StarModel item) async {
    await starService.removeStar(item);
    getStarList();
  }
}
