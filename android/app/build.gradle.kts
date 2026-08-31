import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase: applica la configurazione da google-services.json.
    id("com.google.gms.google-services")
    // Crashlytics: genera il build ID senza cui la libreria uccide l'app
    // all'avvio. La ragione intera sta in settings.gradle.kts, ordine 2162.
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.esotericircle.esoteric_circle"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // IL DESUGARING DELLE LIBRERIE DI BASE, e non e' una scelta.
        //
        // `flutter_local_notifications` lo PRETENDE, e senza di esso la build
        // non parte affatto: si ferma a `checkReleaseAarMetadata` dicendo che
        // la dipendenza richiede core library desugaring.
        //
        // **Nessuna prova poteva prenderlo.** L'ordine che ha aggiunto le
        // notifiche vietava la build, quindi la suite era verde e l'analisi
        // pulita mentre l'app non si costruiva. E' il difetto che si vede solo
        // costruendo, ed e' la ragione per cui una build va fatta prima di
        // consegnare e non dopo.
        isCoreLibraryDesugaringEnabled = true
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

        // **UNA SOLA ARCHITETTURA, arm64-v8a, ed e' una scelta del
        // fondatore, ordine CH del 31 agosto 2026.** Messo davanti alle due
        // strade, rimettere i 32 bit e tornare a 195 MB oppure toglierli
        // davvero, ha risposto "B".
        //
        // **QUI, e non nel comando di build, perche' qui e' successo il
        // difetto.** La 2216 e' stata costruita con --target-platform
        // android-arm64, che agisce SOLO sul motore Flutter: il filtro qui
        // sotto diceva ancora due architetture, quindi armeabi-v7a e'
        // rimasta nell'archivio con le sole cinque librerie dei plugin,
        // senza libflutter.so e senza libapp.so. Ventuno megabyte in meno e
        // un'app che su un telefono a 32 bit non ha un motore da avviare.
        // Nessuna delle 4.175 prove lo ha visto, e a trovarlo e' stato il
        // fondatore leggendo due pesi su App Tester.
        //
        // Scritta qui, la scelta vale QUALUNQUE comando qualcuno lanci: con
        // o senza --target-platform, l'archivio esce con una cartella sola.
        // Il filtro degli ABI vale anche per le librerie native dei plugin,
        // che --target-platform non tocca.
        //
        // Cosa si perde, detto e non nascosto: i telefoni Android col solo
        // processore a 32 bit non possono installare l'app.
        ndk {
            abiFilters += listOf("arm64-v8a")
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
                // **E armeabi-v7a esce di qui, non solo dagli abiFilters.**
                // Ordine CH voce 06. Il commento qui sopra lo dice gia' e
                // vale identico: quel filtro governa cio' che si COMPILA,
                // queste esclusioni governano cio' che si COPIA, e le
                // librerie dei plugin arrivano gia' compilate dentro gli
                // AAR. Nella 2216 sono rimaste esattamente cosi': cinque
                // librerie di plugin a 32 bit dentro una cartella senza
                // motore. Due serrature, perche' una sola era gia' stata
                // misurata insufficiente su x86_64.
                "lib/armeabi-v7a/**",
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

// La libreria che porta le API di Java 8 sulle versioni di Android che non le
// hanno. La pretende `flutter_local_notifications` per programmare gli avvisi.
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
