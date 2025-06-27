// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_history.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class VideoHistory extends _VideoHistory
    with RealmEntity, RealmObjectBase, RealmObject {
  VideoHistory(
    ObjectId id,
    String path,
    String url,
    String token,
    int duration,
    ObjectId serverId,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'path', path);
    RealmObjectBase.set(this, 'url', url);
    RealmObjectBase.set(this, 'token', token);
    RealmObjectBase.set(this, 'duration', duration);
    RealmObjectBase.set(this, 'serverId', serverId);
  }

  VideoHistory._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get path => RealmObjectBase.get<String>(this, 'path') as String;
  @override
  set path(String value) => RealmObjectBase.set(this, 'path', value);

  @override
  String get url => RealmObjectBase.get<String>(this, 'url') as String;
  @override
  set url(String value) => RealmObjectBase.set(this, 'url', value);

  @override
  String get token => RealmObjectBase.get<String>(this, 'token') as String;
  @override
  set token(String value) => RealmObjectBase.set(this, 'token', value);

  @override
  int get duration => RealmObjectBase.get<int>(this, 'duration') as int;
  @override
  set duration(int value) => RealmObjectBase.set(this, 'duration', value);

  @override
  ObjectId get serverId =>
      RealmObjectBase.get<ObjectId>(this, 'serverId') as ObjectId;
  @override
  set serverId(ObjectId value) => RealmObjectBase.set(this, 'serverId', value);

  @override
  Stream<RealmObjectChanges<VideoHistory>> get changes =>
      RealmObjectBase.getChanges<VideoHistory>(this);

  @override
  Stream<RealmObjectChanges<VideoHistory>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<VideoHistory>(this, keyPaths);

  @override
  VideoHistory freeze() => RealmObjectBase.freezeObject<VideoHistory>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'path': path.toEJson(),
      'url': url.toEJson(),
      'token': token.toEJson(),
      'duration': duration.toEJson(),
      'serverId': serverId.toEJson(),
    };
  }

  static EJsonValue _toEJson(VideoHistory value) => value.toEJson();
  static VideoHistory _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'path': EJsonValue path,
        'url': EJsonValue url,
        'token': EJsonValue token,
        'duration': EJsonValue duration,
        'serverId': EJsonValue serverId,
      } =>
        VideoHistory(
          fromEJson(id),
          fromEJson(path),
          fromEJson(url),
          fromEJson(token),
          fromEJson(duration),
          fromEJson(serverId),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(VideoHistory._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      VideoHistory,
      'VideoHistory',
      [
        SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
        SchemaProperty('path', RealmPropertyType.string),
        SchemaProperty('url', RealmPropertyType.string),
        SchemaProperty('token', RealmPropertyType.string),
        SchemaProperty('duration', RealmPropertyType.int),
        SchemaProperty('serverId', RealmPropertyType.objectid),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
