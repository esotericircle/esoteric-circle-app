pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
    // Legge google-services.json e configura Firebase per l'app Android.
    id("com.google.gms.google-services") version "4.4.2" apply false
    // Genera il build ID di Crashlytics dentro le risorse dell'APK. SENZA
    // questo plugin la libreria firebase_crashlytics (entrata col fronte iOS,
    // commit 738a402) uccide FirebaseInitProvider al primo avvio Android:
    // "The Crashlytics build ID is missing", il crash della 2161 sul Realme
    // di Mauro, ordine 2162. La dipendenza Dart e il plugin Gradle vanno
    // SEMPRE insieme, su tutte e due le piattaforme.
    id("com.google.firebase.crashlytics") version "3.0.2" apply false
}

include(":app")
