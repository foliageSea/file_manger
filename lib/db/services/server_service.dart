import 'package:file_manger/db/models/server_model.dart';
import 'package:realm/realm.dart';

import '../database.dart';
import '../repositories/server_repository.dart';

part 'impl/server_service_impl.dart';

abstract class ServerService {
  RealmResults<ServerModel> getServers();

  Future<void> addServer(ServerModel server);

  Future<void> deleteServer(ServerModel server);

  Future<void> updateServer(ServerModel server);

  ServerModel? getServerById(ObjectId id);
}
