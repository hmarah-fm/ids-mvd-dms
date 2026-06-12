/*
*  Copyright (c) 2023 Bayerische Motoren Werke Aktiengesellschaft (BMW AG)
*
*  This program and the accompanying materials are made available under the
*  terms of the Apache License, Version 2.0 which is available at
*  https://www.apache.org/licenses/LICENSE-2.0
*
*  SPDX-License-Identifier: Apache-2.0
*
*  Contributors:
*       Bayerische Motoren Werke Aktiengesellschaft (BMW AG) - Initial API and Implementation
*
*/

plugins {
    `java-library`
    id("application")
    alias(libs.plugins.shadow)
}

dependencies {
    runtimeOnly(project(":launchers:controlplane")) {
        // this will remove the RemoteDataPlaneSelectorService
        exclude(group = "org.eclipse.edc", "data-plane-selector-client")
    }
    runtimeOnly(project(":launchers:dataplane")) {
        // this will remove the RemoteDataPlaneSelectorService
        exclude(group = "org.eclipse.edc", "data-plane-selector-client")
    }

    // RDF extensions here
    //runtimeOnly(project(":extensions:digital-thread"))
   // runtimeOnly(project(":extensions:edc-rdf:data-plane-rdf-spi"))
   // runtimeOnly(project(":extensions:edc-rdf:control-plane-rdf"))
}

tasks.withType<com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar> {
    exclude("**/pom.properties", "**/pom.xml")
    mergeServiceFiles()
    archiveFileName.set("${project.name}.jar")
}

application {
    mainClass.set("org.eclipse.edc.boot.system.runtime.BaseRuntime")
}

edcBuild {
    publish.set(false)
}