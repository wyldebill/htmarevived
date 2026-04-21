import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}


dependencies {
  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:34.12.0"))


  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  // https://firebase.google.com/docs/android/setup#available-libraries
}

val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { load(it) }
    }
}

val dotEnvProperties = Properties().apply {
    val dotEnvFile = rootProject.file("../.env")
    if (dotEnvFile.exists()) {
        dotEnvFile.forEachLine { rawLine ->
            val line = rawLine.trim()
            if (line.isEmpty() || line.startsWith("#")) return@forEachLine
            val separatorIndex = line.indexOf('=')
            if (separatorIndex <= 0) return@forEachLine
            val key = line.substring(0, separatorIndex).trim()
            val value = line.substring(separatorIndex + 1).trim().trim('"')
            setProperty(key, value)
        }
    }
}

val googleMapsApiKey =
    providers.environmentVariable("GOOGLE_MAPS_API_KEY").orNull
        ?: localProperties.getProperty("GOOGLE_MAPS_API_KEY", "")
            .ifEmpty { dotEnvProperties.getProperty("GOOGLE_MAPS_API_KEY", "") }

android {
    namespace = "com.example.htmarevived"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.htmarevived"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
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
