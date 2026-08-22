// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaAdapter extends TypeAdapter<Media> {
  @override
  final int typeId = 25;

  @override
  Media read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Media(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as String,
      studioId: fields[3] as String?,
      franchiseId: fields[4] as String?,
      releaseYear: fields[5] as int,
      imageUrl: fields[6] as String?,
      description: fields[7] as String?,
      genres: (fields[8] as List?)?.cast<String>(),
      platforms: (fields[9] as List?)?.cast<String>(),
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Media obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.studioId)
      ..writeByte(4)
      ..write(obj.franchiseId)
      ..writeByte(5)
      ..write(obj.releaseYear)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.genres)
      ..writeByte(9)
      ..write(obj.platforms)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
