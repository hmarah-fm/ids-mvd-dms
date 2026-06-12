plugins {
    `java-library`
    id("application")
    alias(libs.plugins.shadow)
}

dependencies {
    implementation("org.eclipse.edc:federatedcatalog-base-bom:0.14.1")
    implementation("org.eclipse.edc:crawler-spi:0.14.1")
    implementation("org.eclipse.edc:runtime-core:0.14.1")
    implementation("org.eclipse.edc:connector-core:0.14.1")
    implementation("org.eclipse.edc:jersey-core:0.14.1")
    runtimeOnly("org.eclipse.edc:boot:0.14.1")
    runtimeOnly("org.eclipse.edc:control-plane-core:0.14.1")
   // implementation("org.eclipse.edc:configuration-filesystem:0.14.1")
    runtimeOnly("org.eclipse.edc:token-core:0.14.1")
    implementation("org.eclipse.edc:http:0.14.1")
    runtimeOnly("org.eclipse.edc:dsp:0.14.1")
    implementation("org.eclipse.edc:iam-mock:0.14.1")
    implementation("org.eclipse.edc:control-plane-aggregate-services:0.14.1")
    implementation(project(":launchers:standalone-federated-catalog:catalog-extensions:federated-catalog-keycloak"))
    implementation(project(":extensions:dcp-impl"))
    implementation("org.eclipse.edc:federated-catalog-core:0.14.1")
    implementation("org.eclipse.edc:federated-catalog-api:0.14.1")
    runtimeOnly(libs.edc.api.management)
    runtimeOnly(libs.edc.api.management.config)
    runtimeOnly(libs.edc.dsp) // protocol webhook
    runtimeOnly(libs.bundles.dcp) // DCP protocol impl
    runtimeOnly(libs.edc.api.dsp.config) // json-ld expansion
    implementation("org.eclipse.edc:catalog-api:0.14.1")
    implementation("org.eclipse.edc:secrets-api:0.14.1")


    //my extensions
    //implementation(project(":extensions:federated-catalog-keycloak"))

    if (project.properties.getOrDefault("persistence", "false") == "true") {
        runtimeOnly(libs.edc.vault.hashicorp)
        runtimeOnly(libs.bundles.sql.edc)
        runtimeOnly(libs.edc.sts.remote.client)
        println("This runtime compiles with a remote STS client, Hashicorp Vault and PostgreSQL. You will need properly configured Postgres and HCV instances.")
    }
}

application {
    mainClass.set("org.eclipse.edc.boot.system.runtime.BaseRuntime")
}

var distTar = tasks.getByName("distTar")
var distZip = tasks.getByName("distZip")

tasks.withType<com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar> {
    mergeServiceFiles()
    archiveFileName.set("standalone-catalog.jar")
    dependsOn(distTar, distZip)
    duplicatesStrategy = DuplicatesStrategy.INCLUDE
}

edcBuild {
    publish.set(false)
}

