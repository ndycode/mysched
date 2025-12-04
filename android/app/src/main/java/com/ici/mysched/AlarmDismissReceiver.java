package com.ici.mysched;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import androidx.core.app.NotificationManagerCompat;

public class AlarmDismissReceiver extends BroadcastReceiver {
	@Override
	public void onReceive(Context context, Intent intent) {
		int notificationId = intent.getIntExtra("notification_id", -1);
		if (notificationId != -1) {
			// Dismiss the notification
			NotificationManagerCompat.from(context).cancel(notificationId);
		}
		int classId = intent.getIntExtra("classId", -1);
		String occurrenceKey = intent.getStringExtra("occurrenceKey");
		if (classId != -1 && occurrenceKey != null && !occurrenceKey.isEmpty()) {
			AlarmPrefsHelper.setOccurrenceAcknowledged(context, classId, occurrenceKey, true);
		}
	}
}
