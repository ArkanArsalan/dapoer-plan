plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dapoer_plan.new_dapoer_plan_project_fresh"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.dapoer_plan.new_dapoer_plan_project_fresh"
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
    // INI BARIS YANG SANGAT KRUSIAL
    implementation("org.tensorflow:tensorflow-lite-select-tf-ops:2.11.0")

    // Pastikan dependensi lain seperti camera, image_picker, http, logger, cupertino_icons
    // juga ada di sini sesuai pubspec.yaml Anda.
    // Contoh:
    // implementation("com.google.android.gms:play-services-ads:23.0.0")
    // implementation("androidx.camera:camera-camera2:1.3.3")
}