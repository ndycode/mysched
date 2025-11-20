plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.mysched"
    compileSdk = 36 // Use explicit API level for stability
    ndkVersion = "27.0.12077973"

    defaultConfig {
    applicationId = "com.example.mysched"
    minSdk = 24 // Minimum recommended for modern Flutter plugins
    targetSdk = 36 // Match compileSdk for best compatibility
    versionCode = 1 // Update as needed for releases
    versionName = "1.0.0" // Update as needed for releases
    }

    buildTypes {
        debug {
            // Default debug config
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            // Use release signingConfig if available
            // signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // REQUIRED for flutter_local_notifications
    compileOptions {
    // Enable desugaring to use newer Java APIs on older Android
    isCoreLibraryDesugaringEnabled = true
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
    jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib")
    // REQUIRED: desugared JDK libs
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    implementation("androidx.constraintlayout:constraintlayout:2.1.4")

    // ML Kit Text Recognition base and script-specific models to satisfy plugin references
    implementation("com.google.mlkit:text-recognition:16.0.0")
    implementation("com.google.mlkit:text-recognition-chinese:16.0.0")
    implementation("com.google.mlkit:text-recognition-devanagari:16.0.0")
    implementation("com.google.mlkit:text-recognition-japanese:16.0.0")
    implementation("com.google.mlkit:text-recognition-korean:16.0.0")
}
