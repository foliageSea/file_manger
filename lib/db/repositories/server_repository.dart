import 'package:file_manger/db/models/server_model.dart';
import 'package:objectid/src/objectid/objectid.dart';
import 'package:realm/realm.dart';

import 'base_repository.dart';

class ServerRepository extends BaseRepository {
  ServerRepository(super.db);

  Future addServer(ServerModel server) async {
    await db.writeAsync(() {
      db.add<ServerModel>(server);
    });
  }

  Future<void> deleteServer(ServerModel server) async {
    await db.writeAsync(() {
      db.delete<ServerModel>(server);
    });
  }

  ServerModel? getServerById(ObjectId id) {
    var serverModel = db.find<ServerModel>(id);
    return serverModel;
  }

  Future<void> updateServer(ServerModel server) async {
    await db.writeAsync(() {
      db.add<ServerModel>(server, update: true);
    });
  }

  RealmResults<ServerModel> getServers() {
    var servers = db.all<ServerModel>();
    return servers;
  }
}
