// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_age.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameAgeAdapter extends TypeAdapter<GameAge> {
  @override
  final int typeId = 21;

  @override
  GameAge read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GameAge.pegi3;
      case 1:
        return GameAge.pegi7;
      case 2:
        return GameAge.pegi12;
      case 3:
        return GameAge.pegi16;
      case 4:
        return GameAge.pegi18;
      default:
        return GameAge.pegi3;
    }
  }

  @override
  void write(BinaryWriter writer, GameAge obj) {
    switch (obj) {
      case GameAge.pegi3:
        writer.writeByte(0);
        break;
      case GameAge.pegi7:
        writer.writeByte(1);
        break;
      case GameAge.pegi12:
        writer.writeByte(2);
        break;
      case GameAge.pegi16:
        writer.writeByte(3);
        break;
      case GameAge.pegi18:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameAgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
