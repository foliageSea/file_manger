import 'package:file_manger/db/database.dart';
import 'package:file_manger/db/models/server_model.dart';
import 'package:file_manger/db/repositories/server_repository.dart';
import 'package:file_manger/db/repositories/star_repository.dart';
import 'package:realm/realm.dart';

import '../models/star_model.dart';

part 'impl/star_service_impl.dart';

abstract class StarService {
  RealmResults<StarModel> getStars();
  Future<void> addStar(StarModel star);
  Future<void> removeStar(StarModel star);
  List<StarFullItem> getStarsAndServer();
}

class StarFullItem {
  StarModel star;
  ServerModel server;

  StarFullItem(this.star, this.server);
}
