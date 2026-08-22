// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollectionItemAdapter extends TypeAdapter<CollectionItem> {
  @override
  final int typeId = 33;

  @override
  CollectionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollectionItem(
      id: fields[0] as String,
      collectionId: fields[1] as String,
      mediaId: fields[2] as String,
      order: fields[3] as int,
      addedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CollectionItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.collectionId)
      ..writeByte(2)
      ..write(obj.mediaId)
      ..writeByte(3)
      ..write(obj.order)
      ..writeByte(4)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
