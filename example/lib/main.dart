import 'package:all_bluetooth/all_bluetooth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  runApp(const MyApp());
}

final allBluetooth = AllBluetooth();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<ConnectionResult>(
          stream: allBluetooth.listenForConnection,
          builder: (context, snapshot) {
            final state = snapshot.data?.state ?? false;
            if (state == true) {
              final device = snapshot.data!.device;
              return ChatScreen(device: device!);
            }
            return const HomeScreen();
          },
        ),
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool listeningForClient = false;

  final devices = ValueNotifier<List<BluetoothDevice>>([]);

  @override
  void initState() {
    super.initState();
    const MethodChannel("method_channel").invokeMethod("permit");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: allBluetooth.streamBluetoothState,
      builder: (context, snapshot) {
        final bluetoothOn = snapshot.data ?? false;
        return Scaffold(
          floatingActionButton: switch (listeningForClient) {
            true => null,
            false => FloatingActionButton(
                backgroundColor: switch (bluetoothOn) {
                  true => Theme.of(context).primaryColor,
                  false => Colors.grey,
                },
                onPressed: switch (bluetoothOn) {
                  false => null,
                  true => () {
                      allBluetooth.startBluetoothServer();
                      setState(() {
                        listeningForClient = true;
                      });
                    },
                },
                child: const Icon(Icons.wifi_tethering),
              )
          },
          appBar: AppBar(
            title: const Text("Bluetooth Connect"),
          ),
          body: switch (listeningForClient) {
            true => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Waiting"),
                    const CircularProgressIndicator(),
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          listeningForClient = false;
                        });
                        allBluetooth.closeConnection();
                      },
                      child: const Icon(Icons.stop),
                    ),
                  ],
                ),
              ),
            false => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        switch (bluetoothOn) {
                          true => "ON",
                          false => "off",
                        },
                        style: TextStyle(
                          color: bluetoothOn ? Colors.green : Colors.red,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: switch (bluetoothOn) {
                          false => null,
                          true => () {
                              allBluetooth
                                  .getBondedDevices()
                                  .then((newDevices) {
                                devices.value = newDevices;
                              });
                            },
                        },
                        child: const Text("Bonded Devices"),
                      ),
                    ],
                  ),
                  if (!bluetoothOn)
                    const Center(child: Text("Turn bluetooth on"))
                  else
                    DeviceListWidget(
                      notifier: devices,
                      title: "Paired Devices",
                    ),
                ],
              ),
          },
        );
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  final BluetoothDevice device;

  const ChatScreen({super.key, required this.device});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageListener = ValueNotifier(<String>[]);
  final messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allBluetooth.listenForData.listen((event) {
      if (event != null) {
        messageListener.value = [
          ...messageListener.value,
          event,
        ];
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: [
          ElevatedButton(
            onPressed: allBluetooth.closeConnection,
            child: const Text("CLOSE"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                  valueListenable: messageListener,
                  builder: (context, messages, child) {
                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                msg,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: FloatingActionButton(
                    onPressed: () {
                      final message = messageController.text;
                      allBluetooth.sendMessage(message);
                      messageController.clear();
                      FocusScope.of(context).unfocus();
                    },
                    child: const Icon(Icons.send),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DeviceListWidget extends StatelessWidget {
  final String title;
  final ValueNotifier<List<BluetoothDevice>> notifier;

  const DeviceListWidget({
    required this.notifier,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder(
          valueListenable: notifier,
          builder: (context, value, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title),
                    Text(value.length.toString()),
                  ],
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: value.length,
                    itemBuilder: (ctx, index) {
                      final device = value[index];
                      return ListTile(
                        title: Text(device.name),
                        subtitle: Text(device.address),
                        onTap: () async {
                          allBluetooth.connectToDevice(device.address);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }),
    );
  }
}
