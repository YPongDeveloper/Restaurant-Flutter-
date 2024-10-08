// lib/utils/screen_ratio.dart
import 'package:flutter/widgets.dart';

class ScreenRatio {
  static double getRatio(BuildContext context) {
    return MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
  }
}
