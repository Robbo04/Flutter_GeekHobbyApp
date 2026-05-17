// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimeGroupAdapter extends TypeAdapter<AnimeGroup> {
  @override
  final int typeId = 7;

  @override
  AnimeGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnimeGroup(
      groupId: fields[0] as int,
      name: fields[1] as String,
      animeIds: (fields[2] as List).cast<int>(),
      imageUrl: fields[3] as String?,
      yearReleased: fields[4] as int,
      studio: fields[5] as String,
      lastUpdated: fields[6] as DateTime,
      relationTypes: (fields[7] as Map?)?.cast<int, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AnimeGroup obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.groupId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.animeIds)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.yearReleased)
      ..writeByte(5)
      ..write(obj.studio)
      ..writeByte(6)
      ..write(obj.lastUpdated)
      ..writeByte(7)
      ..write(obj.relationTypes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
