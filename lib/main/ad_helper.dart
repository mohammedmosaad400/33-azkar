import 'dart:io';

class AdHelper {
  static String get interstitialAdUnitId{
    if(Platform.isAndroid){
      return "ca-app-pub-7980797173218475/7894142474";
    }
    else {
      throw UnsupportedError('unsupported platform');
    }
  }

  static String get bannerAdUnitId{
    if(Platform.isAndroid){
      return "ca-app-pub-7980797173218475/6852523548";
    }
    else {
      throw UnsupportedError('unsupported platform');
    }
  }

}