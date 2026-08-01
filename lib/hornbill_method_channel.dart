import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hornbill_platform_interface.dart';

/// An implementation of [HornbillPlatform] that uses method channels.
class MethodChannelHornbill extends HornbillPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hornbill');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
