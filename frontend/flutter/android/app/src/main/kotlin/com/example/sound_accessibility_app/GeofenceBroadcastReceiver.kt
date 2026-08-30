package com.example.sound_accessibility_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingEvent
import org.json.JSONObject

class GeofenceBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        try {
            val event = GeofencingEvent.fromIntent(intent) ?: run {
                Log.w("GeofenceReceiver", "Received null geofence event")
                return
            }

            if (event.hasError()) {
                Log.e("GeofenceReceiver", "Geofence error: ${event.errorCode}")
                return
            }

            val transition = event.geofenceTransition
            val triggeringIds = event.triggeringGeofences
                ?.map { it.requestId }
                ?: emptyList()

            if (transition == Geofence.GEOFENCE_TRANSITION_ENTER ||
                transition == Geofence.GEOFENCE_TRANSITION_EXIT
            ) {
                persistTransition(context, triggeringIds, transition)
                Log.d("GeofenceReceiver", "Transition $transition for ${triggeringIds.joinToString()}")
            }
        } catch (error: Exception) {
            Log.e("GeofenceReceiver", "onReceive failed", error)
        }
    }

    private fun persistTransition(context: Context, ids: List<String>, transition: Int) {
        try {
            val prefs = context.getSharedPreferences("aiish_geofence_state", Context.MODE_PRIVATE)
            val payload = JSONObject().apply {
                put("ids", ids)
                put("transition", transition)
            }
            prefs.edit().putString("pending_geofence_event", payload.toString()).apply()
        } catch (error: Exception) {
            Log.e("GeofenceReceiver", "Failed to persist geofence transition", error)
        }
    }
}
