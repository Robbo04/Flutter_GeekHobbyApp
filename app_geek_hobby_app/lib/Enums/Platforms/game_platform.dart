enum GamePlatform {
  pc,
  playstation,
  xbox,
  nintendo,
  mobile,
  vr,
  other
}

extension GamePlatformExtension on GamePlatform {
  static GamePlatform fromRawg(String slug) {
    switch (slug) {
      case 'pc':
        return GamePlatform.pc;

      case 'playstation':
      case 'playstation2':
      case 'playstation3':
      case 'playstation4':
      case 'playstation5':
        return GamePlatform.playstation;

      case 'xbox':
      case 'xbox-360':
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
        return GamePlatform.other;
    }
  }
}