package com.example.momentum

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.EventChannel

class AudioListeningService : NotificationListenerService() {
    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        // Check if this is a media notification
        val extras = sbn.notification.extras
        
        // Media notifications contain playback state
        if (extras.containsKey("android.media.session")) {
            val playbackState = extras.getInt("android.media.session.playbackState", -1)
            
            // PlaybackState.STATE_PLAYING = 3
            // PlaybackState.STATE_PAUSED = 2
            if (playbackState == 3) {
                eventSink?.success("START")
            } else if (playbackState == 2) {
                eventSink?.success("STOP")
            }
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        // When media notification is removed, audio likely stopped
        val extras = sbn.notification.extras
        if (extras.containsKey("android.media.session")) {
            eventSink?.success("STOP")
        }
    }
}
