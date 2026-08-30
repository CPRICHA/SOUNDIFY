package com.example.sound_accessibility_app

import android.Manifest
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofenceStatusCodes
import com.google.android.gms.location.GeofencingClient
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices
import org.json.JSONObject

object GeofenceBridge {
    private const val TAG = "GeofenceBridge"
    private const val GEOFENCE_PENDING_INTENT_REQUEST_CODE = 4001
    private const val ACTION_GEOFENCE_EVENT = "com.example.sound_accessibility_app.GEOFENCE_EVENT"

    @Volatile
    private var geofencingClient: GeofencingClient? = null
    @Volatile
    private var geofencePendingIntent: PendingIntent? = null

    fun registerGeofences(context: Context, locations: List<Map<String, Any>>) {
        val client = getClient(context)
        if (client == null) {
            persistFailure(context, "Google Play Services unavailable")
            return
        }

        if (!hasLocationPermission(context)) {
            persistFailure(context, "Location permission not granted")
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_BACKGROUND_LOCATION) != PackageManager.PERMISSION_GRANTED
        ) {
            persistFailure(context, "Background location permission not granted")
            return
        }

        val geofences = locations.mapNotNull { location ->
            val id = location["id"] as? String ?: return@mapNotNull null
            val latitude = (location["latitude"] as? Number)?.toDouble() ?: return@mapNotNull null
            val longitude = (location["longitude"] as? Number)?.toDouble() ?: return@mapNotNull null
            val radius = (location["radiusMeters"] as? Number)?.toFloat() ?: return@mapNotNull null
            if (radius <= 0f) return@mapNotNull null
            Geofence.Builder()
                .setRequestId(id)
                .setCircularRegion(latitude, longitude, radius)
                .setExpirationDuration(Geofence.NEVER_EXPIRE)
                .setTransitionTypes(
                    Geofence.GEOFENCE_TRANSITION_ENTER or Geofence.GEOFENCE_TRANSITION_EXIT
                )
                .build()
        }

        if (geofences.isEmpty()) {
            return
        }

        val request = GeofencingRequest.Builder()
            .setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER or GeofencingRequest.INITIAL_TRIGGER_EXIT)
            .addGeofences(geofences)
            .build()

        val pendingIntent = getPendingIntent(context)
        client.addGeofences(request, pendingIntent)
            .addOnSuccessListener {
                Log.d(TAG, "Registered ${geofences.size} geofences")
            }
            .addOnFailureListener { error ->
                persistFailure(context, error.message ?: "Geofence registration failed")
                Log.e(TAG, "Geofence registration failed", error)
            }
    }

    fun removeGeofence(context: Context, locationId: String) {
        val client = getClient(context) ?: return
        val pendingIntent = getPendingIntent(context)
        client.removeGeofences(listOf(locationId), pendingIntent)
            .addOnSuccessListener {
                Log.d(TAG, "Removed geofence $locationId")
            }
            .addOnFailureListener { error ->
                Log.e(TAG, "Remove geofence failed for $locationId", error)
            }
    }

    fun removeAllGeofences(context: Context) {
        val client = getClient(context) ?: return
        val pendingIntent = getPendingIntent(context)
        client.removeGeofences(pendingIntent)
            .addOnSuccessListener {
                Log.d(TAG, "Removed all geofences")
            }
            .addOnFailureListener { error ->
                Log.e(TAG, "Remove all geofences failed", error)
            }
    }

    private fun getClient(context: Context): GeofencingClient? {
        if (geofencingClient != null) {
            return geofencingClient
        }

        if (GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(context) != ConnectionResult.SUCCESS) {
            return null
        }

        geofencingClient = LocationServices.getGeofencingClient(context.applicationContext)
        return geofencingClient
    }

    private fun getPendingIntent(context: Context): PendingIntent {
        val existing = geofencePendingIntent
        if (existing != null) {
            return existing
        }

        val intent = Intent(context.applicationContext, GeofenceBroadcastReceiver::class.java).apply {
            action = ACTION_GEOFENCE_EVENT
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context.applicationContext,
            GEOFENCE_PENDING_INTENT_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )

        geofencePendingIntent = pendingIntent
        return pendingIntent
    }

    private fun hasLocationPermission(context: Context): Boolean {
        val fine = ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION)
        val coarse = ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION)
        return fine == PackageManager.PERMISSION_GRANTED || coarse == PackageManager.PERMISSION_GRANTED
    }

    private fun persistFailure(context: Context, message: String) {
        try {
            val prefs = context.getSharedPreferences("aiish_geofence_state", Context.MODE_PRIVATE)
            val payload = JSONObject().apply {
                put("error", message)
                put("transition", 0)
                put("ids", emptyList<String>())
            }
            prefs.edit().putString("pending_geofence_failure", payload.toString()).apply()
        } catch (_: Exception) {
            // Ignore persistence errors.
        }
    }
}
