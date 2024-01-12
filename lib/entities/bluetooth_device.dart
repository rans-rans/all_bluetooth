part of "package:all_bluetooth/all_bluetooth.dart";

/// This object contains the information about the bluetooth device.
/// It contains the name and address of the device.
class BluetoothDevice {
  /// The name of the bluetooth device. It could be null,
  /// in which case, "unknown device" is returned
  final String name;

  /// The is the address of the bluetooth device, specifically the MAC address.
  final String address;
  BluetoothDevice({
    required this.name,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
    };
  }

  factory BluetoothDevice.fromMap(Object? data) {
    final map = HelperFunctions.convertToMap(data);
    return BluetoothDevice(
      name: map['name'],
      address: map['address'],
    );
  }

  @override
  String toString() => 'BluetoothDevice(name: $name, address: $address)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BluetoothDevice &&
        other.name == name &&
        other.address == address;
  }

  @override
  int get hashCode => name.hashCode ^ address.hashCode;
}
