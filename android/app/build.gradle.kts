import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase: applica la configurazione da google-services.json.
    id("com.google.gms.google-services")
}

android {
    namespace = "com.esotericircle.esoteric_circle"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.esotericircle.esoteric_circle"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Firebase Auth e Firestore richiedono almeno l'API 23.
        minSdk = maxOf(23, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // S2. Il filtro degli ABI vale anche per le librerie native dei
        // plugin. L'opzione --target-platform di Flutter agisce sul solo
        // motore, non su ML Kit e compagnia: per questo l'archivio portava
        // tre architetture mentre un telefono ne usa una sola, 14,6 MB che
        // nessuno esegue. Restano le due che servono ai dispositivi veri.
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a")
        }
    }

    packaging {
        jniLibs {
            // S1. Il validatore Vulkan pesa 14,5 MB e serve solo a chi
            // sviluppa il motore grafico: nell'archivio che si consegna non
            // ha nessuna ragione di esserci.
            excludes += listOf(
                "**/libVkLayer_khronos_validation.so",
                // abiFilters non basta: le librerie dei plugin arrivano
                // gia' compilate dentro gli AAR, e quel filtro governa
                // cio' che si compila, non cio' che si copia. Verificato
                // aprendo l'archivio: x86_64 c'era ancora, 9,4 MB che
                // nessun telefono esegue. Gli emulatori su Mac Apple
                // usano arm64, quindi non serve nemmeno a chi sviluppa.
                "lib/x86_64/**",
                "lib/x86/**",
            )
        }
    }

    // La firma di release legge chiave, alias e password da
    // android/key.properties, che NON sta su Git. Se il file manca, la build
    // di release si ferma con un messaggio chiaro invece di firmare con la
    // chiave di debug, che sta sul disco di chiunque abbia Flutter: una firma
    // cosi' non identifica nessuno, rende l'app falsificabile e Google Play
    // la rifiuta al caricamento. Il keystore vero lo generera' Mauro alla
    // pubblicazione.
    val keyPropertiesFile = rootProject.file("key.properties")
    val keyProperties = Properties()
    if (keyPropertiesFile.exists()) {
        keyProperties.load(FileInputStream(keyPropertiesFile))
    }

    signingConfigs {
        create("release") {
            if (keyPropertiesFile.exists()) {
                storeFile = keyProperties["storeFile"]?.let { file(it) }
                storePassword = keyProperties["storePassword"] as String?
                keyAlias = keyProperties["keyAlias"] as String?
                keyPassword = keyProperties["keyPassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// La guardia scatta quando si costruisce davvero una release, non mentre
// Gradle configura il progetto: valutata in configurazione fermerebbe anche
// le build di debug, che con la firma di pubblicazione non c'entrano nulla.
tasks.matching { it.name.contains("Release") }.configureEach {
    doFirst {
        if (!rootProject.file("key.properties").exists()) {
            throw GradleException(
                "Firma di release assente: manca android/key.properties. " +
                "Crealo con storeFile, storePassword, keyAlias e keyPassword " +
                "del keystore di pubblicazione. Non si firma con la chiave " +
                "di debug, che sta sul disco di chiunque abbia Flutter."
            )
        }
    }
}
