package com.ici.mysched.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import com.ici.mysched.MainActivity
import com.ici.mysched.R
import java.text.SimpleDateFormat
import java.util.*

/**
 * Widget provider for showing the next upcoming class.
 * Data is provided by Flutter via SharedPreferences.
 */
class NextClassWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "NextClassWidgetPrefs"
        private const val KEY_CLASS_TITLE = "class_title"
        private const val KEY_CLASS_CODE = "class_code"
        private const val KEY_START_TIME = "start_time"
        private const val KEY_END_TIME = "end_time"
        private const val KEY_ROOM = "room"
        private const val KEY_INSTRUCTOR = "instructor"
        private const val KEY_HAS_CLASS = "has_class"
        private const val KEY_LAST_UPDATE = "last_update"

        /**
         * Update the widget from Flutter side.
         */
        fun updateWidget(context: Context) {
            val intent = Intent(context, NextClassWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            val manager = AppWidgetManager.getInstance(context)
            val componentName = android.content.ComponentName(context, NextClassWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(componentName)
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            context.sendBroadcast(intent)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val views = RemoteViews(context.packageName, R.layout.widget_layout)

        val hasClass = prefs.getBoolean(KEY_HAS_CLASS, false)

        if (hasClass) {
            val title = prefs.getString(KEY_CLASS_TITLE, "") ?: ""
            val code = prefs.getString(KEY_CLASS_CODE, "") ?: ""
            val startTime = prefs.getString(KEY_START_TIME, "") ?: ""
            val endTime = prefs.getString(KEY_END_TIME, "") ?: ""
            val room = prefs.getString(KEY_ROOM, "") ?: ""
            val instructor = prefs.getString(KEY_INSTRUCTOR, "") ?: ""

            // Format display
            val displayTitle = if (code.isNotEmpty()) "$code - $title" else title
            val timeInfo = formatTimeInfo(startTime, endTime)

            views.setTextViewText(R.id.widget_class_title, displayTitle)
            views.setTextViewText(R.id.widget_time_info, timeInfo)
            views.setViewVisibility(R.id.widget_details_container, View.VISIBLE)

            if (room.isNotEmpty()) {
                views.setTextViewText(R.id.widget_room, room)
                views.setViewVisibility(R.id.widget_room_container, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_room_container, View.GONE)
            }

            if (instructor.isNotEmpty()) {
                views.setTextViewText(R.id.widget_instructor, instructor)
                views.setViewVisibility(R.id.widget_instructor_container, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_instructor_container, View.GONE)
            }
        } else {
            views.setTextViewText(R.id.widget_class_title, "No upcoming classes")
            views.setTextViewText(R.id.widget_time_info, "Enjoy your free time!")
            views.setViewVisibility(R.id.widget_details_container, View.GONE)
        }

        // Set click intent to open app
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            data = android.net.Uri.parse("mysched://schedule/today")
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_class_title, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun formatTimeInfo(startTime: String, endTime: String): String {
        if (startTime.isEmpty()) return "Check your schedule"

        try {
            val now = Calendar.getInstance()
            val inputFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
            val outputFormat = SimpleDateFormat("h:mm a", Locale.getDefault())

            val startDate = inputFormat.parse(startTime) ?: return "$startTime - $endTime"
            val startCalendar = Calendar.getInstance().apply { time = startDate }

            // Set to today
            startCalendar.set(Calendar.YEAR, now.get(Calendar.YEAR))
            startCalendar.set(Calendar.MONTH, now.get(Calendar.MONTH))
            startCalendar.set(Calendar.DAY_OF_MONTH, now.get(Calendar.DAY_OF_MONTH))

            val diffMinutes = (startCalendar.timeInMillis - now.timeInMillis) / (1000 * 60)

            return when {
                diffMinutes < 0 -> "In progress • ends at ${outputFormat.format(inputFormat.parse(endTime)!!)}"
                diffMinutes < 60 -> "Starts in ${diffMinutes}min"
                diffMinutes < 120 -> "Starts in 1h ${diffMinutes - 60}min"
                else -> "Starts at ${outputFormat.format(startDate)}"
            }
        } catch (e: Exception) {
            return "$startTime - $endTime"
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
    }
}
