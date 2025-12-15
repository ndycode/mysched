package com.ici.mysched;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.os.PowerManager;
import android.util.Log;
import androidx.core.app.NotificationCompat;

/**
 * Foreground service for reliable alarm delivery on Android 11-15.
 * This service ensures alarms fire even when:
 * - Device is in Doze mode
 * - App is in background
 * - Battery optimization is enabled
 * 
 * The service starts briefly when an alarm is about to fire,
 * ensuring the system doesn't kill the app during alarm delivery.
 */
public class AlarmForegroundService extends Service {
    private static final String TAG = "MySched";
    private static final String LOG_SCOPE = "AlarmFgService";
    
    private static final String CHANNEL_ID = "mysched_alarm_service_channel";
    private static final int NOTIFICATION_ID = 8888;
    
    public static final String ACTION_START_ALARM = "com.ici.mysched.ACTION_START_ALARM";
    public static final String ACTION_STOP = "com.ici.mysched.ACTION_STOP_SERVICE";
    
    private PowerManager.WakeLock wakeLock;
    
    @Override
    public void onCreate() {
        super.onCreate();
        logDebug("Service created");
        createNotificationChannel();
        acquireWakeLock();
    }
    
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent == null) {
            stopSelf();
            return START_NOT_STICKY;
        }
        
        String action = intent.getAction();
        logDebug("onStartCommand: " + action);
        
        if (ACTION_STOP.equals(action)) {
            stopForeground(true);
            stopSelf();
            return START_NOT_STICKY;
        }
        
        if (ACTION_START_ALARM.equals(action)) {
            // Start as foreground service immediately
            startForeground(NOTIFICATION_ID, buildForegroundNotification());
            
            // Extract alarm data and forward to AlarmReceiver logic
            String title = intent.getStringExtra("title");
            String body = intent.getStringExtra("body");
            int requestCode = intent.getIntExtra("requestCode", 0);
            int classId = intent.getIntExtra("classId", -1);
            String occurrenceKey = intent.getStringExtra("occurrenceKey");
            String subject = intent.getStringExtra("subject");
            String room = intent.getStringExtra("room");
            String startTime = intent.getStringExtra("startTime");
            String endTime = intent.getStringExtra("endTime");
            
            // Launch fullscreen alarm activity
            launchFullscreenAlarm(
                title, body, requestCode, classId, occurrenceKey,
                subject, room, startTime, endTime
            );
            
            // Auto-stop service after alarm is delivered (10 seconds buffer)
            new android.os.Handler(android.os.Looper.getMainLooper()).postDelayed(() -> {
                stopForeground(true);
                stopSelf();
            }, 10000);
        }
        
        return START_NOT_STICKY;
    }
    
    private void launchFullscreenAlarm(
        String title, String body, int requestCode, int classId,
        String occurrenceKey, String subject, String room,
        String startTime, String endTime
    ) {
        try {
            Intent fullscreenIntent = new Intent(this, FullscreenAlarmActivity.class);
            fullscreenIntent.putExtra("title", title);
            fullscreenIntent.putExtra("body", body);
            fullscreenIntent.putExtra("requestCode", requestCode);
            fullscreenIntent.putExtra("classId", classId);
            fullscreenIntent.putExtra("occurrenceKey", occurrenceKey != null ? occurrenceKey : "");
            if (subject != null) fullscreenIntent.putExtra("subject", subject);
            if (room != null) fullscreenIntent.putExtra("room", room);
            if (startTime != null) fullscreenIntent.putExtra("startTime", startTime);
            if (endTime != null) fullscreenIntent.putExtra("endTime", endTime);
            
            fullscreenIntent.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK |
                Intent.FLAG_ACTIVITY_CLEAR_TOP |
                Intent.FLAG_ACTIVITY_SINGLE_TOP |
                Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
            );
            
            startActivity(fullscreenIntent);
            logDebug("Fullscreen alarm activity launched from foreground service");
        } catch (Exception e) {
            logError("Failed to launch fullscreen alarm", e);
        }
    }
    
    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID,
                "Alarm Service",
                NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription("Ensures alarms fire reliably");
            channel.setShowBadge(false);
            channel.setSound(null, null);
            
            NotificationManager nm = getSystemService(NotificationManager.class);
            if (nm != null) {
                nm.createNotificationChannel(channel);
            }
        }
    }
    
    private Notification buildForegroundNotification() {
        Intent stopIntent = new Intent(this, AlarmForegroundService.class);
        stopIntent.setAction(ACTION_STOP);
        PendingIntent stopPi = PendingIntent.getService(
            this, 0, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT | 
                (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ? PendingIntent.FLAG_IMMUTABLE : 0)
        );
        
        return new NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Alarm Active")
            .setContentText("Your alarm is ringing...")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setOngoing(true)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Stop", stopPi)
            .build();
    }
    
    private void acquireWakeLock() {
        try {
            PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
            if (pm != null) {
                wakeLock = pm.newWakeLock(
                    PowerManager.PARTIAL_WAKE_LOCK,
                    "MySched:AlarmForegroundService"
                );
                wakeLock.acquire(5 * 60 * 1000); // 5 minutes max
                logDebug("Wake lock acquired");
            }
        } catch (Exception e) {
            logError("Failed to acquire wake lock", e);
        }
    }
    
    private void releaseWakeLock() {
        try {
            if (wakeLock != null && wakeLock.isHeld()) {
                wakeLock.release();
                wakeLock = null;
                logDebug("Wake lock released");
            }
        } catch (Exception e) {
            logError("Failed to release wake lock", e);
        }
    }
    
    @Override
    public void onDestroy() {
        releaseWakeLock();
        logDebug("Service destroyed");
        super.onDestroy();
    }
    
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
    
    private void logDebug(String message) {
        Log.d(TAG, "[" + LOG_SCOPE + "] " + message);
    }
    
    private void logError(String message, Exception e) {
        Log.e(TAG, "[" + LOG_SCOPE + "] " + message, e);
    }
    
    /**
     * Static helper to start this service for an alarm.
     * Works on Android 8+ with foreground service restrictions.
     */
    public static void startForAlarm(Context context, Intent alarmData) {
        Intent serviceIntent = new Intent(context, AlarmForegroundService.class);
        serviceIntent.setAction(ACTION_START_ALARM);
        
        // Copy alarm data
        if (alarmData != null) {
            serviceIntent.putExtras(alarmData);
        }
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent);
            } else {
                context.startService(serviceIntent);
            }
            Log.d(TAG, "[" + LOG_SCOPE + "] Foreground service started for alarm");
        } catch (Exception e) {
            Log.e(TAG, "[" + LOG_SCOPE + "] Failed to start foreground service", e);
        }
    }
}
