import java.io.File
import org.gradle.api.tasks.Delete

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = File(rootDir, "build")
buildDir = newBuildDir

subprojects {
    buildDir = File(newBuildDir, name)
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(buildDir)
}