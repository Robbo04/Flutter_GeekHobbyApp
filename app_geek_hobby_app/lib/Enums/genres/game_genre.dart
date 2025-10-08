import 'package:hive/hive.dart';

part 'game_genre.g.dart';

@HiveType(typeId: 22)
enum GameGenre {
  @HiveField(0)
  action,
  @HiveField(1)
  adventure,
  @HiveField(2) 
  rpg,
  @HiveField(3)
  simulation,
  @HiveField(4)
  strategy,
  @HiveField(5)
  sports,
  @HiveField(6)
  puzzle,
  @HiveField(7)
  horror,
  @HiveField(8)
  racing,
  @HiveField(9)
  fighting,
  @HiveField(10)  
  platformer,
  @HiveField(11)
  shooter,
  @HiveField(12)
  mmorpg,
  @HiveField(13)
  indie,
  @HiveField(14)
  casual,
  @HiveField(15)
  survival,
  @HiveField(16)
  rhythm,
  @HiveField(17)
  sandbox,
  @HiveField(18)
  openWorld,
  @HiveField(19)
  stealth,
  @HiveField(20)
  party,
  @HiveField(21)
  educational,
  @HiveField(22)  
  other
}

extension GameGenreExtension on GameGenre {
  static GameGenre fromRawg(String slug) {
    switch (slug) {
      case 'action':
        return GameGenre.action;
      case 'adventure':
        return GameGenre.adventure;
      case 'role-playing-games-rpg':
      case 'rpg':
        return GameGenre.rpg;
      case 'simulation':
        return GameGenre.simulation;
      case 'strategy':
        return GameGenre.strategy;
      case 'sports':
        return GameGenre.sports;
      case 'puzzle':
        return GameGenre.puzzle;
      case 'horror':
        return GameGenre.horror;
      case 'racing':
        return GameGenre.racing;
      case 'fighting':
        return GameGenre.fighting;
      case 'platformer':
        return GameGenre.platformer;
      case 'shooter':
        return GameGenre.shooter;
      case 'mmorpg':
        return GameGenre.mmorpg;
      case 'indie':
        return GameGenre.indie;
      case 'casual':
        return GameGenre.casual;
      case 'survival':
        return GameGenre.survival;
      case 'rhythm':
        return GameGenre.rhythm;
      case 'sandbox':
        return GameGenre.sandbox;
      case 'open-world':
        return GameGenre.openWorld;
      case 'stealth':
        return GameGenre.stealth;
      case 'party':
        return GameGenre.party;
      case 'educational':
        return GameGenre.educational;
      default:
        print('Unknown genre slug: $slug');
        return GameGenre.other;
    }
  }
}