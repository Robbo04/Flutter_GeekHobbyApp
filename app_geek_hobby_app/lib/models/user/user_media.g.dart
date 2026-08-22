// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_media.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserMediaAdapter extends TypeAdapter<UserMedia> {
  @override
  final int typeId = 31;

  @override
  UserMedia read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserMedia(
      id: fields[0] as String,
      userId: fields[1] as String,
      mediaId: fields[2] as String,
      status: fields[3] as String,
      progress: fields[4] as int,
      rating: fields[5] as int?,
      notes: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserMedia obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.mediaId)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.progress)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMediaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
