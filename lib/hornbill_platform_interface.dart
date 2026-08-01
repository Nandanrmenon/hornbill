import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hornbill_method_channel.dart';

abstract class HornbillPlatform extends PlatformInterface {
  /// Constructs a HornbillPlatform.
  HornbillPlatform() : super(token: _token);

  static final Object _token = Object();

  static HornbillPlatform _instance = MethodChannelHornbill();

  /// The default instance of [HornbillPlatform] to use.
  ///
  /// Defaults to [MethodChannelHornbill].
  static HornbillPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HornbillPlatform] when
  /// they register themselves.
  static set instance(HornbillPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
