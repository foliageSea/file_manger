part of '../server_service.dart';

class ServerServiceImpl with AppDatabaseMixin implements ServerService {
  late ServerRepository serverRepository;

  ServerServiceImpl() {
    serverRepository = ServerRepository(db);
  }

  @override
  Future<void> addServer(ServerModel server) async {
    await serverRepository.addServer(server);
  }

  @override
  Future<void> deleteServer(ServerModel server) async {
    await serverRepository.deleteServer(server);
  }

  @override
  ServerModel? getServerById(ObjectId id) {
    return serverRepository.getServerById(id);
  }

  @override
  Future<void> updateServer(ServerModel server) async {
    await serverRepository.updateServer(server);
  }

  @override
  List<ServerModel> getServers() {
    return serverRepository.getServers().toList();
  }
}
