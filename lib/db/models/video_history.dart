import 'package:realm/realm.dart';

part 'video_history.realm.dart';

@RealmModel()
class _VideoHistory {
  @PrimaryKey()
  late ObjectId id;
  late String path;
  late String url;
  late String token;
  late int duration;
  late int position;
  late ObjectId serverId;
  late DateTime createdTime;
  late DateTime updatedTime;
}
