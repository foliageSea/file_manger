import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:file_manger/db/models/server_model.dart';
import 'package:webdav_client/webdav_client.dart';

abstract class FileStorage {
  Future init(ServerModel server);

  Future<List<StorageFileItem>> readDir(StorageFileItem file);

  Future<String> getUrl(StorageFileItem file);

  String getAuth();
}

class WebDavFileStorage extends FileStorage {
  late Client client;

  @override
  Future init(ServerModel server) async {
    client = newClient(
      server.url,
      debug: false,
      user: server.username,
      password: server.password,
    );
  }

  @override
  Future<List<StorageFileItem>> readDir(StorageFileItem file) async {
    var list = await client.readDir(file.path!);

    var files = list
        .map(
          (e) => StorageFileItem(
            path: e.path,
            isDir: e.isDir,
            name: e.name,
            mimeType: e.mimeType,
            size: e.size,
            eTag: e.eTag,
            cTime: e.cTime,
            mTime: e.mTime,
          ),
        )
        .toList();

    return files;
  }

  @override
  Future<String> getUrl(StorageFileItem file) async {
    var uri = client.uri.slice(0, client.uri.length - 2);
    var path = file.path;
    var url = Uri.encodeFull('$uri$path');
    return url;
  }

  @override
  String getAuth() {
    var auth = client.auth;
    var user = auth.user;
    var pwd = auth.pwd;

    String getWebDavAuth() =>
        'Basic ${base64Encode(utf8.encode('$user:$pwd'))}';

    return getWebDavAuth();
  }
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
