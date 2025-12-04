package com.ici.mysched.widget

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.security.MessageDigest

object WidgetImageCache {
    private const val TAG = "WidgetImageCache"
    private const val CACHE_DIR = "widget_avatars"
    
    /**
     * Downloads an image from URL and caches it locally.
     * Returns the local file path if successful, null otherwise.
     */
    fun cacheImageFromUrl(context: Context, imageUrl: String?): String? {
        if (imageUrl.isNullOrBlank()) {
            Log.d(TAG, "No image URL provided")
            return null
        }
        
        try {
            // Create cache directory
            val cacheDir = File(context.cacheDir, CACHE_DIR)
            if (!cacheDir.exists()) {
                cacheDir.mkdirs()
            }
            
            // Generate filename from URL hash
            val filename = urlToFilename(imageUrl)
            val cachedFile = File(cacheDir, filename)
            
            // Return cached file if it exists and is recent (< 24 hours)
            if (cachedFile.exists()) {
                val ageMs = System.currentTimeMillis() - cachedFile.lastModified()
                if (ageMs < 24 * 60 * 60 * 1000) {
                    Log.d(TAG, "Using cached image: ${cachedFile.absolutePath}")
                    return cachedFile.absolutePath
                }
            }
            
            // Download image
            Log.d(TAG, "Downloading image from: $imageUrl")
            val bitmap = downloadBitmap(imageUrl) ?: return null
            
            // Save to cache
            FileOutputStream(cachedFile).use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
                out.flush()
            }
            
            Log.d(TAG, "Image cached successfully: ${cachedFile.absolutePath}")
            return cachedFile.absolutePath
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to cache image from $imageUrl", e)
            return null
        }
    }
    
    private fun downloadBitmap(imageUrl: String): Bitmap? {
        var connection: HttpURLConnection? = null
        try {
            val url = URL(imageUrl)
            connection = url.openConnection() as HttpURLConnection
            connection.connectTimeout = 10000
            connection.readTimeout = 10000
            connection.doInput = true
            connection.connect()
            
            if (connection.responseCode != HttpURLConnection.HTTP_OK) {
                Log.e(TAG, "HTTP error: ${connection.responseCode}")
                return null
            }
            
            connection.inputStream.use { input ->
                return BitmapFactory.decodeStream(input)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Download failed", e)
            return null
        } finally {
            connection?.disconnect()
        }
    }
    
    private fun urlToFilename(url: String): String {
        val digest = MessageDigest.getInstance("MD5")
        val hash = digest.digest(url.toByteArray())
        return hash.joinToString("") { "%02x".format(it) } + ".png"
    }
    
    /**
     * Clear all cached images
     */
    fun clearCache(context: Context) {
        try {
            val cacheDir = File(context.cacheDir, CACHE_DIR)
            if (cacheDir.exists()) {
                cacheDir.listFiles()?.forEach { it.delete() }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to clear cache", e)
        }
    }
}
