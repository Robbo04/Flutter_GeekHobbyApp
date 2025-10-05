enum GameGenre {
  action,
  adventure,
  rpg,
  simulation,
  strategy,
  sports,
  puzzle,
  horror,
  racing,
  fighting,
  platformer,
  shooter,
  mmorpg,
  indie,
  casual,
  survival,
  rhythm,
  sandbox,
  openWorld,
  stealth,
  party,
  educational,
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