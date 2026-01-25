// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroupItemAdapter extends TypeAdapter<GroupItem> {
  @override
  final int typeId = 6;

  @override
  GroupItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupItem(
      name: fields[0] as String,
      studio: fields[1] as String,
      yearReleased: fields[5] as int,
      imageUrl: fields[2] as String?,
      items: (fields[7] as List).cast<Item>(),
    )
      ..owned = fields[3] as bool
      ..wishlist = fields[4] as bool
      ..userRating = fields[6] as int;
  }

  @override
  void write(BinaryWriter writer, GroupItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(7)
      ..write(obj.items)
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
      other is GroupItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
