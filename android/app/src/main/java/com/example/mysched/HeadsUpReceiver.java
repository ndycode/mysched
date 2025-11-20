package com.example.mysched;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import java.util.HashSet;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

public class HeadsUpReceiver extends BroadcastReceiver {
	@Override
	public void onReceive(Context context, Intent intent) {
		String title = intent.getStringExtra("title");
		String body = intent.getStringExtra("body");
		int requestCode = intent.getIntExtra("requestCode", 0);
		String subject = intent.getStringExtra("subject");
		String room = intent.getStringExtra("room");
		String startTime = intent.getStringExtra("startTime");
		String endTime = intent.getStringExtra("endTime");

		String displayTitle =
			(subject != null && !subject.isEmpty())
				? subject
				: (title != null && !title.isEmpty() ? title : "Upcoming class");
		String displayBody = buildBody(body, room, startTime, endTime);

		NotificationManager nm =
			(NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
		String channelId = "mysched_heads_up";
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
			&& nm.getNotificationChannel(channelId) == null) {
			NotificationChannel channel =
				new NotificationChannel(channelId, "Upcoming Class Alerts", NotificationManager.IMPORTANCE_HIGH);
			channel.setDescription("Heads-up notifications before class alarms fire");
			channel.enableVibration(true);
			channel.setLockscreenVisibility(NotificationCompat.VISIBILITY_PUBLIC);
			nm.createNotificationChannel(channel);
		}

		Intent openIntent = new Intent(context, MainActivity.class);
		openIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
		PendingIntent contentIntent = PendingIntent.getActivity(
			context,
			requestCode,
			openIntent,
			PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
		);

		NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channelId)
			.setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
			.setContentTitle(displayTitle)
			.setStyle(new NotificationCompat.BigTextStyle().bigText(displayBody))
			.setContentText(displayBody)
			.setPriority(NotificationCompat.PRIORITY_HIGH)
			.setCategory(NotificationCompat.CATEGORY_REMINDER)
			.setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
			.setAutoCancel(true)
			.setDefaults(NotificationCompat.DEFAULT_ALL)
			.setShowWhen(true)
			.setWhen(System.currentTimeMillis())
			.setContentIntent(contentIntent);

		NotificationManagerCompat.from(context).notify(requestCode, builder.build());
		forgetScheduledId(context, requestCode);
	}

	private String buildBody(String body, String room, String startTime, String endTime) {
		if (body != null && !body.isEmpty()) {
			return body;
		}
		StringBuilder builder = new StringBuilder();
		if (room != null && !room.trim().isEmpty()) {
			builder.append(room.trim());
		}
		String timeLabel = buildTimeLabel(startTime, endTime);
		if (!timeLabel.isEmpty()) {
			if (builder.length() > 0) {
				builder.append(" \u00B7 ");
			}
			builder.append(timeLabel);
		}
		if (builder.length() == 0) {
			builder.append("Class starting soon.");
		}
		return builder.toString();
	}

	private String buildTimeLabel(String startTime, String endTime) {
		String startLabel = startTime != null ? startTime.trim() : "";
		String endLabel = endTime != null ? endTime.trim() : "";
		if (!startLabel.isEmpty() && !endLabel.isEmpty()) {
			return startLabel + " - " + endLabel;
		}
		if (!startLabel.isEmpty()) {
			return startLabel;
		}
		if (!endLabel.isEmpty()) {
			return endLabel;
		}
		return "";
	}

	private void forgetScheduledId(Context context, int id) {
		android.content.SharedPreferences sp = context.getSharedPreferences(
			"com.example.mysched.alarms",
			Context.MODE_PRIVATE
		);
		java.util.Set<String> set = sp.getStringSet("ids", null);
		if (set == null || set.isEmpty()) return;
		java.util.Set<String> updated = new java.util.HashSet<>(set);
		if (updated.remove(Integer.toString(id))) {
			sp.edit().putStringSet("ids", updated).apply();
		}
	}
}
