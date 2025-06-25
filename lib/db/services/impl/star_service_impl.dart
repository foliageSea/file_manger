part of '../star_service.dart';

class StarServiceImpl with AppDatabaseMixin implements StarService {
  late StarRepository starRepository;
  late ServerRepository serverRepository;

  StarServiceImpl() {
    starRepository = StarRepository(db);
    serverRepository = ServerRepository(db);
  }

  @override
  Future<void> addStar(StarModel star) async {
    await starRepository.addStar(star);
  }

  @override
  List<StarModel> getStars() {
    return starRepository.getStars().toList();
  }

  @override
  Future<void> removeStar(StarModel star) async {
    await starRepository.removeStar(star);
  }

  @override
  List<StarFullItem> getStarsAndServer() {
    var stars = getStars();
    List<StarFullItem> list = [];
    for (var item in stars) {
      var server = serverRepository.getServerById(item.serverId);
      if (server != null) {
        list.add(StarFullItem(item, server));
      }
    }
    return list;
  }
}
