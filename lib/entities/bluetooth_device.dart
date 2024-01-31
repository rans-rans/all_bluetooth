part of "package:all_bluetooth/all_bluetooth.dart";

/// This object contains the information about the bluetooth device.
/// It contains the name and address of the device.
class BluetoothDevice {
  /// The name of the bluetooth device. It could be null,
  /// in which case, "unknown device" is returned
  final String name;

  /// The is the address of the bluetooth device, specifically the MAC address.
  final String address;

  /// The tells the bonded state of the device
  final bool bondedState;
  BluetoothDevice({
    required this.name,
    required this.address,
    required this.bondedState,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'bonded_state': bondedState,
    };
  }

  factory BluetoothDevice.fromMap(Object? data) {
    final map = HelperFunctions.convertToMap(data);
    return BluetoothDevice(
      name: map['name'],
      address: map['address'],
      bondedState: map['bonded_state'],
    );
  }

  @override
  String toString() =>
      'BluetoothDevice(name: $name, address: $address, bonded_state: $bondedState)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BluetoothDevice &&
        other.name == name &&
        other.bondedState == bondedState &&
        other.address == address;
  }

  @override
  int get hashCode => name.hashCode ^ bondedState.hashCode ^ address.hashCode;
}
