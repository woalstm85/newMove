plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.move"
    compileSdk = 35  // 31에서 33으로 업데이트
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.move"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // 릴리즈 빌드 설정 추가
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            // 디버그 서명 설정 유지
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // 리소스 패키징 옵션 추가
    packagingOptions {
        resources {
            excludes += listOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0"
            )
        }
    }

    // 린트 옵션 추가
    lint {
        disable += "InvalidPackage"
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Conscrypt 의존성 추가
    implementation("org.conscrypt:conscrypt-android:2.5.2")

    // Google Play Core 의존성 추가
    implementation("com.google.android.play:core:1.10.3")
}