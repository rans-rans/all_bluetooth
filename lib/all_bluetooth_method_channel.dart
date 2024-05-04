import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'all_bluetooth.dart';
import 'all_bluetooth_platform_interface.dart';

/// An implementation of [AllBluetoothPlatform] that uses method channels.
final class MethodChannelAllBluetooth extends AllBluetoothPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('com.rans_innovations/all_bluetooth');

  final bluetoothChangeEvent = const EventChannel("bluetooth_change_event");
  final connectionChange = const EventChannel("connection_change_event");
  final sendReceiveEvent = const EventChannel("send_receive_event");
  final foundDeviceEvent = const EventChannel("found_device_event");

  @override
  Future<void> closeConnection() async {
    methodChannel.invokeMethod("close_connection");
  }

  @override
  Future<void> connectToDevice(String address) async {
    methodChannel.invokeMethod("connect_to_device", address);
  }

  @override
  Future<List<BluetoothDevice>> getBondedDevices() async {
    final response =
        await methodChannel.invokeMethod("get_bonded_devices") as List<Object?>;
    final devices = response.map(BluetoothDevice.fromMap);
    return devices.toList();
  }

  @override
  Future<bool> isBluetoothOn() async {
    try {
      final response = await methodChannel.invokeMethod("is_bluetooth_on");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> startBluetoothServer({int? timeout}) async {
    methodChannel.invokeMethod("start_server", timeout);
  }

  @override
  Future<void> startAdvertising({int? secondDuration}) async {
    methodChannel.invokeMethod("start_advertising", secondDuration);
  }

  @override
  Future<bool> sendMessage(String message) async {
    final response =
        await methodChannel.invokeMethod("send_message", message) as bool;
    return response;
  }

  @override
  Future<void> startDiscovery() async {
    methodChannel.invokeMethod("start_discovery");
  }

  @override
  Future<void> stopDiscovery() async {
    methodChannel.invokeMethod("stop_discovery");
  }

  @override
  Stream<BluetoothDevice> get discoverDevices {
    final stream = foundDeviceEvent.receiveBroadcastStream().map(
      (event) {
        final data =
            HelperFunctions.convertToMap(event as Map<Object?, Object?>);
        final device = BluetoothDevice.fromMap(data);
        return device;
      },
    );
    return stream;
  }

  @override
  Stream<bool> get listenToBluetoothState {
    final stream = bluetoothChangeEvent.receiveBroadcastStream().map((event) {
      return event as bool;
    });
    return stream;
  }

  @override
  Stream<ConnectionResult> get listenForConnection {
    final stream = connectionChange.receiveBroadcastStream().map((event) {
      final data =
          HelperFunctions.convertToMap((event as Map<Object?, Object?>));
      final connectionResult = ConnectionResult.fromMap(data);
      return connectionResult;
    });
    return stream;
  }

  @override
  Stream<String?> get listenForData {
    final stream = sendReceiveEvent.receiveBroadcastStream().map((event) {
      if (event["status"] == false) return null;
      return event["response"].toString();
    });
    return stream;
  }
}
