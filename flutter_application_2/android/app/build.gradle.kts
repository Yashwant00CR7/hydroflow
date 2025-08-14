plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase plugin
}

android {
    namespace = "com.example.flutter_application_2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Updated to required version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.flutter_application_2"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("debug")
        isMinifyEnabled = true
        proguardFiles(
            getDefaultProguardFile("proguard-android.txt"),
            "proguard-rules.pro"
        )
    }
}
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.5.0")) // ✅ Kotlin DSL format
    implementation("com.google.firebase:firebase-auth") // ✅ Kotlin DSL format
    // You can add more Firebase dependencies similarly
}
