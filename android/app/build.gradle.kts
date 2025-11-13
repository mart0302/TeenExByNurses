plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.app_enfermeria"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // 🔧 Cambiado desde flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.app_enfermeria"
        minSdk = 23 // 🔧 Asegurado que sea mínimo 23 (Firebase lo requiere)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ BOM (Bill of Materials) para controlar versiones automáticamente
    implementation(platform("com.google.firebase:firebase-bom:33.14.0"))

    // ✅ Agrega los productos de Firebase que vayas a usar
    // Por ejemplo, Analytics (puedes quitarlo si no lo usas):
    implementation("com.google.firebase:firebase-analytics")
}
