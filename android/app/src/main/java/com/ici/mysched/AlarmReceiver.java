package com.ici.mysched;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;

/**
 * BroadcastReceiver for handling alarm triggers.
 * 
 * Delivery mechanism varies by Android version:
 * - Android 11+ (API 30+): Uses foreground service for reliable delivery
 * - Android 10 and below: Launches activity directly
 * 
 * Always posts a backup notification on Android 10+ in case fullscreen fails.
 */
public class AlarmReceiver extends BroadcastReceiver {
    private static final String TAG = "MySched";
    private static final String LOG_SCOPE = "AlarmReceiver";

    private static void logDebug(String message) {
        android.util.Log.d(TAG, "[" + LOG_SCOPE + "] " + message);
    }

    private static void logError(String message, Throwable t) {
        android.util.Log.e(TAG, "[" + LOG_SCOPE + "] " + message, t);
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        // Acquire wake lock immediately for reliable delivery
        android.os.PowerManager.WakeLock wakeLock = null;
        try {
            android.os.PowerManager pm =
                (android.os.PowerManager) context.getSystemService(Context.POWER_SERVICE);
            wakeLock = pm.newWakeLock(
                android.os.PowerManager.PARTIAL_WAKE_LOCK |
                android.os.PowerManager.ACQUIRE_CAUSES_WAKEUP,
                "MySched:AlarmReceiverWakeLock");
            wakeLock.acquire(2 * 60 * 1000);
            logDebug("Wake lock acquired");
        } catch (Throwable t) {
            logError("Failed to acquire wake lock", t);
        }

        // Extract alarm data
        String title = intent.getStringExtra("title");
        String body = intent.getStringExtra("body");
        int requestCode = intent.getIntExtra("requestCode", 0);
        int classId = intent.getIntExtra("classId", -1);
        String occurrenceKey = intent.getStringExtra("occurrenceKey");
        if (occurrenceKey == null) occurrenceKey = "";
        String subject = intent.getStringExtra("subject");
        String room = intent.getStringExtra("room");
        String startTime = intent.getStringExtra("startTime");
        String endTime = intent.getStringExtra("endTime");

        // For Android 11+ (API 30+), use foreground service for reliable delivery
        // For Android 10 and below, launch activity directly
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            logDebug("Using foreground service for alarm delivery (Android 11+)");
            launchViaForegroundService(context, intent);
        } else {
            logDebug("Launching fullscreen alarm directly (Android 10 and below)");
            launchFullscreenAlarmDirectly(context, title, body, requestCode, classId,
                occurrenceKey, subject, room, startTime, endTime);
        }

