// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_genre.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameGenreAdapter extends TypeAdapter<GameGenre> {
  @override
  final int typeId = 22;

  @override
  GameGenre read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GameGenre.action;
      case 1:
        return GameGenre.adventure;
      case 2:
        return GameGenre.rpg;
      case 3:
        return GameGenre.simulation;
      case 4:
        return GameGenre.strategy;
      case 5:
        return GameGenre.sports;
      case 6:
        return GameGenre.puzzle;
      case 7:
        return GameGenre.horror;
      case 8:
        return GameGenre.racing;
      case 9:
        return GameGenre.fighting;
      case 10:
        return GameGenre.platformer;
      case 11:
        return GameGenre.shooter;
      case 12:
        return GameGenre.mmorpg;
      case 13:
        return GameGenre.indie;
      case 14:
        return GameGenre.casual;
      case 15:
        return GameGenre.survival;
      case 16:
        return GameGenre.rhythm;
      case 17:
        return GameGenre.sandbox;
      case 18:
        return GameGenre.openWorld;
      case 19:
        return GameGenre.stealth;
      case 20:
        return GameGenre.party;
      case 21:
        return GameGenre.educational;
      case 22:
        return GameGenre.other;
      default:
        return GameGenre.action;
    }
  }

  @override
  void write(BinaryWriter writer, GameGenre obj) {
    switch (obj) {
      case GameGenre.action:
        writer.writeByte(0);
        break;
      case GameGenre.adventure:
        writer.writeByte(1);
        break;
      case GameGenre.rpg:
        writer.writeByte(2);
        break;
      case GameGenre.simulation:
        writer.writeByte(3);
        break;
      case GameGenre.strategy:
        writer.writeByte(4);
        break;
      case GameGenre.sports:
        writer.writeByte(5);
        break;
      case GameGenre.puzzle:
        writer.writeByte(6);
        break;
      case GameGenre.horror:
        writer.writeByte(7);
        break;
      case GameGenre.racing:
        writer.writeByte(8);
        break;
      case GameGenre.fighting:
        writer.writeByte(9);
        break;
      case GameGenre.platformer:
        writer.writeByte(10);
        break;
      case GameGenre.shooter:
        writer.writeByte(11);
        break;
      case GameGenre.mmorpg:
        writer.writeByte(12);
        break;
      case GameGenre.indie:
        writer.writeByte(13);
        break;
      case GameGenre.casual:
        writer.writeByte(14);
        break;
      case GameGenre.survival:
        writer.writeByte(15);
        break;
      case GameGenre.rhythm:
        writer.writeByte(16);
        break;
      case GameGenre.sandbox:
        writer.writeByte(17);
        break;
      case GameGenre.openWorld:
        writer.writeByte(18);
        break;
      case GameGenre.stealth:
        writer.writeByte(19);
        break;
      case GameGenre.party:
        writer.writeByte(20);
        break;
      case GameGenre.educational:
        writer.writeByte(21);
        break;
      case GameGenre.other:
        writer.writeByte(22);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameGenreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
