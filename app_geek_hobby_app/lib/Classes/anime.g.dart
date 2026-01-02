// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimeAdapter extends TypeAdapter<Anime> {
  @override
  final int typeId = 5;

  @override
  Anime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Anime(
      id: fields[7] as int,
      name: fields[0] as String,
      studio: fields[1] as String,
      yearReleased: fields[5] as int,
      imageUrl: fields[2] as String?,
      isMovie: fields[8] as bool,
      seasons: fields[9] as int,
      episodes: fields[10] as int,
      runtime: fields[11] as int,
    )
      ..owned = fields[3] as bool
      ..wishlist = fields[4] as bool
      ..userRating = fields[6] as int;
  }

  @override
  void write(BinaryWriter writer, Anime obj) {
    writer
      ..writeByte(12)
      ..writeByte(7)
      ..write(obj.id)
      ..writeByte(8)
      ..write(obj.isMovie)
      ..writeByte(9)
      ..write(obj.seasons)
      ..writeByte(10)
      ..write(obj.episodes)
      ..writeByte(11)
      ..write(obj.runtime)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.studio)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.owned)
      ..writeByte(4)
      ..write(obj.wishlist)
      ..writeByte(5)
      ..write(obj.yearReleased)
      ..writeByte(6)
      ..write(obj.userRating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
