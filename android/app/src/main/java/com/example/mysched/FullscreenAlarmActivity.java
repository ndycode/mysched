package com.example.mysched;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.KeyguardManager;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.PowerManager;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;
import android.widget.LinearLayout;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.app.NotificationCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import java.util.Calendar;
import java.util.Locale;

import com.example.mysched.AlarmStore;

public class FullscreenAlarmActivity extends Activity {
    private String subject;
    private String room;
    private String startTime;
    private String endTime;
    private boolean acknowledged;
    @Override
    protected void onResume() {
        super.onResume();
        // Dismiss keyguard again in case device was locked after onCreate
        KeyguardManager keyguardManager = (KeyguardManager) getSystemService(Context.KEYGUARD_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            keyguardManager.requestDismissKeyguard(this, null);
        }
        // Re-apply immersive flags and aggressive window flags
        Window window = getWindow();
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON |
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON |
                        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED |
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD |
                        WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON |
                        WindowManager.LayoutParams.FLAG_FULLSCREEN |
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN |
                        WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
        applyImmersiveMode();
        // Reacquire wake locks aggressively
        PowerManager powerManager = (PowerManager) getSystemService(Context.POWER_SERVICE);
        if (wakeLock == null || !wakeLock.isHeld()) {
            wakeLock = powerManager.newWakeLock(
                PowerManager.FULL_WAKE_LOCK |
                PowerManager.ACQUIRE_CAUSES_WAKEUP |
                PowerManager.ON_AFTER_RELEASE, TAG);
            wakeLock.acquire(10 * 60 * 1000);
            logDebug("FULL_WAKE_LOCK reacquired in onResume");
        }
        if (partialWakeLock == null || !partialWakeLock.isHeld()) {
            partialWakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, TAG + "_Partial");
            partialWakeLock.acquire(10 * 60 * 1000);
            logDebug("PARTIAL_WAKE_LOCK reacquired in onResume");
        }
        // Restart alarm effects if needed
        if (mediaPlayer == null) {
            startAlarmSound();
        }
        if (vibrator == null) {
            startVibration();
        }
    }
    private static final String TAG = "MySched";
    private static final String LOG_SCOPE = "AlarmActivity";

    private PowerManager.WakeLock wakeLock;
    private PowerManager.WakeLock partialWakeLock;
    private MediaPlayer mediaPlayer;
    private Vibrator vibrator;
    private Handler handler;
    private Handler clockHandler;
    private Runnable stopAlarmRunnable;
    private Runnable timeTickRunnable;

    private String title;
    private String body;
    private int requestCode;
    private int classId;
    private String occurrenceKey;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        logDebug("FullscreenAlarmActivity onCreate launched");
        // Aggressively acquire wake locks at start
        PowerManager powerManager = (PowerManager) getSystemService(Context.POWER_SERVICE);
        if (wakeLock == null || !wakeLock.isHeld()) {
            wakeLock = powerManager.newWakeLock(
                PowerManager.FULL_WAKE_LOCK |
                PowerManager.ACQUIRE_CAUSES_WAKEUP |
                PowerManager.ON_AFTER_RELEASE, TAG);
            wakeLock.acquire(10 * 60 * 1000);
            logDebug("FULL_WAKE_LOCK acquired in onCreate");
        }
        if (partialWakeLock == null || !partialWakeLock.isHeld()) {
            partialWakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, TAG + "_Partial");
            partialWakeLock.acquire(10 * 60 * 1000);
            logDebug("PARTIAL_WAKE_LOCK acquired in onCreate");
        }

        // Get extras from intent
        Intent intent = getIntent();
        title = intent.getStringExtra("title");
        body = intent.getStringExtra("body");
        requestCode = intent.getIntExtra("requestCode", 0);
        classId = intent.getIntExtra("classId", -1);
        occurrenceKey = intent.getStringExtra("occurrenceKey");
        if (occurrenceKey == null) {
            occurrenceKey = "";
        }
        // Get class info for UI
        subject = intent.getStringExtra("subject");
        room = intent.getStringExtra("room");
        startTime = intent.getStringExtra("startTime");
        endTime = intent.getStringExtra("endTime");



        // Set up full screen alarm window
        setupFullscreenWindow();

        // Extra: immersive fullscreen and always-on flags
        Window window = getWindow();
        window.setBackgroundDrawableResource(R.drawable.fullscreen_alarm_background);
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON |
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON |
                        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED |
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD |
                        WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON |
                        WindowManager.LayoutParams.FLAG_FULLSCREEN |
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN |
                        WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
        applyImmersiveMode();

        // Always start alarm effects aggressively
        startAlarmEffects();

        // Try to set content view, fallback to TextView if layout fails
        boolean uiOk = false;
        try {
            setContentView(R.layout.activity_fullscreen_alarm);
            View root = findViewById(R.id.alarm_root);
            if (root != null) {
                root.setBackgroundResource(R.drawable.fullscreen_alarm_background);
            }
            initializeUI();
            uiOk = true;
        } catch (Exception e) {
            logError("Failed to set content view, using fallback UI", e);
        }
        if (!uiOk) {
            TextView tv = new TextView(this);
            tv.setText(
                (title != null ? title : "Alarm")
                    + "\n\n"
                    + (body != null ? body : "It's time!")
                    + "\n\nTap to dismiss.");
            tv.setGravity(android.view.Gravity.CENTER);
            tv.setTextSize(24f);
            tv.setTextColor(Color.WHITE);
            tv.setPadding(64, 64, 64, 64);
            tv.setBackgroundResource(R.drawable.fullscreen_alarm_background);
            tv.setOnClickListener(v -> dismissAlarm());
            setContentView(tv);
        }

        // Auto-dismiss after 2 minutes as fallback
        handler = new Handler(Looper.getMainLooper());
        stopAlarmRunnable = this::dismissAlarm;
        handler.postDelayed(stopAlarmRunnable, 2 * 60 * 1000); // 2 minutes
    }

    private void setupFullscreenWindow() {
        Window window = getWindow();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true);
            setTurnScreenOn(true);
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                    | WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                    | WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                    | WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                    | WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
            );
        }

        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                | WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
        );

        window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        );

        KeyguardManager keyguardManager = (KeyguardManager) getSystemService(Context.KEYGUARD_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && keyguardManager != null) {
            keyguardManager.requestDismissKeyguard(this, null);
        }

        applyImmersiveMode();
    }

    private void applyImmersiveMode() {
        Window window = getWindow();
        if (window == null) return;
        View decorView = window.getDecorView();
        WindowCompat.setDecorFitsSystemWindows(window, false);
        WindowInsetsControllerCompat controller =
            new WindowInsetsControllerCompat(window, decorView);
        controller.hide(
            WindowInsetsCompat.Type.statusBars() | WindowInsetsCompat.Type.navigationBars());
        controller.setSystemBarsBehavior(
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            decorView.setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
            );
        }
    }

    private void initializeUI() {
        TextView timeView = findViewById(R.id.alarm_time);
        TextView timeSubtitleView = findViewById(R.id.alarm_time_subtitle);
        TextView subjectView = findViewById(R.id.alarm_subject);
        TextView roomChipView = findViewById(R.id.alarm_chip_room);
        TextView timeChipView = findViewById(R.id.alarm_chip_time);
        TextView dateChipView = findViewById(R.id.alarm_chip_date);
        LinearLayout metaRow = findViewById(R.id.alarm_detail_meta);
        Button stopButton = findViewById(R.id.dismiss_button);
        Button snoozeButton = findViewById(R.id.snooze_button);
        Button remindersButton = findViewById(R.id.view_reminders_button);

        // Set current time in large font (update every second)
        if (timeView != null) {
            updateTimeView(timeView);
        }
        if (timeSubtitleView != null) {
            String subtitle = buildSubtitleLabel();
            if (!subtitle.isEmpty()) {
                timeSubtitleView.setText(subtitle);
                timeSubtitleView.setVisibility(View.VISIBLE);
            } else {
                timeSubtitleView.setVisibility(View.GONE);
            }
        }

        // Show subject, room, and time info clearly in fullscreen UI
        if (subjectView != null) {
            String subjectLabel = resolveSubjectLabel();
            if (!subjectLabel.isEmpty()) {
                subjectView.setText(subjectLabel);
                subjectView.setVisibility(View.VISIBLE);
            } else {
                subjectView.setVisibility(View.GONE);
            }
        }
        boolean metaVisible = false;
        if (roomChipView != null) {
            String roomLabel = room != null ? room.trim() : "";
            if (!roomLabel.isEmpty()) {
                roomChipView.setText(roomLabel);
                roomChipView.setVisibility(View.VISIBLE);
                metaVisible = true;
            } else {
                roomChipView.setVisibility(View.GONE);
            }
        }
        if (timeChipView != null) {
            String timeLabel = buildTimeLabel();
            if (!timeLabel.isEmpty()) {
                timeChipView.setText(timeLabel);
                timeChipView.setVisibility(View.VISIBLE);
                metaVisible = true;
            } else {
                timeChipView.setVisibility(View.GONE);
            }
        }
        if (dateChipView != null) {
            String dateLabel = buildDateLabel();
            if (!dateLabel.isEmpty()) {
                dateChipView.setText(dateLabel);
                dateChipView.setVisibility(View.VISIBLE);
                metaVisible = true;
            } else {
                dateChipView.setVisibility(View.GONE);
            }
        }
        if (metaRow != null) {
            metaRow.setVisibility(metaVisible ? View.VISIBLE : View.GONE);
        }

        if (stopButton != null) {
            stopButton.setText("Stop");
            stopButton.setOnClickListener(v -> dismissAlarm());
        }
        if (snoozeButton != null) {
            snoozeButton.setText("Snooze");
            snoozeButton.setOnClickListener(v -> snoozeAlarm());
        }
        if (remindersButton != null) {
            remindersButton.setText("View reminders");
            remindersButton.setOnClickListener(v -> openRemindersFromAlarm());
        }
    }

    private void openRemindersFromAlarm() {
        try {
            Intent intent = new Intent(this, MainActivity.class);
            intent.putExtra("navigate_to_reminders", true);
            intent.putExtra("reminder_scope", "today");
            intent.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK |
                Intent.FLAG_ACTIVITY_CLEAR_TOP |
                Intent.FLAG_ACTIVITY_SINGLE_TOP
            );
            startActivity(intent);
        } catch (Exception e) {
            logError("Failed to start reminders intent", e);
        } finally {
            dismissAlarm();
        }
    }

    private String resolveSubjectLabel() {
        if (subject != null) {
            String trimmed = subject.trim();
            if (!trimmed.isEmpty()) {
                return trimmed;
            }
        }
        if (title != null) {
            String trimmed = title.trim();
            if (!trimmed.isEmpty()) {
                return trimmed;
            }
        }
        return "";
    }

    private String buildTimeLabel() {
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

    private String buildDateLabel() {
        java.util.Date date = parseOccurrenceDate();
        if (date == null) return "";
        java.text.SimpleDateFormat fmt =
            new java.text.SimpleDateFormat("EEE, MMM d", Locale.getDefault());
        return fmt.format(date);
    }

    private String buildSubtitleLabel() {
        java.util.Date date = parseOccurrenceDate();
        StringBuilder builder = new StringBuilder();
        if (date != null) {
            java.text.SimpleDateFormat fmt =
                new java.text.SimpleDateFormat("EEEE, MMM d", Locale.getDefault());
            builder.append(fmt.format(date));
        }
        String startLabel = startTime != null ? startTime.trim() : "";
        if (!startLabel.isEmpty()) {
            if (builder.length() > 0) {
                builder.append(" · ");
            }
            builder.append(startLabel);
        }
        return builder.toString();
    }

    private java.util.Date parseOccurrenceDate() {
        if (occurrenceKey == null) return null;
        String trimmed = occurrenceKey.trim();
        if (trimmed.length() != 8) return null;
        try {
            java.text.SimpleDateFormat parser =
                new java.text.SimpleDateFormat("yyyyMMdd", Locale.US);
            parser.setLenient(false);
            return parser.parse(trimmed);
        } catch (Exception ignored) {
            return null;
        }
    }

    private void logDebug(String message) {
        android.util.Log.d(TAG, "[" + LOG_SCOPE + "] " + message);
    }

    private void logInfo(String message) {
        android.util.Log.i(TAG, "[" + LOG_SCOPE + "] " + message);
    }

    private void logWarn(String message) {
        android.util.Log.w(TAG, "[" + LOG_SCOPE + "] " + message);
    }

    private void logWarn(String message, Throwable t) {
        android.util.Log.w(TAG, "[" + LOG_SCOPE + "] " + message, t);
    }

    private void logError(String message) {
        android.util.Log.e(TAG, "[" + LOG_SCOPE + "] " + message);
    }

    private void logError(String message, Throwable t) {
        android.util.Log.e(TAG, "[" + LOG_SCOPE + "] " + message, t);
    }

    private void updateTimeView(TextView timeView) {
        if (clockHandler == null) {
            clockHandler = new Handler(Looper.getMainLooper());
        }
        timeTickRunnable = new Runnable() {
            @Override
            public void run() {
                java.text.SimpleDateFormat sdf =
                    new java.text.SimpleDateFormat("h:mm", java.util.Locale.getDefault());
                String time = sdf.format(new java.util.Date());
                timeView.setText(time);
                if (clockHandler != null) {
                    clockHandler.postDelayed(this, 1000);
                }
            }
        };
        clockHandler.post(timeTickRunnable);
    }

    private void startAlarmEffects() {
        // Acquire both FULL and PARTIAL wake locks for maximum reliability
        PowerManager powerManager = (PowerManager) getSystemService(Context.POWER_SERVICE);
        wakeLock = powerManager.newWakeLock(
            PowerManager.FULL_WAKE_LOCK |
            PowerManager.ACQUIRE_CAUSES_WAKEUP |
            PowerManager.ON_AFTER_RELEASE, TAG);
        wakeLock.acquire(10 * 60 * 1000); // 10 minutes
        logDebug("FULL_WAKE_LOCK acquired");
        partialWakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, TAG + "_Partial");
        partialWakeLock.acquire(10 * 60 * 1000);
        logDebug("PARTIAL_WAKE_LOCK acquired");

        // Start alarm sound
        startAlarmSound();

        // Start vibration
        startVibration();
    }

    private void startAlarmSound() {
        try {
            // Use default alarm ringtone
            Uri alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM);
            if (alarmUri == null) {
                alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE);
            }

            mediaPlayer = new MediaPlayer();
            mediaPlayer.setAudioAttributes(
                new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            );
            mediaPlayer.setDataSource(this, alarmUri);
            mediaPlayer.setLooping(true);
            mediaPlayer.prepare();
            mediaPlayer.start();

            // Set volume to max for alarm stream
            AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
            audioManager.setStreamVolume(
                AudioManager.STREAM_ALARM,
                audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM),
                0
            );

            logDebug("Alarm sound started");
        } catch (Exception e) {
            logError("Alarm sound error", e);
            // Fallback: try notification sound
            try {
                Uri fallbackUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                mediaPlayer = new MediaPlayer();
                mediaPlayer.setAudioAttributes(
                    new AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                );
                mediaPlayer.setDataSource(this, fallbackUri);
                mediaPlayer.setLooping(true);
                mediaPlayer.prepare();
                mediaPlayer.start();
                logDebug("Fallback notification sound started");
            } catch (Exception ex) {
                logError("Fallback sound error", ex);
            }
        }
    }

    private void startVibration() {
        vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
        if (vibrator == null || !vibrator.hasVibrator()) {
            logDebug("No vibrator available for alarm");
            return;
        }
        long[] pattern = new long[]{0, 700, 300, 700};
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                VibrationEffect effect = VibrationEffect.createWaveform(pattern, 0);
                vibrator.vibrate(effect);
            } else {
                vibrator.vibrate(pattern, 0);
            }
            logDebug("Alarm vibration started");
        } catch (Exception e) {
            logError("Failed to start vibration", e);
        }
    }

    // Make dismissAlarm public so it can be called from lambdas
    public void dismissAlarm() {
        stopAlarmInternal(true);
        postReminderNotification();
        finish();
    }

    // Add missing stopAlarm and snoozeAlarm methods
    public void stopAlarm() {
        stopAlarmInternal(true);
    }

    private void stopAlarmInternal(boolean acknowledge) {
        if (acknowledge) {
            markAcknowledged();
        } else {
            AlarmStore.clearOccurrenceAck(this, classId, occurrenceKey);
        }
        if (classId != -1) {
            AlarmStore.removeClassScheduleId(this, classId, requestCode);
        }
        AlarmStore.forgetAlarmId(this, requestCode);
        AlarmStore.removeNativeId(this, requestCode);
        // Cancel auto-dismiss
        if (handler != null && stopAlarmRunnable != null) {
            handler.removeCallbacks(stopAlarmRunnable);
        }
        if (clockHandler != null && timeTickRunnable != null) {
            clockHandler.removeCallbacks(timeTickRunnable);
        }
        stopAlarmRunnable = null;
        handler = null;
        timeTickRunnable = null;
        clockHandler = null;
        // Stop sound
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer.release();
            mediaPlayer = null;
        }
        // Stop vibration
        if (vibrator != null) {
            vibrator.cancel();
            vibrator = null;
        }
        // Release wake locks
        if (wakeLock != null && wakeLock.isHeld()) {
            wakeLock.release();
            wakeLock = null;
        }
        if (partialWakeLock != null && partialWakeLock.isHeld()) {
            partialWakeLock.release();
            partialWakeLock = null;
        }
        // Dismiss notification if any
        NotificationManagerCompat.from(this).cancel(requestCode);
    }

    public void snoozeAlarm() {
        int minutes = Math.max(1, AlarmStore.readSnoozeMinutes(this));
        stopAlarmInternal(false);
        long triggerAt = System.currentTimeMillis() + minutes * 60_000L;
        int newRequestCode = buildSnoozeRequestCode(classId, triggerAt);
        String newOccurrenceKey = buildOccurrenceKey(triggerAt);
        scheduleSnoozedAlarm(triggerAt, newRequestCode, newOccurrenceKey);
        AlarmStore.clearOccurrenceAck(this, classId, newOccurrenceKey);
        showSnoozeFeedback(minutes);
        finish();
    }

    private void scheduleSnoozedAlarm(long triggerAt, int newRequestCode, String newOccurrenceKey) {
        AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
        if (alarmManager == null) return;

        Intent broadcastIntent = new Intent(this, AlarmReceiver.class);
        broadcastIntent.putExtra("title", title);
        broadcastIntent.putExtra("body", body);
        broadcastIntent.putExtra("requestCode", newRequestCode);
        broadcastIntent.putExtra("classId", classId);
        broadcastIntent.putExtra("occurrenceKey", newOccurrenceKey);
        if (subject != null) {
            broadcastIntent.putExtra("subject", subject);
        }
        if (room != null) {
            broadcastIntent.putExtra("room", room);
        }
        if (startTime != null) {
            broadcastIntent.putExtra("startTime", startTime);
        }
        if (endTime != null) {
            broadcastIntent.putExtra("endTime", endTime);
        }
        PendingIntent broadcastPi = PendingIntent.getBroadcast(
            this,
            newRequestCode,
            broadcastIntent,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        AlarmManager.AlarmClockInfo info =
            new AlarmManager.AlarmClockInfo(triggerAt, broadcastPi);
        alarmManager.setAlarmClock(info, broadcastPi);
        AlarmStore.rememberAlarmId(this, newRequestCode);
        if (classId != -1) {
            AlarmStore.addClassScheduleId(this, classId, newRequestCode);
        }
        AlarmStore.addNativeId(this, newRequestCode);
        this.requestCode = newRequestCode;
        this.occurrenceKey = newOccurrenceKey;
    }

    private int buildSnoozeRequestCode(int classIdValue, long triggerAt) {
        long hash = 17L;
        hash = hash * 31L + classIdValue;
        hash = hash * 31L + (triggerAt & 0x7fffffffL);
        return (int) (Math.abs(hash) & 0x7fffffff);
    }

    private String buildOccurrenceKey(long millis) {
        Calendar cal = Calendar.getInstance();
        cal.setTimeInMillis(millis);
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH) + 1;
        int day = cal.get(Calendar.DAY_OF_MONTH);
        return String.format(Locale.US, "%04d%02d%02d", year, month, day);
    }

    private void showSnoozeFeedback(int minutes) {
        String channelId = "mysched_snooze_feedback";
        NotificationManager nm =
            (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (nm == null) return;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            nm.getNotificationChannel(channelId) == null) {
            NotificationChannel channel = new NotificationChannel(
                channelId,
                "Snooze Feedback",
                NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription("Confirms when reminders are snoozed");
            channel.enableVibration(false);
            nm.createNotificationChannel(channel);
        }
        String text = minutes == 1
            ? "Reminder snoozed for 1 minute"
            : "Reminder snoozed for " + minutes + " minutes";
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("Snoozed")
            .setContentText(text)
            .setStyle(new NotificationCompat.BigTextStyle().bigText(text))
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setAutoCancel(true)
            .setShowWhen(true)
            .setWhen(System.currentTimeMillis());
        nm.notify(0x5A5A, builder.build());
    }

    private void markAcknowledged() {
        if (!acknowledged && classId != -1 && occurrenceKey != null && !occurrenceKey.isEmpty()) {
            AlarmPrefsHelper.setOccurrenceAcknowledged(this, classId, occurrenceKey, true);
            acknowledged = true;
        }
    }

    private void postReminderNotification() {
        Handler reminderHandler = new Handler(Looper.getMainLooper());
        reminderHandler.postDelayed(this::showReminderNotification, 2000);
    }

    private void showReminderNotification() {
        String displayTitle = (subject != null && !subject.isEmpty())
            ? subject
            : (title != null && !title.isEmpty() ? title : "Class reminder");
        String displayBody = buildReminderBody();

        NotificationManager nm =
            (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
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

        Intent openIntent = new Intent(this, MainActivity.class);
        openIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent contentIntent = PendingIntent.getActivity(
            this,
            requestCode + 4,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        int reminderId = requestCode + 2000;

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, channelId)
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

        NotificationManagerCompat.from(this).notify(reminderId, builder.build());
    }

    private String buildReminderBody() {
        if (body != null && !body.isEmpty()) {
            return body;
        }
        StringBuilder builder = new StringBuilder();
        if (room != null && !room.trim().isEmpty()) {
            builder.append(room.trim());
        }
        String timeLabel = buildTimeLabel();
        if (!timeLabel.isEmpty()) {
            if (builder.length() > 0) {
                builder.append(" - ");
            }
            builder.append(timeLabel);
        }
        if (builder.length() == 0) {
            builder.append("Class starting soon.");
        }
        return builder.toString();
    }

    @Override
    protected void onDestroy() {
        stopAlarm();
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
        dismissAlarm();
        super.onBackPressed();
    }

}


