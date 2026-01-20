// android/build.gradle.kts
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins { 
    id("com.google.gms.google-services") version "4.4.4" apply false
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    afterEvaluate {
        // Only configure if it's an Android project (app or library plugins)
        if (project.plugins.hasPlugin("com.android.application") ||
            project.plugins.hasPlugin("com.android.library")) {

            // Access the android extension safely
            project.extensions.findByName("android")?.let { androidExt ->
                @Suppress("UNCHECKED_CAST")
                val android = androidExt as? com.android.build.gradle.BaseExtension
                android?.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_21
                    targetCompatibility = JavaVersion.VERSION_21
                }
            }

            // For Kotlin projects/plugins: configure compile tasks using the new compilerOptions DSL
            project.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
                }
            }
        }
    }
}

// Optional: Clean task override (yours is fine, keep if needed)
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}