package com.example.momentum

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private var eventChannel: EventChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup event channel for audio listening events
        eventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.momentum.audio/listening"
        )

        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                // Set the event sink in the service
                AudioListeningService.eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                AudioListeningService.eventSink = null
            }
        })
    }
}

