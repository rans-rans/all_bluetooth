# all_bluetooth

This is a flutter plugin for communicating with bluetooth devices.

### Features

- connect to a bluetooth devices
- returning a list of bonded devices is supported
- retrieving the Bluetooth state (on/off) as either a future or a stream.
- starting a bluetooth server
- listening to the state of a bluetooth connection
- listening for data across a bluetooth connection

### Getting Started

Add `all_bluetooth` as a dependency in your pubspec.yaml file

```
dependencies:
    all_bluetooth: ^<latest-version>
```

<br/>

Add these to your AndroidManifest.xml file and request the needed permissions. You can use the `permission_handler` package to request the needed permissions.

```
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
```

Create an instance in your app

```
final allBluetooth = AllBluetooth
```

#### Objects and classes

- Bluetooth device: The package provides you with the object to easily manage bluetooth devices. It has the following fields
  - device name: `String`
  - device address: `String`

<br/>

- ConnectionResult: This object tells you the state of your bluetooth connection. This object is what is emitted by the `listenToConnection` stream whenever your connection with another device change. It has the following fields:
  - state(`bool`) -> whether connected or not
  - response(`String`) -> the response message
  - device(`BluetoothDevice?`) -> the bluetooth device returned when connection is successful

#### Importing

```
import "package:all_bluetooth/all_bluetooth.dart";
```

### Usage

Before starting, take note that most functions are only going to work only if there is a bluetooth connection available. So always make sure you are streaming for the bluetooth connection state with the `listenForConnection` stream which emits `ConnectionResult`.

Methods like `listenToData` and `sendMessage` can only work properly if there is a proper bluetooth connection. You can also add validation like checking whether bluetooth turned on/off by using the `isBluetoothOn` method or `streamBluetoothState` stream before trying to call any function.

### Methods and Streams

- `closeConnection`: This function closes your Bluetooth connection with another device and release all resources that was taken by the bluetooth connection. This function is used to also close a bluetooth server

<br/>

- `connectToDevice`: This function is used to connect to another bluetooth device, using the other device's address. For this function to be successful, make sure the other device is connecting as a server because you connecting are the client

<br/>

- `getBondedDevices`: This function simply returns a list of `BluetoothDevice` that your phone have bonded to them before.

```
example

final devices = await allBluetooth.getBondedDevice();
print(devices)

output
[
    BluetoothDevice(name:"Device 1", address:"DA:4V:10:CE:17:00),
    BluetoothDevice(name:"Device 2", address:"DA:5V:10:CE:17:00),
    BluetoothDevice(name:"Device 3", address:"DA:6V:10:CE:17:00),
    BluetoothDevice(name:"Device 4", address:"DA:7V:10:CE:17:00),
 ]
```

<br/>

- `isBluetoothOn`: This simply returns true if bluetooth is turned on and false if it is turned off

<br/>

- `startBluetoothServer`: This function is used to open a server socket if you want to connect as a server. The opened socket will keep listening for clients unless you explictly close the bluetooth server with `closeConnection` function. Use the `listenForConnection` to listen for clients.

---

###### NOTE

- It doesn't matter if you connect as client or server. Both parties can send and receive data.
  It is just how connections are formed, one should start as client and the other as server.

  <br/>

- If you want to know the result of (startBluetoothServer and connectToDevice), you should always use them together with `listenForConnection` stream, to know whether your connection was successful or not. This is because the success/failure result of bluetooth connections are not handled by the function itself but it is handled by a **broadcast receiver** which is separate.

You can refer to main.dart in the example tab for reference

---

<br/>

- `sendMessage`: This function returns true if successful and false if unsuccessful for a message sent

<br/>

- `listenForConnection`: This stream is used to listen for bluetooth connections. This connection contains the `ConnectionResult`, that is, the status, the response message of that connection, and if the connection was successful, there will also be a `BluetoothDevice` object also. It is best prefered if you wrapped your entire app with this stream in a stream builder

<br/>

- `listenForData`: The stream for listening for data/messages across a bluetooth connection. Make sure you use it with the `listenForConnection` stream so that you will be sure you are send across a proper connection

<br/>

- `streamBluetoothState`: This stream is used to listen to the state of your device's bluetooth, whether it is turned on/off.
  If you change the state of your device bluetooth, this stream will emit a value corresponding to that state. So if you turn the bluetooth on, you get true and vice versa.

<br/>

### TODO

- Discovery and bonding to new devices.
- Setting a timeout for a Bluetooth server.
- Connection to multiple devices.

### Contributions and support

- All contributions and issues are welcome.
- If you want to contribute code, please create a pull request
- If you find a bug or want a feature, please fill an issue
