# Add project specific ProGuard rules here.

# Stripe - Keep all Stripe classes
-keep class com.stripe.android.** { *; }

# Ignore warnings for Stripe push provisioning (if you don't use it)
-dontwarn com.stripe.android.pushProvisioning.**

# React Native Stripe SDK
-keep class com.reactnativestripesdk.** { *; }

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Google Play Core (for deferred components - Flutter dynamic feature modules)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Apache Tika (XML processing)
-dontwarn javax.xml.stream.**
-dontwarn org.apache.tika.**

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep generic signature of Call, Response (Retrofit/OkHttp if used)
-keepattributes Signature
-keepattributes Exceptions