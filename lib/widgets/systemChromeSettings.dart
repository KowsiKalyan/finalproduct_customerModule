import 'package:flutter/services.dart';

class SystemChromeSettings {
  static setSystemButtomNavigationBarithTopAndButtom() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
    );
  }

  static setSystemUIOverlayStyleWithLightBrightNess() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  static setSystemUIOverlayStyleWithDarkBrightNess() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  static setSystemUIOverlayStyleWithNoSpecification() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }
  // static setSystemUIOverlayStyleWithLightBrightNess() {
  //   SystemChrome.setSystemUIOverlayStyle(
  //     const SystemUiOverlayStyle(
  //       statusBarColor: Colors.transparent,
  //       statusBarIconBrightness: Brightness.light,
  //     ),
  //   );
  // }

  // static setSystemUIOverlayStyleWithDarkBrightNess() {
  //   SystemChrome.setSystemUIOverlayStyle(
  //     const SystemUiOverlayStyle(
  //       statusBarColor: Colors.transparent,
  //       statusBarIconBrightness: Brightness.dark,
  //     ),
  //   );
  // }

  // static setSystemUIOverlayStyleWithNoSpecification() {
  //   SystemChrome.setSystemUIOverlayStyle(
  //     const SystemUiOverlayStyle(
  //       statusBarColor: Colors.transparent,
  //     ),
  //   );
  // }
}
