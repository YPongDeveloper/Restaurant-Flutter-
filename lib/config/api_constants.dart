import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static String baseUrl = _getBaseUrl();
  static String employeesAPI = '$baseUrl/employee';
  static String foodAPI = '$baseUrl/food';
  static String orderAPI = '$baseUrl/order';

  static String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080'; // สำหรับ Web
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080'; // สำหรับ Android
    } else {
      return 'http://localhost:8080'; // สำหรับแพลตฟอร์มอื่น (เช่น iOS, Desktop)
    }
  }
}
