package com.ici.mysched

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

object AlarmPrefsHelper {
    private const val PREFS_NAME = "com.example.mysched.alarms"
    private const val ACK_MAP_KEY = "notif_ack_map"

    @JvmStatic
    fun setOccurrenceAcknowledged(
        context: Context,
        classId: Int,
        occurrenceKey: String,
        acknowledged: Boolean,
    ) {
        if (classId == -1 || occurrenceKey.isEmpty()) return

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val boolKey = "ack_${classId}_${occurrenceKey}"
        prefs.edit().apply {
            if (acknowledged) {
                putBoolean(boolKey, true)
            } else {
                remove(boolKey)
            }
        }.apply()

        try {
            val root = JSONObject(prefs.getString(ACK_MAP_KEY, "{}") ?: "{}")
            val classKey = classId.toString()
            if (acknowledged) {
                val array = if (root.has(classKey)) root.getJSONArray(classKey) else JSONArray()
                if (!jsonArrayContains(array, occurrenceKey)) {
                    array.put(occurrenceKey)
                }
                root.put(classKey, array)
            } else if (root.has(classKey)) {
                val array = root.getJSONArray(classKey)
                val retained = mutableListOf<String>()
                for (i in 0 until array.length()) {
                    val value = array.optString(i)
                    if (value != occurrenceKey && value.isNotEmpty()) {
                        retained.add(value)
                    }
                }
                if (retained.isEmpty()) {
                    root.remove(classKey)
                } else {
                    root.put(classKey, JSONArray(retained))
                }
            }
            prefs.edit().putString(ACK_MAP_KEY, root.toString()).apply()
        } catch (_: Exception) {
            // ignore malformed JSON
        }
    }

    @JvmStatic
    fun isOccurrenceAcknowledged(
        context: Context,
        classId: Int,
        occurrenceKey: String,
    ): Boolean {
        if (classId == -1 || occurrenceKey.isEmpty()) return false
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val boolKey = "ack_${classId}_${occurrenceKey}"
        if (prefs.getBoolean(boolKey, false)) return true
        return try {
            val root = JSONObject(prefs.getString(ACK_MAP_KEY, "{}") ?: "{}")
            val classKey = classId.toString()
            if (!root.has(classKey)) return false
            jsonArrayContains(root.getJSONArray(classKey), occurrenceKey)
        } catch (_: Exception) {
            false
        }
    }

    private fun jsonArrayContains(array: JSONArray, value: String): Boolean {
        for (i in 0 until array.length()) {
            if (value == array.optString(i)) return true
        }
        return false
    }
}
