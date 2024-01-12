package com.rans_innovations.all_bluetooth


import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothServerSocket
import android.bluetooth.BluetoothSocket
import android.content.BroadcastReceiver
import android.content.Context
import android.content.IntentFilter
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException
import java.util.UUID

/** AllBluetoothPlugin */
class AllBluetoothPlugin : FlutterPlugin, MethodCallHandler, FlutterActivity() {

    private val connectionUUID = UUID.fromString("38d00467-9f10-4e96-b045-d9b69303fa33")

    private lateinit var context: Context
    private lateinit var methodChannel: MethodChannel

    private lateinit var bluetoothChangeEvent: EventChannel
    private lateinit var connectionChangeEvent: EventChannel
    private lateinit var sendReceiveEvent: EventChannel


    private var bluetoothStateSink: EventChannel.EventSink? = null
    private var connectionStateSink: EventChannel.EventSink? = null
    private var sendReceiveSink: EventChannel.EventSink? = null

    private lateinit var broadcastReceiver: BroadcastReceiver

    private lateinit var bluetoothManager: BluetoothManager
    private lateinit var bluetoothAdapter: BluetoothAdapter


    private var clientSocket: BluetoothSocket? = null
    private var serverSocket: BluetoothServerSocket? = null
    private lateinit var sendReceive: SendReceive


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

        context = flutterPluginBinding.applicationContext

        methodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "com.rans_innovations/all_bluetooth"
        )
        methodChannel.setMethodCallHandler(this)


        bluetoothChangeEvent =
            EventChannel(flutterPluginBinding.binaryMessenger, "bluetooth_change_event")
        connectionChangeEvent =
            EventChannel(flutterPluginBinding.binaryMessenger, "connection_change_event")
        sendReceiveEvent =
            EventChannel(flutterPluginBinding.binaryMessenger, ("send_receive_event"))



        bluetoothManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.getSystemService(BluetoothManager::class.java)
        } else {
            ContextCompat.getSystemService(context, BluetoothManager::class.java)!!
        }
        bluetoothAdapter = bluetoothManager.adapter


        bluetoothChangeEvent.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, events: EventChannel.EventSink?) {
                    bluetoothStateSink = events
                }

                override fun onCancel(arguments: Any?) {
                }
            }
        )

        connectionChangeEvent.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, events: EventChannel.EventSink?) {
                    connectionStateSink = events
                }

                override fun onCancel(arguments: Any?) {
                }
            }
        )

        sendReceiveEvent.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, events: EventChannel.EventSink?) {
                    sendReceiveSink = events
                }

                override fun onCancel(arguments: Any?) {
                }
            }
        )


        broadcastReceiver = BluetoothBroadcast(
            bluetoothAdapter,
            listenToConnection = { device, isConnected ->
                val response = getConnectionMessage(
                    device = device,
                    status = isConnected,
                    message = "connection status changed to $isConnected"
                )
                connectionStateSink?.success(response)
            },
            listenToState = {
                bluetoothStateSink?.success(bluetoothAdapter.isEnabled)
            }
        )

        val filter = IntentFilter().apply {
            addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
            addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
            addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
        }

        context.registerReceiver(broadcastReceiver, filter)
    }


    override fun onMethodCall(call: MethodCall, result: Result) {


        when (call.method) {
            "get_bonded_devices" -> {
                val bondedDevices = bluetoothAdapter.bondedDevices.toMutableList()
                val response = mutableListOf<Map<*, *>>()
                bondedDevices.forEach {
                    response.add(
                        mapOf("name" to it.name, "address" to it.address)
                    )
                }
                if (!bluetoothAdapter.isEnabled) {
                    result.error(
                        "403",
                        "Please turn on your bluetooth on first",
                        "Make sure your device bluetooth is turned on before you can continue. Check to see if it is turned on"
                    )
                } else {
                    result.success(response)
                }
            }

            "is_bluetooth_on" -> {
                val isBluetoothOn = bluetoothAdapter.isEnabled
                result.success(isBluetoothOn)
            }

            "start_server" -> {
                if (!bluetoothAdapter.isEnabled) {
                    result.error(
                        "403",
                        "Please turn on your bluetooth on first",
                        "Make sure your device bluetooth is turned on before you can continue. Check to see if it is turned on"
                    )
                    return
                }
                val serverClass = ServerClass()
                serverClass.start()
            }

            "connect_to_device" -> {
                if (!bluetoothAdapter.isEnabled) {
                    result.error(
                        "403",
                        "Please turn on your bluetooth on first",
                        "Make sure your device bluetooth is turned on before you can continue. Check to see if it is turned on"
                    )
                    return
                }
                val deviceAddress = call.arguments as String
                val device = bluetoothAdapter.getRemoteDevice(deviceAddress)
                val clientClass = ClientClass(device)
                clientClass.start()
            }

            "send_message" -> {
                if (!bluetoothAdapter.isEnabled) {
                    result.error(
                        "403",
                        "Please turn on your bluetooth on first",
                        "Make sure your device bluetooth is turned on before you can continue. Check to see if it is turned on"
                    )
                    return
                }
                val message = call.arguments as String
                val messageSent = sendReceive.sendMessage(message)
                result.success(messageSent)
            }

            "close_connection" -> {
                closeConnection()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)

        bluetoothChangeEvent.setStreamHandler(null)
        connectionChangeEvent.setStreamHandler(null)
        sendReceiveEvent.setStreamHandler(null)
    }

    override fun onStop() {
        super.onStop()
        closeConnection()
    }


    private fun closeConnection() {
        serverSocket = null
        clientSocket?.also {
            if (it.isConnected) {
                it.close()
                clientSocket = null
            }
        }
    }


    inner class ServerClass : Thread() {
        override fun run() {
            var shouldLoop = true

            bluetoothAdapter.listenUsingRfcommWithServiceRecord(
                "com.rans_innovations/all_bluetooth",
                connectionUUID
            )
                ?.let { newServerSocket ->
                    serverSocket = newServerSocket
                    while (shouldLoop) {

                        clientSocket =
                            try {
                                serverSocket?.accept()
                            } catch (ex: IOException) {
                                shouldLoop = false
                                null
                            }

                        clientSocket?.let { socket ->
                            try {
                                sendReceive = SendReceive(socket)
                                sendReceive.start()
                            } catch (e: IOException) {
                                return
                            }
                        }
                    }

                }
        }
    }


    inner class ClientClass(
        private val device: BluetoothDevice
    ) : Thread() {

        override fun run() {
            clientSocket = bluetoothAdapter
                .getRemoteDevice(device.address)
                .createRfcommSocketToServiceRecord(connectionUUID)

            clientSocket?.let { socket ->
                try {
                    socket.connect()

                    sendReceive = SendReceive(socket)
                    sendReceive.start()
                } catch (e: IOException) {
                    return
                }
            }
        }
    }


    inner class SendReceive(
        private val socket: BluetoothSocket
    ) : Thread() {
        private val inputStream = socket.inputStream

        override fun run() {

            if (!socket.isConnected) {
                return
            }

            while (true) {
                try {
                    val buffer = ByteArray(1024)
                    val bytes = try {
                        inputStream.read(buffer)
                    } catch (e: IOException) {
                        val response = getConnectionMessage(
                            status = false,
                            message = e.message,
                            device = null
                        )
                        runOnUiThread { connectionStateSink?.success(response) }
                        break
                    }


                    val message = buffer.decodeToString(endIndex = bytes)
                    val response =
                        mapOf(
                            "response" to message,
                            "status" to true
                        )

                    runOnUiThread { sendReceiveSink?.success(response) }
                } catch (e: Exception) {
                    val response = getConnectionMessage(
                        status = false,
                        message = e.message,
                        device = socket.remoteDevice
                    )
                    runOnUiThread { connectionStateSink?.success(response) }
                }

            }
        }


        fun sendMessage(message: String): Boolean {
            return try {
                socket.outputStream
                    .write(message.toByteArray())
                true
            } catch (e: Exception) {
                e.printStackTrace()
                false
            }

        }

    }

    private fun getConnectionMessage(
        status: Boolean,
        message: String?,
        device: BluetoothDevice?
    ): Map<String, Any?> {
        return mapOf(
            "response" to message,
            "status" to status,
            "name" to device?.name,
            "address" to device?.address
        )
    }

}
