# Keep ML Kit Text Recognition classes referenced via reflection by the Flutter plugin
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Keep classes from google.mlkit.vision.text.* options builders
-keep class com.google.mlkit.vision.text.** { *; }

# Flutter and Kotlin basics
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Keep R8 from removing the FullscreenAlarmActivity entry points
-keep class com.example.mysched.FullscreenAlarmActivity { *; }
-keep class com.example.mysched.MainActivity { *; }
