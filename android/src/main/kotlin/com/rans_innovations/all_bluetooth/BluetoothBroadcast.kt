package com.rans_innovations.all_bluetooth

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class BluetoothBroadcast(
    private val bluetoothAdapter: BluetoothAdapter,
    private val listenToState: (Boolean) -> Unit,
    private val listenToConnection: (BluetoothDevice?, Boolean) -> Unit
) : BroadcastReceiver() {


    override fun onReceive(context: Context?, intent: Intent?) {

        val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent?.getParcelableExtra(
                BluetoothDevice.EXTRA_DEVICE,
                BluetoothDevice::class.java
            )
        } else {
            @Suppress("DEPRECATION")
            intent?.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
        }


        when (intent?.action) {
            BluetoothAdapter.ACTION_STATE_CHANGED -> {
                val isEnabled = bluetoothAdapter.isEnabled
                isEnabled.let(listenToState)
            }

            BluetoothDevice.ACTION_ACL_CONNECTED -> {
                println("connected to  ${device?.name} 😊😊😊")
                listenToConnection(device, true)
            }

            BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                println("there is a disconnection")
                listenToConnection(device, false)
            }
        }

    }
}
