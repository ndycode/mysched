package com.ici.mysched.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import com.ici.mysched.R
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*

class MySchedWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, MySchedWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }
        }
        
        private fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                val views = RemoteViews(context.packageName, R.layout.widget_small)

                // FORCE DUMMY DATA FOR VERIFICATION
                val nextClassSubject = "Visual Design (Lab)"
                val nextClassTime = "1:00 PM - 4:00 PM"
                val nextClassLocation = "Design Studio A"
                val nextClassInstructor = "Prof. Anderson"
                val isOngoing = true

                // Set class title
                views.setTextViewText(R.id.widget_subject, nextClassSubject)
                
                // Set time
                views.setTextViewText(R.id.widget_time, nextClassTime)
                
                // Set current date
                val dateFormat = SimpleDateFormat("EEE, MMM d", Locale.getDefault())
                val currentDate = dateFormat.format(Date())
                views.setTextViewText(R.id.widget_date, currentDate)
                
                // Set location
                views.setViewVisibility(R.id.widget_location_row, View.VISIBLE)
                views.setTextViewText(R.id.widget_location, nextClassLocation)
                
                // Set instructor
                views.setViewVisibility(R.id.widget_instructor_row, View.VISIBLE)
                views.setTextViewText(R.id.widget_instructor, nextClassInstructor)
                
                // ENABLE BITMAP LOADING (Using a dummy URL logic for now, or just resource if URL missing)
                // For this test, we will try to load a real image if we had one, but since we are forcing data,
                // let's try to load a placeholder from a URL if we can, or just stick to resource for safety first.
                // Actually, let's TEST THE BITMAP LOGIC with a safe fallback.
                // Since we don't have a real URL in dummy data, we will use the default icon for now.
                // BUT, I will uncomment the bitmap loading logic so it's ready for real data.
                
                val nextClassInstructorAvatar = widgetData.getString("next_class_instructor_avatar", null)
                if (!nextClassInstructorAvatar.isNullOrEmpty()) {
                     // Download and cache avatar in background
                    Thread {
                        val cachedPath = WidgetImageCache.cacheImageFromUrl(context, nextClassInstructorAvatar)
                        if (cachedPath != null) {
                            try {
                                // Downscale bitmap to avoid Binder transaction limit
                                val options = android.graphics.BitmapFactory.Options()
                                options.inJustDecodeBounds = true
                                android.graphics.BitmapFactory.decodeFile(cachedPath, options)
                                
                                val reqWidth = 100 // Target size (approx 24dp * density)
                                val reqHeight = 100
                                var inSampleSize = 1
                                
                                if (options.outHeight > reqHeight || options.outWidth > reqWidth) {
                                    val halfHeight: Int = options.outHeight / 2
                                    val halfWidth: Int = options.outWidth / 2
                                    while ((halfHeight / inSampleSize) >= reqHeight && (halfWidth / inSampleSize) >= reqWidth) {
                                        inSampleSize *= 2
                                    }
                                }

                                options.inJustDecodeBounds = false
                                options.inSampleSize = inSampleSize
                                
                                val bitmap = android.graphics.BitmapFactory.decodeFile(cachedPath, options)
                                if (bitmap != null) {
                                    views.setImageViewBitmap(R.id.widget_instructor_avatar, bitmap)
                                    appWidgetManager.updateAppWidget(appWidgetId, views)
                                }
                            } catch (e: Exception) {
                                android.util.Log.e("MySchedWidget", "Failed to load avatar", e)
                            }
                        }
                    }.start()
                } else {
                    views.setImageViewResource(R.id.widget_instructor_avatar, R.drawable.ic_widget_instructor)
                }

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                android.util.Log.e("MySchedWidget", "Error updating widget", e)
            }
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        Companion.updateAppWidget(context, appWidgetManager, appWidgetId)
    }
}
