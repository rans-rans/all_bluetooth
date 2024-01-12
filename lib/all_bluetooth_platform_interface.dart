import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'all_bluetooth.dart';
import 'all_bluetooth_method_channel.dart';

abstract class AllBluetoothPlatform extends PlatformInterface {
  /// Constructs a AllBluetoothPlatform.
  AllBluetoothPlatform() : super(token: _token);

  static final Object _token = Object();

  static AllBluetoothPlatform _instance = MethodChannelAllBluetooth();

  /// The default instance of [AllBluetoothPlatform] to use.
  ///
  /// Defaults to [MethodChannelAllBluetooth].
  static AllBluetoothPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AllBluetoothPlatform] when
  /// they register themselves.
  static set instance(AllBluetoothPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> closeConnection();

  Future<void> connectToDevice(String address);

  Future<List<BluetoothDevice>> getBondedDevices();

  Future<bool> isBluetoothOn();

  Future<void> startBluetoothServer();

  Future<bool> sendMessage(String message);

  Stream<bool> get listenToBluetoothState;

  Stream<String?> get listenForData;

  Stream<ConnectionResult> get listenForConnection;
}
