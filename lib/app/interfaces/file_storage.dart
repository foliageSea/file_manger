import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:file_manger/db/models/server_model.dart';
import 'package:realm/realm.dart';
import 'package:webdav_client/webdav_client.dart';

part 'impl/file_storage_impl.dart';

abstract class FileStorage {
  Future init(ServerModel server);

  Future<List<StorageFileItem>> readDir(StorageFileItem file);

  Future<String> getUrl(StorageFileItem file);

  String getAuth();

  ObjectId getServerId();
}

class StorageFileItem {
  String? path;
  bool? isDir;
  String? name;
  String? mimeType;
  int? size;
  String? eTag;
  DateTime? cTime;
  DateTime? mTime;

  StorageFileItem({
    this.path,
    this.isDir,
    this.name,
    this.mimeType,
    this.size,
    this.eTag,
    this.cTime,
    this.mTime,
  });

  StorageFileItem copy() {
    return StorageFileItem()
      ..path = path
      ..isDir = isDir
      ..name = name
      ..mimeType = mimeType
      ..size = size
      ..eTag = eTag
      ..cTime = cTime
      ..mTime = mTime;
  }
}
