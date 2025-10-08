import 'package:hive/hive.dart';

part 'game_platform.g.dart';

@HiveType(typeId: 23)
enum GamePlatform {
  @HiveField(0)
  pc,
  @HiveField(1)
  playstation,
  @HiveField(2) 
  xbox,
  @HiveField(3)
  nintendo,
  @HiveField(4)
  mobile,
  @HiveField(5)
  vr,
  @HiveField(6)
  other
}

extension GamePlatformExtension on GamePlatform {
  static GamePlatform fromRawg(String slug) {
    switch (slug) {
      case 'pc':
      case 'linux':
      case 'macos':
      case 'web':
        return GamePlatform.pc;

      case 'ps-vita':
      case 'playstation':
      case 'playstation2':
      case 'playstation3':
      case 'playstation4':
      case 'playstation5':
        return GamePlatform.playstation;

      case 'xbox':
      case 'xbox-old':
      case 'xbox360':
      case 'xbox-one':
      case 'xbox-series-x':
      case 'xbox-series-s':
        return GamePlatform.xbox; // Or create a separate enum for Series S if you want

      case 'nintendo-switch':
      case 'nintendo-3ds':
      case 'nintendo-ds':
      case 'nintendo-wii':
      case 'nintendo-wii-u':
        return GamePlatform.nintendo;

      case 'ios':
      case 'android':
      case 'mobile':
        return GamePlatform.mobile;

      case 'oculus-rift':
      case 'htc-vive':
      case 'playstation-vr':
      case 'valve-index':
      case 'windows-mixed-reality':
      case 'vr':
        return GamePlatform.vr;
      default:
        print('Unknown platform slug: $slug');
        return GamePlatform.other;
    }
  }
}