
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterAesEncrypt {
  static const MethodChannel _channel = MethodChannel('flutter_aes_encrypt');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 加密
  static Future<String?> aesEncrypt(String input, String key) async {
    if (input.isEmpty) {
      return null;
    }

    final String? encryptResult = await _channel.invokeMethod('aesEncrypt',
        <String, dynamic> {
          'input': input,
          'key': key,
        }
    );
    return encryptResult;
  }

  /// 解密
  static Future<String?> aesDecrypt(String input, String key) async {
    if (input.isEmpty) {
      return null;
    }

    final String? decryptResult = await _channel.invokeMethod('aesDecrypt',
        <String, dynamic> {
          'input': input,
          'key': key,
        }
    );
    return decryptResult;
  }
}
