package com.example.sound_accessibility_app

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.sound_accessibility_app/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "showCustomNotification" -> {

                    val title =
                        call.argument<String>("title") ?: "Sound Detected"

                    val priority =
                        call.argument<String>("priority") ?: ""

                    val imageBytes =
                        call.argument<ByteArray>("imageBytes")

                    val channelId =
                        call.argument<String>("channelId")
                            ?: "sound_alerts_standard"

                    val notificationId =
                        call.argument<Int>("notificationId")
                            ?: (System.currentTimeMillis() % 100000).toInt()

                    val isCriticalOrHigh =
                        call.argument<Boolean>("isCriticalOrHigh") ?: false

                    try {
                        val remoteViews = RemoteViews(
                            packageName,
                            R.layout.sound_notification
                        )

                        remoteViews.setTextViewText(
                            R.id.sound_title,
                            title
                        )

                        remoteViews.setTextViewText(
                            R.id.sound_priority,
                            priority
                        )

                        if (imageBytes != null && imageBytes.isNotEmpty()) {
                            val bitmap = BitmapFactory.decodeByteArray(
                                imageBytes,
                                0,
                                imageBytes.size
                            )

                            if (bitmap != null) {
                                remoteViews.setImageViewBitmap(
                                    R.id.sound_image,
                                    bitmap
                                )
                            }
                        }

                        val dismissIntent = Intent(
                            this,
                            NotificationActionReceiver::class.java
                        ).apply {
                            action = "ACTION_DISMISS"
                            putExtra("notificationId", notificationId)
                        }

                        val dismissPendingIntent =
                            PendingIntent.getBroadcast(
                                this,
                                notificationId * 10 + 1,
                                dismissIntent,
                                PendingIntent.FLAG_UPDATE_CURRENT or
                                    PendingIntent.FLAG_IMMUTABLE
                            )

                        val builder =
                            NotificationCompat.Builder(this, channelId)
                                .setSmallIcon(R.mipmap.ic_launcher)
                                .setCustomContentView(remoteViews)
                                .setCustomBigContentView(remoteViews)
                                .setStyle(
                                    NotificationCompat.DecoratedCustomViewStyle()
                                )
                                .setPriority(NotificationCompat.PRIORITY_HIGH)
                                .setAutoCancel(true)
                                .addAction(
                                    0,
                                    "Dismiss",
                                    dismissPendingIntent
                                )

                        if (isCriticalOrHigh) {

                            val snoozeIntent = Intent(
                                this,
                                NotificationActionReceiver::class.java
                            ).apply {
                                action = "ACTION_SNOOZE"
                                putExtra(
                                    "notificationId",
                                    notificationId
                                )
                            }

                            val snoozePendingIntent =
                                PendingIntent.getBroadcast(
                                    this,
                                    notificationId * 10 + 2,
                                    snoozeIntent,
                                    PendingIntent.FLAG_UPDATE_CURRENT or
                                        PendingIntent.FLAG_IMMUTABLE
                                )

                            builder.addAction(
                                0,
                                "Snooze (2m)",
                                snoozePendingIntent
                            )
                        }

                        val manager =
                            getSystemService(
                                Context.NOTIFICATION_SERVICE
                            ) as NotificationManager

                        manager.notify(
                            notificationId,
                            builder.build()
                        )

                        result.success(true)

                    } catch (e: Exception) {
                        result.error(
                            "NOTIFICATION_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}


class NotificationActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {

        val notificationId =
            intent.getIntExtra("notificationId", -1)

        if (notificationId == -1) return

        val manager =
            context.getSystemService(
                Context.NOTIFICATION_SERVICE
            ) as NotificationManager

        when (intent.action) {

            "ACTION_DISMISS" -> {
                manager.cancel(notificationId)
            }

            "ACTION_SNOOZE" -> {
                manager.cancel(notificationId)

                val prefs = context.getSharedPreferences(
                    "FlutterSharedPreferences",
                    Context.MODE_PRIVATE
                )

                prefs.edit()
                    .putLong(
                        "flutter.snoozed_until",
                        System.currentTimeMillis() + (2 * 60 * 1000)
                    )
                    .apply()
            }
        }
    }
}
