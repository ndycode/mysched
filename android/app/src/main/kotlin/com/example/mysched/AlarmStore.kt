package com.example.mysched

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

object AlarmStore {
    private const val PREFS_NAME = "com.example.mysched.alarms"
    private const val IDS_KEY = "ids"
    private const val FLUTTER_PREFS = "FlutterSharedPreferences"
    private const val CLASS_MAP_KEY = "flutter.notif_class_schedule_map"
    private const val NATIVE_IDS_KEY = "flutter.scheduled_native_alarm_ids"
    private const val SNOOZE_MINUTES_KEY = "flutter.snoozeMinutes"
    private const val LEGACY_SNOOZE_KEY = "flutter.default_snooze_minutes"

    @JvmStatic
    fun rememberAlarmId(context: Context, id: Int) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val current = prefs.getStringSet(IDS_KEY, mutableSetOf())?.toMutableSet()
            ?: mutableSetOf()
        current.add(id.toString())
        prefs.edit().putStringSet(IDS_KEY, current).apply()
    }

    @JvmStatic
    fun forgetAlarmId(context: Context, id: Int) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val current = prefs.getStringSet(IDS_KEY, mutableSetOf())?.toMutableSet()
            ?: mutableSetOf()
        if (current.remove(id.toString())) {
            prefs.edit().putStringSet(IDS_KEY, current).apply()
        }
    }

    @JvmStatic
    fun getRememberedAlarmIds(context: Context): Set<Int> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val current = prefs.getStringSet(IDS_KEY, emptySet()) ?: emptySet()
        return current.mapNotNull { it.toIntOrNull() }.toSet()
    }

    @JvmStatic
    fun addClassScheduleId(context: Context, classId: Int, id: Int) {
        if (classId == -1) return
        val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val root = readClassMap(prefs)
        val key = classId.toString()
        val set = root.optJSONArray(key)?.let { jsonArrayToSet(it) } ?: linkedSetOf()
        if (set.add(id)) {
            root.put(key, JSONArray(set.toList()))
            prefs.edit().putString(CLASS_MAP_KEY, root.toString()).apply()
        } else if (!root.has(key)) {
            root.put(key, JSONArray(set.toList()))
            prefs.edit().putString(CLASS_MAP_KEY, root.toString()).apply()
        }
    }

    @JvmStatic
    fun removeClassScheduleId(context: Context, classId: Int, id: Int) {
        if (classId == -1) return
        val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val root = readClassMap(prefs)
        val key = classId.toString()
        if (!root.has(key)) return
        val set = jsonArrayToSet(root.getJSONArray(key))
        if (set.remove(id)) {
            if (set.isEmpty()) {
                root.remove(key)
            } else {
                root.put(key, JSONArray(set.toList()))
            }
            prefs.edit().putString(CLASS_MAP_KEY, root.toString()).apply()
        }
    }

    @JvmStatic
    fun readSnoozeMinutes(context: Context): Int {
        val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val configured = readPositiveInt(prefs, SNOOZE_MINUTES_KEY)
        if (configured != null) return configured
        val legacy = readPositiveInt(prefs, LEGACY_SNOOZE_KEY)
        return legacy ?: 5
    }

    @JvmStatic
    fun clearOccurrenceAck(context: Context, classId: Int, occurrenceKey: String?) {
        if (classId == -1 || occurrenceKey.isNullOrEmpty()) return
        AlarmPrefsHelper.setOccurrenceAcknowledged(context, classId, occurrenceKey, false)
    }

    @JvmStatic
    fun addNativeId(context: Context, id: Int) {
        val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val list = readNativeIdList(prefs)
        val idString = id.toString()
        if (!list.contains(idString)) {
            list.add(idString)
            prefs.edit().putString(NATIVE_IDS_KEY, JSONArray(list).toString()).apply()
        }
    }

    @JvmStatic
    fun removeNativeId(context: Context, id: Int) {
        val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val list = readNativeIdList(prefs)
        val idString = id.toString()
        if (list.remove(idString)) {
            if (list.isEmpty()) {
                prefs.edit().remove(NATIVE_IDS_KEY).apply()
            } else {
                prefs.edit().putString(NATIVE_IDS_KEY, JSONArray(list).toString()).apply()
            }
        }
    }

    private fun readClassMap(prefs: SharedPreferences): JSONObject {
        val raw = prefs.getString(CLASS_MAP_KEY, "{}") ?: "{}"
        return try {
            JSONObject(raw)
        } catch (_: Exception) {
            JSONObject()
        }
    }

    private fun jsonArrayToSet(array: JSONArray): MutableSet<Int> {
        val result = linkedSetOf<Int>()
        for (i in 0 until array.length()) {
            val value = array.opt(i)
            when (value) {
                is Int -> result.add(value)
                is Number -> result.add(value.toInt())
                is String -> value.toIntOrNull()?.let { result.add(it) }
            }
        }
        return result
    }

    private fun readNativeIdList(prefs: SharedPreferences): MutableList<String> {
        val raw = prefs.getString(NATIVE_IDS_KEY, null) ?: return mutableListOf()
        return try {
            val array = JSONArray(raw)
            val list = mutableListOf<String>()
            for (i in 0 until array.length()) {
                val v = array.opt(i)
                if (v is String) {
                    list.add(v)
                } else if (v is Number) {
                    list.add(v.toString())
                }
            }
            list
        } catch (_: Exception) {
            mutableListOf()
        }
    }

    private fun readPositiveInt(prefs: SharedPreferences, key: String): Int? {
        return try {
            val value = prefs.getInt(key, -1)
            if (value > 0) value else null
        } catch (_: ClassCastException) {
            val raw = prefs.all[key]
            when (raw) {
                is Number -> {
                    val v = raw.toInt()
                    if (v > 0) v else null
                }
                is String -> raw.toIntOrNull()?.takeIf { it > 0 }
                else -> null
            }
        }
    }
}
