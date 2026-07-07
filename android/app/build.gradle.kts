plugins {
    id("com.android.application")
    id("kotlin-android")
    // Firebase Cloud Messaging — reads android/app/google-services.json.
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.plant_life"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications, which uses java.time APIs
        // that need desugaring on older Android versions.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Application ID must match the package_name in google-services.json
        // (com.plantLife) for Firebase Cloud Messaging to resolve its client
        // config. The Kotlin/namespace stays com.example.plant_life.
        applicationId = "com.plantLife"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Backports java.time (and friends) so flutter_local_notifications works on
    // API levels below 26. Version per the plugin's requirement (>= 2.1.4).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
