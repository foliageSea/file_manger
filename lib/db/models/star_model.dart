import 'package:realm/realm.dart';

part 'star_model.realm.dart';

@RealmModel()
class _StarModel {
  @PrimaryKey()
  late ObjectId id;
  late String name;
  late String path;
  late ObjectId serverId;
}