        // Always post notification as backup (Android 10+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            postBackupNotification(context, title, body, requestCode, classId, 
                occurrenceKey, subject, room, startTime, endTime);
        }
    }

    private void launchViaForegroundService(Context context, Intent alarmIntent) {
        try {
            AlarmForegroundService.startForAlarm(context, alarmIntent);
        } catch (Exception e) {
            logError("Failed to start foreground service, falling back to direct launch", e);
            // Fallback to direct launch
            String title = alarmIntent.getStringExtra("title");
            String body = alarmIntent.getStringExtra("body");
            int requestCode = alarmIntent.getIntExtra("requestCode", 0);
            int classId = alarmIntent.getIntExtra("classId", -1);
            String occurrenceKey = alarmIntent.getStringExtra("occurrenceKey");
            String subject = alarmIntent.getStringExtra("subject");
            String room = alarmIntent.getStringExtra("room");
            String startTime = alarmIntent.getStringExtra("startTime");
            String endTime = alarmIntent.getStringExtra("endTime");
            launchFullscreenAlarmDirectly(context, title, body, requestCode, classId,
                occurrenceKey != null ? occurrenceKey : "", subject, room, startTime, endTime);
        }
    }

    private void launchFullscreenAlarmDirectly(Context context, String title, String body,
            int requestCode, int classId, String occurrenceKey, String subject, 
            String room, String startTime, String endTime) {
        try {
            Intent fullscreenIntent = new Intent(context, FullscreenAlarmActivity.class);
            fullscreenIntent.putExtra("title", title);
            fullscreenIntent.putExtra("body", body);
            fullscreenIntent.putExtra("requestCode", requestCode);
            fullscreenIntent.putExtra("classId", classId);
            fullscreenIntent.putExtra("occurrenceKey", occurrenceKey);
            if (subject != null && !subject.isEmpty()) {
                fullscreenIntent.putExtra("subject", subject);
            }
            if (room != null && !room.isEmpty()) {
                fullscreenIntent.putExtra("room", room);
            }
            if (startTime != null && !startTime.isEmpty()) {
                fullscreenIntent.putExtra("startTime", startTime);
            }
            if (endTime != null && !endTime.isEmpty()) {
                fullscreenIntent.putExtra("endTime", endTime);
            }
            fullscreenIntent.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK |
                Intent.FLAG_ACTIVITY_CLEAR_TOP |
                Intent.FLAG_ACTIVITY_SINGLE_TOP |
                Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
            );

            ContextCompat.startActivity(context, fullscreenIntent, null);
            logDebug("Fullscreen alarm activity launched directly");
        } catch (Throwable t) {
            logError("Failed to launch FullscreenAlarmActivity", t);
        }
    }

    private void postBackupNotification(Context context, String title, String body,
            int requestCode, int classId, String occurrenceKey, String subject,
            String room, String startTime, String endTime) {
        try {
            NotificationManager nm =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

            String channelId = "mysched_alarm_channel_v2";
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (nm.getNotificationChannel(channelId) == null) {
                    NotificationChannel channel =
                        new NotificationChannel(channelId, "Alarms", NotificationManager.IMPORTANCE_HIGH);
                    channel.setDescription("Alarm notifications");
                    channel.setLockscreenVisibility(NotificationCompat.VISIBILITY_PUBLIC);
                    channel.enableVibration(true);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        channel.setBypassDnd(true);
                    }
                    nm.createNotificationChannel(channel);
                }
            }

            Intent fullscreenIntent = new Intent(context, FullscreenAlarmActivity.class);
            fullscreenIntent.putExtra("title", title);
            fullscreenIntent.putExtra("body", body);
            fullscreenIntent.putExtra("requestCode", requestCode);
            fullscreenIntent.putExtra("classId", classId);
            fullscreenIntent.putExtra("occurrenceKey", occurrenceKey);
            if (subject != null) fullscreenIntent.putExtra("subject", subject);
            if (room != null) fullscreenIntent.putExtra("room", room);
            if (startTime != null) fullscreenIntent.putExtra("startTime", startTime);
            if (endTime != null) fullscreenIntent.putExtra("endTime", endTime);
            fullscreenIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);

            PendingIntent fullScreenPendingIntent = PendingIntent.getActivity(
                context, requestCode, fullscreenIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | 
                    (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ? PendingIntent.FLAG_IMMUTABLE : 0)
            );

            Intent dismissIntent = new Intent(context, AlarmDismissReceiver.class);
            dismissIntent.putExtra("notification_id", requestCode);
            dismissIntent.putExtra("classId", classId);
            dismissIntent.putExtra("occurrenceKey", occurrenceKey);
            PendingIntent dismissPi = PendingIntent.getBroadcast(
                context, requestCode + 1, dismissIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | 
                    (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ? PendingIntent.FLAG_IMMUTABLE : 0)
            );

            String displayTitle = (subject != null && !subject.isEmpty())
                ? subject : (title != null ? title : "Alarm");
            String displayBody = body != null ? body : "It's time!";

            NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channelId)
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle(displayTitle)
                .setStyle(new NotificationCompat.BigTextStyle().bigText(displayBody))
                .setContentText(displayBody)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setShowWhen(true)
                .setWhen(System.currentTimeMillis())
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .setFullScreenIntent(fullScreenPendingIntent, true)
                .setDeleteIntent(dismissPi)
                .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Dismiss", dismissPi)
                .setAutoCancel(false);

            Intent remindersIntent = new Intent(context, MainActivity.class);
            remindersIntent.putExtra("navigate_to_reminders", true);
            remindersIntent.putExtra("reminder_scope", "today");
            remindersIntent.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK |
                Intent.FLAG_ACTIVITY_CLEAR_TOP |
                Intent.FLAG_ACTIVITY_SINGLE_TOP);
            PendingIntent remindersPi = PendingIntent.getActivity(
                context, requestCode + 2, remindersIntent,
                PendingIntent.FLAG_UPDATE_CURRENT | 
                    (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ? PendingIntent.FLAG_IMMUTABLE : 0)
            );
            builder.addAction(android.R.drawable.ic_menu_today, "View reminders", remindersPi);

            nm.notify(requestCode, builder.build());
            logDebug("Backup notification posted");
        } catch (Exception e) {
            logError("Failed to post backup notification", e);
        }
    }
}
