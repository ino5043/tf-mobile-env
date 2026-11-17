import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 配布用（release）の署名の鍵。
// - CI: GitHub の秘密の値から、環境変数 EDUCARDS_* で渡す（.github/workflows/educards-release-android.yml）
// - 手元: android/key.properties（.gitignore 済み。リポジトリに入れない）
// 鍵が無いとき、CI ではビルドを止める。手元では試しのために debug の鍵で署名する。
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

fun signingValue(env: String, property: String): String? =
    System.getenv(env)?.takeIf { it.isNotBlank() } ?: keystoreProperties.getProperty(property)

val releaseStoreFile = signingValue("EDUCARDS_KEYSTORE_PATH", "storeFile")
val isCi = System.getenv("CI") == "true"

android {
    namespace = "com.techfusion.educards"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications が Java 8 以降の API を古い端末でも使うために必要
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // 一度配ったら変えない。変えると別のアプリ扱いになり、上書きで更新できなくなる。
        applicationId = "com.techfusion.educards"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (releaseStoreFile != null) {
                storeFile = file(releaseStoreFile)
                storePassword = signingValue("EDUCARDS_KEYSTORE_PASSWORD", "storePassword")
                keyAlias = signingValue("EDUCARDS_KEY_ALIAS", "keyAlias")
                keyPassword = signingValue("EDUCARDS_KEY_PASSWORD", "keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = when {
                releaseStoreFile != null -> signingConfigs.getByName("release")
                isCi -> throw GradleException(
                    "Release signing key is missing. Set the EDUCARDS_* secrets.",
                )
                else -> signingConfigs.getByName("debug")
            }
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
