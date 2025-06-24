import 'package:file_manger/db/models/star_model.dart';
import 'package:file_manger/db/repositories/base_repository.dart';
import 'package:realm_dart/src/results.dart';

class StarRepository extends BaseRepository {
  StarRepository(super.db);

  Future<void> addStar(StarModel star) async {
    await db.writeAsync(() {
      db.add<StarModel>(star);
    });
  }

  RealmResults<StarModel> getStars() {
    RealmResults<StarModel> results = db.all<StarModel>();
    return results;
  }

  Future<void> removeStar(StarModel star) async {
    await db.writeAsync(() {
      db.delete<StarModel>(star);
    });
  }
}
