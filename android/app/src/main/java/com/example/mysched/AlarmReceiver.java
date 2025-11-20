package com.example.mysched;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;

import com.example.mysched.MainActivity;

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
		try {
			android.os.PowerManager powerManager =
				(android.os.PowerManager) context.getSystemService(Context.POWER_SERVICE);
			android.os.PowerManager.WakeLock wakeLock = powerManager.newWakeLock(
				android.os.PowerManager.FULL_WAKE_LOCK
					| android.os.PowerManager.ACQUIRE_CAUSES_WAKEUP
					| android.os.PowerManager.ON_AFTER_RELEASE,
				"AlarmReceiver:AlarmWakeLock");
			wakeLock.acquire(2 * 60 * 1000);
			logDebug("Wake lock acquired before launching alarm activity");
		} catch (Throwable t) {
			logError("Failed to acquire wake lock", t);
		}

		String title = intent.getStringExtra("title");
		String body = intent.getStringExtra("body");
		int requestCode = intent.getIntExtra("requestCode", 0);
		int classId = intent.getIntExtra("classId", -1);
		String occurrenceKey = intent.getStringExtra("occurrenceKey");
		if (occurrenceKey == null) {
			occurrenceKey = "";
		}
		String subject = intent.getStringExtra("subject");
		String room = intent.getStringExtra("room");
		String startTime = intent.getStringExtra("startTime");
		String endTime = intent.getStringExtra("endTime");

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
			Intent.FLAG_ACTIVITY_NEW_TASK
				| Intent.FLAG_ACTIVITY_CLEAR_TOP
				| Intent.FLAG_ACTIVITY_SINGLE_TOP
				| Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
		);

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
			NotificationManager nm =
				(NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

			String channelId = "mysched_alarm_channel_v2";
			if (nm.getNotificationChannel(channelId) == null) {
				NotificationChannel channel =
					new NotificationChannel(channelId, "Alarms", NotificationManager.IMPORTANCE_HIGH);
				channel.setDescription("Alarm notifications");
				channel.setLockscreenVisibility(NotificationCompat.VISIBILITY_PUBLIC);
				channel.enableVibration(true);
				nm.createNotificationChannel(channel);
			}

			PendingIntent fullScreenPendingIntent = PendingIntent.getActivity(
				context,
				requestCode,
				fullscreenIntent,
				PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
			);

			Intent dismissIntent = new Intent(context, AlarmDismissReceiver.class);
			dismissIntent.putExtra("notification_id", requestCode);
			dismissIntent.putExtra("classId", classId);
			dismissIntent.putExtra("occurrenceKey", occurrenceKey);
			PendingIntent dismissPi = PendingIntent.getBroadcast(
				context,
				requestCode + 1,
				dismissIntent,
				PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
			);

			String displayTitle =
				(subject != null && !subject.isEmpty())
					? subject
					: (title != null ? title : "Alarm");
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
				Intent.FLAG_ACTIVITY_NEW_TASK
					| Intent.FLAG_ACTIVITY_CLEAR_TOP
					| Intent.FLAG_ACTIVITY_SINGLE_TOP);
			PendingIntent remindersPi = PendingIntent.getActivity(
				context,
				requestCode + 2,
				remindersIntent,
				PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
			);
			builder.addAction(
				android.R.drawable.ic_menu_today,
				"View reminders",
				remindersPi
			);

			nm.notify(requestCode, builder.build());
			logDebug("Full-screen notification posted as backup");
		}

		try {
			logDebug("Launching FullscreenAlarmActivity (Kotlin)");
			ContextCompat.startActivity(context, fullscreenIntent, null);
		} catch (Throwable t) {
			logError("Failed to launch FullscreenAlarmActivity", t);
		}
	}
}


