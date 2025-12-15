package com.ici.mysched;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

/**
 * Handles device boot completion to reschedule alarms.
 * This is critical for alarm reliability across device restarts.
 * 
 * Supports:
 * - Standard Android boot
 * - Quick boot (some manufacturers)
 * - Direct boot (before user unlock on Android N+)
 * - Package replaced (app update)
 */
public class BootReceiver extends BroadcastReceiver {
    private static final String TAG = "MySched";
    private static final String LOG_SCOPE = "BootReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent == null) return;
        
        String action = intent.getAction();
        Log.i(TAG, "[" + LOG_SCOPE + "] Received boot broadcast: " + action);
        
        // Handle various boot-related intents
        if (Intent.ACTION_BOOT_COMPLETED.equals(action) ||
            Intent.ACTION_LOCKED_BOOT_COMPLETED.equals(action) ||
            "android.intent.action.QUICKBOOT_POWERON".equals(action) ||
            "com.htc.intent.action.QUICKBOOT_POWERON".equals(action) ||
            Intent.ACTION_MY_PACKAGE_REPLACED.equals(action)) {
            
            Log.i(TAG, "[" + LOG_SCOPE + "] Triggering alarm reschedule after boot/update");
            
            // Option 1: Start MainActivity to trigger Flutter reschedule
            // This is the simplest approach - Flutter will reschedule alarms on init
            try {
                Intent launchIntent = new Intent(context, MainActivity.class);
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                launchIntent.putExtra("from_boot_receiver", true);
                
                // For Android 12+, we need to be careful about background restrictions
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    // Post a notification to let user know alarms are being restored
                    // and provide a way to open the app
                    showRescheduleNotification(context);
                } else {
                    // On older versions, we can start activity directly
                    // But actually, let's use notification approach for all versions
                    // to avoid ANR and be more user-friendly
                    showRescheduleNotification(context);
                }
            } catch (Exception e) {
                Log.e(TAG, "[" + LOG_SCOPE + "] Failed to handle boot: " + e.getMessage(), e);
            }
        }
    }
    
    private void showRescheduleNotification(Context context) {
        try {
            android.app.NotificationManager nm = 
                (android.app.NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            
            String channelId = "mysched_boot_channel";
            
            // Create notification channel for Android 8+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                android.app.NotificationChannel channel = nm.getNotificationChannel(channelId);
                if (channel == null) {
                    channel = new android.app.NotificationChannel(
                        channelId,
                        "System Messages",
                        android.app.NotificationManager.IMPORTANCE_LOW
                    );
                    channel.setDescription("System notifications for app updates");
                    channel.setShowBadge(false);
                    nm.createNotificationChannel(channel);
                }
            }
            
            // Create pending intent to open app
            Intent openIntent = new Intent(context, MainActivity.class);
            openIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
            openIntent.putExtra("from_boot_receiver", true);
            
            android.app.PendingIntent pendingIntent = android.app.PendingIntent.getActivity(
                context,
                0,
                openIntent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT | 
                    (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ? android.app.PendingIntent.FLAG_IMMUTABLE : 0)
            );
            
            // Build notification
            androidx.core.app.NotificationCompat.Builder builder = 
                new androidx.core.app.NotificationCompat.Builder(context, channelId)
                    .setSmallIcon(android.R.drawable.ic_popup_reminder)
                    .setContentTitle("MySched")
                    .setContentText("Tap to restore your class alarms")
                    .setPriority(androidx.core.app.NotificationCompat.PRIORITY_LOW)
                    .setAutoCancel(true)
                    .setContentIntent(pendingIntent);
            
            nm.notify(9999, builder.build());
            
            Log.i(TAG, "[" + LOG_SCOPE + "] Posted reschedule notification");
        } catch (Exception e) {
            Log.e(TAG, "[" + LOG_SCOPE + "] Failed to show notification: " + e.getMessage(), e);
        }
    }
}
