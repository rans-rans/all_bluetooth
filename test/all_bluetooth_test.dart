import 'package:all_bluetooth/all_bluetooth.dart';
import 'package:all_bluetooth/all_bluetooth_method_channel.dart';
import 'package:all_bluetooth/all_bluetooth_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAllBluetoothPlatform
    with MockPlatformInterfaceMixin
    implements AllBluetoothPlatform {
  @override
  @override
  Stream<bool> get listenToBluetoothState {
    throw UnimplementedError();
  }

  @override
  Future<bool> isBluetoothOn() {
    throw UnimplementedError();
  }

  @override
  Future<List<BluetoothDevice>> getBondedDevices() {
    throw UnimplementedError();
  }

  @override
  Future<void> connectToDevice(String address) {
    throw UnimplementedError();
  }

  @override
  Future<bool> sendMessage(String message) {
    throw UnimplementedError();
  }

  @override
  Future<void> startBluetoothServer() {
    throw UnimplementedError();
  }

  @override
  Future<void> closeConnection() {
    throw UnimplementedError();
  }

  @override
  Stream<ConnectionResult> get listenForConnection {
    throw UnimplementedError();
  }

  @override
  Stream<String> get listenForData {
    throw UnimplementedError();
  }

  @override
  Stream<BluetoothDevice> get discoverDevices => throw UnimplementedError();

  @override
  Future<void> startDiscovery() {
    throw UnimplementedError();
  }

  @override
  Future<void> stopDiscovery() {
    throw UnimplementedError();
  }
}

void main() {
  final AllBluetoothPlatform initialPlatform = AllBluetoothPlatform.instance;

  test('$MethodChannelAllBluetooth is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAllBluetooth>());
  });

  test('getPlatformVersion', () async {
    MockAllBluetoothPlatform fakePlatform = MockAllBluetoothPlatform();
    AllBluetoothPlatform.instance = fakePlatform;
  });
}
