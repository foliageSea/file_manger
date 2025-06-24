// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'star_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class StarModel extends _StarModel
    with RealmEntity, RealmObjectBase, RealmObject {
  StarModel(ObjectId id, String name, String path, ObjectId serverId) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'path', path);
    RealmObjectBase.set(this, 'serverId', serverId);
  }

  StarModel._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get path => RealmObjectBase.get<String>(this, 'path') as String;
  @override
  set path(String value) => RealmObjectBase.set(this, 'path', value);

  @override
  ObjectId get serverId =>
      RealmObjectBase.get<ObjectId>(this, 'serverId') as ObjectId;
  @override
  set serverId(ObjectId value) => RealmObjectBase.set(this, 'serverId', value);

  @override
  Stream<RealmObjectChanges<StarModel>> get changes =>
      RealmObjectBase.getChanges<StarModel>(this);

  @override
  Stream<RealmObjectChanges<StarModel>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<StarModel>(this, keyPaths);

  @override
  StarModel freeze() => RealmObjectBase.freezeObject<StarModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'path': path.toEJson(),
      'serverId': serverId.toEJson(),
    };
  }

  static EJsonValue _toEJson(StarModel value) => value.toEJson();
  static StarModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'path': EJsonValue path,
        'serverId': EJsonValue serverId,
      } =>
        StarModel(
          fromEJson(id),
          fromEJson(name),
          fromEJson(path),
          fromEJson(serverId),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(StarModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, StarModel, 'StarModel', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('path', RealmPropertyType.string),
      SchemaProperty('serverId', RealmPropertyType.objectid),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
