library all_bluetooth;

import 'all_bluetooth_platform_interface.dart';

part "package:all_bluetooth/entities/bluetooth_device.dart";
part "package:all_bluetooth/entities/connection_result.dart";
part 'helper_functions.dart';

class AllBluetooth {
  final instance = AllBluetoothPlatform.instance;

  /// This function is used to close your bluetooth connection with another device and
  /// release all resources that was taken by the bluetooth connection.
  Future<void> closeConnection() async {
    return await instance.closeConnection();
  }

  /// This function is used to connect to another bluetooth device, using the other device's
  /// address. For this function to be successful, make sure the other device is connecting as
  /// a server because you connecting are the client
  ///
  /// **NOTE**:
  ///
  /// - It doesn't matter if you connect as client or server. Both parties can send and receive data.
  /// It is just how connections are formed, one should start as client and the other as
  /// server.
  /// <br/>
  ///
  /// - If you want to know the result of the function, you should always be used together with [listenForConnection]
  /// function which returns a stream, to know whether your connection was successful or not. This is
  /// because the success/failure result of bluetooth connections are not handle by the function itself but it is
  /// handled by a __broadcast receiver__ which is a separate.
  Future<void> connectToDevice(String address) async {
    return await instance.connectToDevice(address);
  }

  /// This function simply returns a list of [BluetoothDevice] that your phone have bonded to them
  /// before.
  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await instance.getBondedDevices();
  }

  /// This simply returns true if bluetooth is turned on and false if it is turned off
  Future<bool> isBluetoothOn() async {
    final isActive = await instance.isBluetoothOn();
    return isActive;
  }

  /// This function is used to open a server socket if you want to connect as a server. The opened socket
  /// will keep listening for clients unless you explictly close the bluetooth server with
  /// [closeConnection] function
  ///
  /// **NOTE**:
  ///
  /// - It doesn't matter if you connect as client or server. Both parties can send and receive data.
  /// It is just how connections are formed, one should start as client and the other as
  /// server.
  /// <br/>
  ///
  /// - If you want to know the result of the function, you should always be used together with ``[listenForConnection]``
  /// function which returns a stream, to know whether your connection was successful or not. This is
  /// because the success/failure result of bluetooth connections are not handle by the function itself but it is
  /// handled by a __broadcast receiver__ which is a separate.
  Future<void> startBluetoothServer() async {
    return await instance.startBluetoothServer();
  }

  /// Use this function to send data across your bluetooth connection. Your data is sent as raw text
  /// so you might want to perform your own encoding to ensure security when send and receiving
  /// the data.
  /// <br/>
  ///
  /// This function returns true if successful and false if unsuccessful
  Future<bool> sendMessage(String message) async {
    final response = await instance.sendMessage(message);
    return response;
  }

  /// This stream is used to listen for bluetooth connections.
  /// This connection contains the [ConnectionResult], that is, the status, the response message of
  /// that connection, and if the connection was successful, there will also be a [BluetoothDevice]
  ///  object also.
  Stream<ConnectionResult> get listenForConnection {
    return instance.listenForConnection;
  }

  /// The stream for listening for data/messages across a bluetooth connection. Make sure you use it with the
  /// [listenForConnection] stream so that you will be sure you are send across a proper connection
  Stream<String?> get listenForData {
    return instance.listenForData;
  }

  /// This stream is used to listen to the state of your device's bluetooth, whether it is
  /// turned on/off.<br/>
  /// If you change the state of your device bluetooth, this stream will
  /// emit a value corresponding to that state. So if you turn the bluetooth on, you get
  /// [true] and vice versa.
  Stream<bool> get streamBluetoothState async* {
    // first get the bluetooth state like this because first emitted value is null
    // this way, you are sure to get the bluetooth state of your device
    final isBluetoothOn = await instance.isBluetoothOn();
    yield isBluetoothOn;
    yield* instance.listenToBluetoothState;
  }
}
