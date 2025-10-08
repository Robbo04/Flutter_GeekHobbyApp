// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_platform.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GamePlatformAdapter extends TypeAdapter<GamePlatform> {
  @override
  final int typeId = 23;

  @override
  GamePlatform read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GamePlatform.pc;
      case 1:
        return GamePlatform.playstation;
      case 2:
        return GamePlatform.xbox;
      case 3:
        return GamePlatform.nintendo;
      case 4:
        return GamePlatform.mobile;
      case 5:
        return GamePlatform.vr;
      case 6:
        return GamePlatform.other;
      default:
        return GamePlatform.pc;
    }
  }

  @override
  void write(BinaryWriter writer, GamePlatform obj) {
    switch (obj) {
      case GamePlatform.pc:
        writer.writeByte(0);
        break;
      case GamePlatform.playstation:
        writer.writeByte(1);
        break;
      case GamePlatform.xbox:
        writer.writeByte(2);
        break;
      case GamePlatform.nintendo:
        writer.writeByte(3);
        break;
      case GamePlatform.mobile:
        writer.writeByte(4);
        break;
      case GamePlatform.vr:
        writer.writeByte(5);
        break;
      case GamePlatform.other:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamePlatformAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
