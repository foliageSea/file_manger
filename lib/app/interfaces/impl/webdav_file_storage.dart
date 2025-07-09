part of '../file_storage.dart';

class WebDavFileStorage extends FileStorage {
  late Client client;
  late ServerModel server;

  @override
  Future init(ServerModel server) async {
    this.server = server;
    client = newClient(
      server.url,
      debug: false,
      user: server.username,
      password: server.password,
    );
  }

  @override
  Future<List<FileItem>> readDir(
    FileItem file, [
    CustomCancelToken? cancelToken,
  ]) async {
    var list = await client.readDir(file.path!, cancelToken);

    var files = list
        .map(
          (e) => FileItem(
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
  Future<String> getUrl(FileItem file) async {
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

  @override
  ObjectId getServerId() {
    return server.id;
  }
}
