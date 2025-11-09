plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // was: kotlin-android
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.testflutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // was 11
        targetCompatibility = JavaVersion.VERSION_17 // was 11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString() // was 11
    }

    defaultConfig {
        applicationId = "com.example.testflutter"
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
