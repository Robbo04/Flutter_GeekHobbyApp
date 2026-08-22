// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'studio.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudioAdapter extends TypeAdapter<Studio> {
  @override
  final int typeId = 28;

  @override
  Studio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Studio(
      id: fields[0] as String,
      name: fields[1] as String,
      country: fields[2] as String?,
      logoUrl: fields[3] as String?,
      createdAt: fields[4] as DateTime?,
      updatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Studio obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.country)
      ..writeByte(3)
      ..write(obj.logoUrl)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
