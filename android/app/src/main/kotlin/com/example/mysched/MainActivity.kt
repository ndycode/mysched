package com.example.mysched

import android.Manifest
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import androidx.core.content.ContextCompat

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
}

