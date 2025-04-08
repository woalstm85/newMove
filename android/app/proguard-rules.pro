# Flutter 관련 규칙
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# OkHttp 관련 규칙
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
-dontwarn org.openssl.**

# Flutter Naver Login 관련 규칙
-keep class com.nhn.android.naverlogin.** { *; }
-keep class com.navercorp.nid.** { *; }
-keep class com.yoonjaepark.flutter_naver_login.** { *; }

# Google Play Core 관련 규칙
-keep class com.google.android.play.core.** { *; }