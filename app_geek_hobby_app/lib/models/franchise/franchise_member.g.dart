// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'franchise_member.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FranchiseMemberAdapter extends TypeAdapter<FranchiseMember> {
  @override
  final int typeId = 27;

  @override
  FranchiseMember read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FranchiseMember(
      id: fields[0] as String,
      franchiseId: fields[1] as String,
      mediaId: fields[2] as String,
      role: fields[3] as String,
      order: fields[4] as int,
      isPrimary: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FranchiseMember obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.franchiseId)
      ..writeByte(2)
      ..write(obj.mediaId)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.order)
      ..writeByte(5)
      ..write(obj.isPrimary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FranchiseMemberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
