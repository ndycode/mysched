package com.ici.mysched

import android.Manifest
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.annotation.SuppressLint
import android.media.RingtoneManager
import android.media.MediaPlayer
import android.media.AudioAttributes
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import androidx.core.content.ContextCompat
import androidx.core.app.NotificationManagerCompat

class MainActivity : FlutterActivity() {
    private val channelName = "mysched/native_alarm"
    private val navigationChannelName = "mysched/navigation"
    private var navigationChannel: MethodChannel? = null
    private var pendingReminderScope: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleTestAlarm" -> {
                        val seconds = (call.argument<Int>("seconds") ?: 5).toLong()
                        val title = call.argument<String>("title") ?: "Alarm"
                        val body = call.argument<String>("body") ?: "It's time!"
                        try {
                            scheduleAlarmIn(seconds, title, body)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("schedule_failed", e.message, null)
                        }
                    }
                    "scheduleNativeAlarmAt" -> {
                        try {
                            val atMillis = call.argument<Long>("atMillis")
                                ?: throw IllegalArgumentException("atMillis required")
                            val id = call.argument<Int>("id")
                                ?: throw IllegalArgumentException("id required")
                            val title = call.argument<String>("title") ?: "Alarm"
                            val body = call.argument<String>("body") ?: "It's time!"
                            val classId = call.argument<Int>("classId") ?: -1
                            val occurrenceKey = call.argument<String>("occurrenceKey") ?: ""
                            val subject = call.argument<String>("subject")
                            val room = call.argument<String>("room")
                            val startLabel = call.argument<String>("startTime")
                            val endLabel = call.argument<String>("endTime")
                            val headsUpOnly = call.argument<Boolean>("headsUpOnly") ?: false
                            if (headsUpOnly) {
                                scheduleHeadsUpAlarmAtMillis(
                                    atMillis,
                                    id,
                                    title,
                                    body,
                                    classId,
                                    occurrenceKey,
                                    subject,
                                    room,
                                    startLabel,
                                    endLabel
                                )
                            } else {
                                scheduleAlarmAtMillis(
                                    atMillis,
                                    id,
                                    title,
                                    body,
                                    classId,
                                    occurrenceKey,
                                    subject,
                                    room,
                                    startLabel,
                                    endLabel
                                )
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("schedule_failed", e.message, null)
                        }
                    }
                    "cancelNativeAlarm" -> {
                        try {
                            val id = call.argument<Int>("id")
                                ?: throw IllegalArgumentException("id required")
                            cancelAlarmById(id)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("cancel_failed", e.message, null)
                        }
                    }
                    "cancelAllNativeAlarms" -> {
                        try {
                            cancelAllScheduledAlarms()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("cancel_all_failed", e.message, null)
                        }
                    }
                    "isOccurrenceAcknowledged" -> {
                        try {
                            val classId = call.argument<Int>("classId") ?: -1
                            val occurrenceKey = call.argument<String>("occurrenceKey") ?: ""
                            val ack = isOccurrenceAcknowledged(classId, occurrenceKey)
                            result.success(ack)
                        } catch (e: Exception) {
                            result.error("ack_failed", e.message, null)
                        }
                    }
                    "markOccurrenceAcknowledged" -> {
                        val classId = call.argument<Int>("classId") ?: -1
                        val occurrenceKey = call.argument<String>("occurrenceKey") ?: ""
                        AlarmPrefsHelper.setOccurrenceAcknowledged(this, classId, occurrenceKey, true)
                        result.success(true)
                    }
                    "clearOccurrenceAcknowledged" -> {
                        val classId = call.argument<Int>("classId") ?: -1
                        val occurrenceKey = call.argument<String>("occurrenceKey") ?: ""
                        AlarmPrefsHelper.setOccurrenceAcknowledged(this, classId, occurrenceKey, false)
                        result.success(true)
                    }
                    "openExactAlarmSettings" -> {
                        try {
                            openExactAlarmSettings()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("open_settings_failed", e.message, null)
                        }
                    }
                    "canScheduleExactAlarms" -> {
                        try {
                            val canSchedule = canScheduleExactAlarms()
                            result.success(canSchedule)
                        } catch (e: Exception) {
                            result.error("check_failed", e.message, null)
                        }
                    }
                    "alarmReadiness" -> {
                        try {
                            result.success(alarmReadiness())
                        } catch (e: Exception) {
                            result.error("readiness_failed", e.message, null)
                        }
                    }
                    "openNotificationSettings" -> {
                        try {
                            openNotificationSettings()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("open_notification_settings_failed", e.message, null)
                        }
                    }
                    "openBatteryOptimizationSettings" -> {
                        try {
                            val preferAppInfo = call.argument<Boolean>("preferAppInfo") ?: false
                            openBatteryOptimizationSettings(preferAppInfo)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("open_battery_settings_failed", e.message, null)
                        }
                    }
                    "playRingtonePreview" -> {
                        try {
                            val ringtoneType = call.argument<String>("ringtoneType") ?: "default"
                            playRingtonePreview(ringtoneType)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("play_ringtone_failed", e.message, null)
                        }
                    }
                    "getAlarmSounds" -> {
                        try {
                            val sounds = getAvailableAlarmSounds()
                            result.success(sounds)
                        } catch (e: Exception) {
                            result.error("get_alarm_sounds_failed", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        navigationChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            navigationChannelName
        ).apply {
            setMethodCallHandler { _, result -> result.notImplemented() }
        }

        deliverPendingNavigation()
        handleNavigationIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleNavigationIntent(intent)
    }

    private fun scheduleAlarmIn(seconds: Long, title: String, body: String) {
        val ctx = this
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val triggerAt = System.currentTimeMillis() + seconds * 1000
        val requestCode = (triggerAt % Int.MAX_VALUE).toInt()
        val broadcastIntent = Intent(ctx, AlarmReceiver::class.java).apply {
            putExtra("title", title)
            putExtra("body", body)
            putExtra("requestCode", requestCode)
        }
        val broadcastPi = PendingIntent.getBroadcast(
            ctx,
            requestCode,
            broadcastIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or pendingIntentImmutableFlag()
        )
        val info = AlarmManager.AlarmClockInfo(triggerAt, broadcastPi)
        am.setAlarmClock(info, broadcastPi)
        AlarmStore.rememberAlarmId(this, requestCode)
        AlarmStore.addNativeId(this, requestCode)
    }

    private fun scheduleAlarmAtMillis(
        triggerAt: Long,
        requestCode: Int,
        title: String,
        body: String,
        classId: Int,
        occurrenceKey: String,
        subject: String?,
        room: String?,
        startLabel: String?,
        endLabel: String?
    ) {
        val ctx = this
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val broadcastIntent = Intent(ctx, AlarmReceiver::class.java).apply {
            putExtra("title", title)
            putExtra("body", body)
            putExtra("requestCode", requestCode)
            putExtra("classId", classId)
            putExtra("occurrenceKey", occurrenceKey)
            subject?.let { putExtra("subject", it) }
            room?.let { putExtra("room", it) }
            startLabel?.let { putExtra("startTime", it) }
            endLabel?.let { putExtra("endTime", it) }
        }
        val broadcastPi = PendingIntent.getBroadcast(
            ctx,
            requestCode,
            broadcastIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or pendingIntentImmutableFlag()
        )
        val info = AlarmManager.AlarmClockInfo(triggerAt, broadcastPi)
        am.setAlarmClock(info, broadcastPi)
        AlarmStore.rememberAlarmId(this, requestCode)
        if (classId != -1) {
            AlarmStore.addClassScheduleId(this, classId, requestCode)
        }
        AlarmStore.addNativeId(this, requestCode)
    }

    private fun scheduleHeadsUpAlarmAtMillis(
        triggerAt: Long,
        requestCode: Int,
        title: String,
        body: String,
        classId: Int,
        occurrenceKey: String,
        subject: String?,
        room: String?,
        startLabel: String?,
        endLabel: String?,
    ) {
        val ctx = this
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val broadcastIntent = Intent(ctx, HeadsUpReceiver::class.java).apply {
            putExtra("title", title)
            putExtra("body", body)
            putExtra("requestCode", requestCode)
            putExtra("classId", classId)
            putExtra("occurrenceKey", occurrenceKey)
            subject?.let { putExtra("subject", it) }
            room?.let { putExtra("room", it) }
            startLabel?.let { putExtra("startTime", it) }
            endLabel?.let { putExtra("endTime", it) }
        }
        val broadcastPi = PendingIntent.getBroadcast(
            ctx,
            requestCode,
            broadcastIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or pendingIntentImmutableFlag()
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, broadcastPi)
        } else {
            am.setExact(AlarmManager.RTC_WAKEUP, triggerAt, broadcastPi)
        }
        AlarmStore.rememberAlarmId(this, requestCode)
        AlarmStore.addNativeId(this, requestCode)
    }

    private fun cancelAlarmById(requestCode: Int) {
        val ctx = this
        val am = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        fun cancelReceiver(receiver: Class<*>) {
            val intent = Intent(ctx, receiver)
            val pi = PendingIntent.getBroadcast(
                ctx,
                requestCode,
                intent,
                PendingIntent.FLAG_NO_CREATE or pendingIntentImmutableFlag()
            )
            if (pi != null) {
                am.cancel(pi)
                pi.cancel()
            }
        }

        cancelReceiver(AlarmReceiver::class.java)
        cancelReceiver(HeadsUpReceiver::class.java)
        AlarmStore.forgetAlarmId(this, requestCode)
        AlarmStore.removeNativeId(this, requestCode)
    }

    private fun cancelAllScheduledAlarms() {
        val ids = AlarmStore.getRememberedAlarmIds(this).toList()
        for (id in ids) {
            try { cancelAlarmById(id) } catch (_: Exception) {}
        }
    }

    private fun isOccurrenceAcknowledged(classId: Int, occurrenceKey: String): Boolean {
        return AlarmPrefsHelper.isOccurrenceAcknowledged(this, classId, occurrenceKey)
    }

    private fun openExactAlarmSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = Uri.parse("package:" + applicationContext.packageName)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
        } else {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:" + applicationContext.packageName)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
        }
    }

    private fun canScheduleExactAlarms(): Boolean {
        val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            am.canScheduleExactAlarms()
        } else {
            true
        }
    }

    private fun alarmReadiness(): Map<String, Any?> {
        val notificationsAllowed = NotificationManagerCompat.from(this).areNotificationsEnabled()
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        val ignoringBattery = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            pm.isIgnoringBatteryOptimizations(packageName)
        } else {
            true
        }
        return mapOf(
            "exactAlarmAllowed" to canScheduleExactAlarms(),
            "notificationsAllowed" to notificationsAllowed,
            "ignoringBatteryOptimizations" to ignoringBattery,
            "sdkInt" to Build.VERSION.SDK_INT,
        )
    }

    private fun openNotificationSettings() {
        val intent = Intent().apply {
            action = Settings.ACTION_APP_NOTIFICATION_SETTINGS
            putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(intent)
    }

    @SuppressLint("BatteryLife")
    private fun openBatteryOptimizationSettings(preferAppInfo: Boolean) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        if (pm.isIgnoringBatteryOptimizations(packageName)) return

        val intents = mutableListOf<Intent>()
        if (preferAppInfo) {
            intents.add(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:$packageName")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                },
            )
        }
        intents.add(
            Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:$packageName")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            },
        )
        intents.add(
            Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            },
        )
        if (!preferAppInfo) {
            intents.add(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:$packageName")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                },
            )
        }

        for (intent in intents) {
            try {
                startActivity(intent)
                return
            } catch (_: Exception) {
                // try next
            }
        }
    }

    private fun pendingIntentImmutableFlag(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
    }

    private fun handleNavigationIntent(intent: Intent?) {
        if (intent == null) return
        if (intent.getBooleanExtra("navigate_to_reminders", false)) {
            val scope = intent.getStringExtra("reminder_scope") ?: "today"
            val channel = navigationChannel
            if (channel != null) {
                channel.invokeMethod(
                    "open_reminders",
                    mapOf("scope" to scope)
                )
            } else {
                pendingReminderScope = scope
            }
        }
    }

    private fun deliverPendingNavigation() {
        val scope = pendingReminderScope ?: return
        val channel = navigationChannel ?: return
        channel.invokeMethod(
            "open_reminders",
            mapOf("scope" to scope)
        )
        pendingReminderScope = null
    }

    private fun getAvailableAlarmSounds(): List<Map<String, String>> {
        val alarmSounds = mutableListOf<Map<String, String>>()
        
        try {
            val ringtoneManager = RingtoneManager(this)
            ringtoneManager.setType(RingtoneManager.TYPE_ALARM)
            val cursor = ringtoneManager.cursor
            
            if (cursor != null && cursor.moveToFirst()) {
                do {
                    try {
                        val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                        val uriString = ringtoneManager.getRingtoneUri(cursor.position).toString()
                        
                        alarmSounds.add(mapOf(
                            "title" to (title ?: "Alarm Sound"),
                            "uri" to uriString
                        ))
                    } catch (e: Exception) {
                        // Skip this ringtone if there's an issue
                    }
                } while (cursor.moveToNext())
                
                // Do not close cursor as it is owned by RingtoneManager and can cause StaleDataException
                // cursor.close()
            }
        } catch (e: Exception) {
            // If error, return empty list (Flutter will show default)
        }
        
        return alarmSounds
    }

    private fun playRingtonePreview(ringtoneUriString: String) {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val volumePercent = prefs.getInt("flutter.alarm_volume", 80)
        val volume = volumePercent / 100.0f

        try {
            // Parse URI string - if it's "default", use default alarm
            val uri = if (ringtoneUriString == "default") {
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            } else {
                Uri.parse(ringtoneUriString)
            }

            val mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                setDataSource(this@MainActivity, uri)
                setVolume(volume, volume)
                prepare()
                start()
            }

            // Stop after 2 seconds
            Handler(Looper.getMainLooper()).postDelayed({
                try {
                    mediaPlayer.stop()
                    mediaPlayer.release()
                } catch (_: Exception) {}
            }, 2000)
        } catch (_: Exception) {
            // Ignore errors
        }
    }
}

