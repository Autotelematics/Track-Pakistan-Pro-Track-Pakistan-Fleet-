import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    compileSdk = 36
    ndkVersion = if (extra.has("flutter.ndkVersion")) {
        extra["flutter.ndkVersion"] as String
    } else {
        "29.0.13599879"
    }

    namespace = "com.autotelnew.android"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true

    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    sourceSets {
        getByName("main") {
            java.srcDir("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.autotelnew.android"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = System.getenv("FLUTTER_VERSION_CODE")?.toIntOrNull() ?: 1
        versionName = System.getenv("FLUTTER_VERSION_NAME") ?: "1.0"
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val properties = Properties().apply {
                    load(FileInputStream(keystorePropertiesFile))
                }
                keyAlias = properties["keyAlias"] as String
                keyPassword = properties["keyPassword"] as String
                storeFile = file(properties["storeFile"] as String)
                storePassword = properties["storePassword"] as String
            } else {
                println("⚠️ Warning: key.properties file not found. Skipping release signing.")
            }
        }
    }


    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }

}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation(platform("com.google.firebase:firebase-bom:31.2.2"))
    implementation("com.google.firebase:firebase-analytics")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
