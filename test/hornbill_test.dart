import 'package:flutter_test/flutter_test.dart';
import 'package:hornbill/hornbill.dart';
import 'package:hornbill/hornbill_platform_interface.dart';
import 'package:hornbill/hornbill_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHornbillPlatform
    with MockPlatformInterfaceMixin
    implements HornbillPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final HornbillPlatform initialPlatform = HornbillPlatform.instance;

  test('$MethodChannelHornbill is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHornbill>());
  });

  test('getPlatformVersion', () async {
    Hornbill hornbillPlugin = Hornbill();
    MockHornbillPlatform fakePlatform = MockHornbillPlatform();
    HornbillPlatform.instance = fakePlatform;

    expect(await hornbillPlugin.getPlatformVersion(), '42');
  });
}
