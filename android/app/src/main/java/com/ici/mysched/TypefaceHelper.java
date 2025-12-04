package com.ici.mysched;

import android.content.Context;
import android.graphics.Typeface;
import android.util.Log;
import java.util.HashMap;
import java.util.Map;

public class TypefaceHelper {
    private static final String TAG = "MySched";
    private static final Map<String, Typeface> cache = new HashMap<>();

    public static Typeface get(Context context, String fontName) {
        if (cache.containsKey(fontName)) {
            Log.d(TAG, "[TypefaceHelper] Font retrieved from cache: " + fontName);
            return cache.get(fontName);
        }
        
        try {
            String fontPath = "fonts/" + fontName;
            Log.d(TAG, "[TypefaceHelper] Attempting to load font: " + fontPath);
            Typeface typeface = Typeface.createFromAsset(
                context.getAssets(), 
                fontPath
            );
            cache.put(fontName, typeface);
            Log.d(TAG, "[TypefaceHelper] Successfully loaded font: " + fontName);
            return typeface;
        } catch (Exception e) {
            Log.e(TAG, "[TypefaceHelper] Failed to load font: " + fontName, e);
            return Typeface.DEFAULT;
        }
    }

    public static Typeface getSFProRounded(Context context, FontWeight weight) {
        try {
            String fontFile;
            switch (weight) {
                case BLACK:
                    fontFile = "SF-Pro-Rounded-Black.otf";
                    break;
                case HEAVY:
                    fontFile = "SF-Pro-Rounded-Heavy.otf";
                    break;
                case BOLD:
                    fontFile = "SF-Pro-Rounded-Bold.otf";
                    break;
                case SEMIBOLD:
                    fontFile = "SF-Pro-Rounded-Semibold.otf";
                    break;
                case MEDIUM:
                    fontFile = "SF-Pro-Rounded-Medium.otf";
                    break;
                case REGULAR:
                default:
                    fontFile = "SF-Pro-Rounded-Regular.otf";
                    break;
            }
            Typeface typeface = get(context, fontFile);
            return typeface != null ? typeface : Typeface.DEFAULT;
        } catch (Exception e) {
            Log.e(TAG, "[TypefaceHelper] Error in getSFProRounded", e);
            return Typeface.DEFAULT;
        }
    }

    public enum FontWeight {
        REGULAR,
        MEDIUM,
        SEMIBOLD,
        BOLD,
        HEAVY,
        BLACK
    }
}
