import 'dart:convert';

import 'package:core/core.dart';
import 'package:dartx/dartx.dart';
import 'package:file_manger/db/models/server_model.dart';
import 'package:realm/realm.dart';
import 'package:webdav_client/webdav_client.dart';

part 'impl/webdav_file_storage.dart';

abstract class FileStorage {
  Future init(ServerModel server);

  Future<List<FileItem>> readDir(
    FileItem file, [
    CustomCancelToken? cancelToken,
  ]);

  Future<String> getUrl(FileItem file);

  String getAuth();

  ObjectId getServerId();
}

class FileItem {
  String? path;
  bool? isDir;
  String? name;
  String? mimeType;
  int? size;
  String? eTag;
  DateTime? cTime;
  DateTime? mTime;

  FileItem({
    this.path,
    this.isDir,
    this.name,
    this.mimeType,
    this.size,
    this.eTag,
    this.cTime,
    this.mTime,
  });

  FileItem copy() {
    return FileItem()
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
