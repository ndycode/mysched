    private void initializeUI() {
        // Header elements
        TextView ringingTimeView = findViewById(R.id.ringing_time);
        
        // Time card elements
        TextView timeView = findViewById(R.id.alarm_time);
        TextView countdownView = findViewById(R.id.alarm_countdown);
        TextView dateView = findViewById(R.id.alarm_date);
        
        // Context card elements
        TextView nextClassView = findViewById(R.id.next_class_label);
        
        // Buttons
        Button stopButton = findViewById(R.id.dismiss_button);
        Button snoozeButton = findViewById(R.id.snooze_button);
        Button remindersButton = findViewById(R.id.view_reminders_button);

        // Set ringing time (current time when alarm fired)
        if (ringingTimeView != null) {
            java.text.SimpleDateFormat sdf = 
                new java.text.SimpleDateFormat("hh:mm a", java.util.Locale.getDefault());
            ringingTimeView.setText(sdf.format(new java.util.Date()));
        }

        // Set current time in large font (update every second)
        if (timeView != null) {
            updateTimeView(timeView);
        }

        // Set countdown timer (2 minutes auto-dismiss)
        if (countdownView != null) {
            startCountdownTimer(countdownView);
        }

        // Set date
        if (dateView != null) {
            String dateLabel = buildDateLabel();
            if (!dateLabel.isEmpty()) {
                dateView.setText(dateLabel);
            } else {
                java.text.SimpleDateFormat fmt = 
                    new java.text.SimpleDateFormat("EEE, MMM d", Locale.getDefault());
                dateView.setText(fmt.format(new java.util.Date()));
            }
        }

        // Set next class info
        if (nextClassView != null) {
            String nextClassLabel = buildNextClassLabel();
            if (!nextClassLabel.isEmpty()) {
                nextClassView.setText(nextClassLabel);
            } else {
                nextClassView.setText("Next: " + (subject != null ? subject : "Class") + 
                    (startTime != null ? " at " + startTime : ""));
            }
        }

        // Set up buttons
        if (stopButton != null) {
            stopButton.setOnClickListener(v -> dismissAlarm());
        }
        if (snoozeButton != null) {
            int snoozeMinutes = Math.max(1, AlarmStore.readSnoozeMinutes(this));
            snoozeButton.setText("Snooze " + snoozeMinutes + " min");
            snoozeButton.setOnClickListener(v -> snoozeAlarm());
        }
        if (remindersButton != null) {
            remindersButton.setOnClickListener(v -> openRemindersFromAlarm());
        }
    }

    private String buildNextClassLabel() {
        if (subject != null && startTime != null) {
            return "Next: " + subject + " at " + startTime;
        }
        if (subject != null) {
            return "Next: " + subject;
        }
        if (title != null && startTime != null) {
            return "Next: " + title + " at " + startTime;
        }
        return "";
    }

    private void startCountdownTimer(TextView countdownView) {
        final long endTime = System.currentTimeMillis() + (2 * 60 * 1000); // 2 minutes
        final Handler countdownHandler = new Handler(Looper.getMainLooper());
        final Runnable countdownRunnable = new Runnable() {
            @Override
            public void run() {
                long remaining = endTime - System.currentTimeMillis();
                if (remaining > 0) {
                    int minutes = (int) (remaining / 60000);
                    int seconds = (int) ((remaining % 60000) / 1000);
                    countdownView.setText(String.format(Locale.getDefault(), 
                        "Alarm stops in %02d:%02d", minutes, seconds));
                    countdownHandler.postDelayed(this, 1000);
                } else {
                    countdownView.setText("Alarm stopping...");
                }
            }
        };
        countdownHandler.post(countdownRunnable);
    }
