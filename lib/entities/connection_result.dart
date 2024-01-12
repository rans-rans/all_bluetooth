part of "package:all_bluetooth/all_bluetooth.dart";

final class ConnectionResult {
  /// This boolean tells us whether the connection was successful or not
  final bool state;

  /// This contains the response message from a connection. It tells you whether
  /// your connection was successful or a failure, in which case will tell you
  /// where the failure occurred
  final String response;

  /// This is the bluetooth device that we get when we have a successful connection.
  /// If our bluetooth connection wasn't successful, then null will be returned
  final BluetoothDevice? device;
  ConnectionResult({
    required this.state,
    required this.response,
    this.device,
  });

  Map<String, dynamic> toMap() {
    return {
      'state': state,
      'response': response,
      'device': device?.toMap(),
    };
  }

  factory ConnectionResult.fromMap(Map<String, dynamic> map) {
    BluetoothDevice? device;

    final status = map["status"];
    final response = map["response"];

    if (status) {
      device = BluetoothDevice.fromMap(map);
    }
    return ConnectionResult(
      device: device,
      response: response,
      state: status,
    );
  }
  @override
  String toString() =>
      'ConnectionStatus(state: $state, response: $response, device: $device)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConnectionResult &&
        other.state == state &&
        other.response == response &&
        other.device == device;
  }

  @override
  int get hashCode => state.hashCode ^ response.hashCode ^ device.hashCode;
}
