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
 *       Bayerische Motoren Werke Aktiengesellschaft (BMW AG) - initial API and implementation
 *
 */

package org.eclipse.edc.demo.dcp.core;

import org.eclipse.edc.policy.context.request.spi.RequestCatalogPolicyContext;
import org.eclipse.edc.policy.context.request.spi.RequestPolicyContext;
import org.eclipse.edc.policy.engine.spi.PolicyValidatorRule;
import org.eclipse.edc.policy.model.Policy;

import java.util.HashSet;
import java.util.Set;

public class DefaultScopeMappingFunction implements PolicyValidatorRule<RequestPolicyContext> {
    private final Set<String> defaultScopes;
    private final boolean enableDataProcessorForCatalog;

    public DefaultScopeMappingFunction(Set<String> defaultScopes) {
        this(defaultScopes, false);
    }

    public DefaultScopeMappingFunction(Set<String> defaultScopes, boolean enableDataProcessorForCatalog) {
        this.defaultScopes = defaultScopes;
        this.enableDataProcessorForCatalog = enableDataProcessorForCatalog;
    }

    @Override
    public Boolean apply(Policy policy, RequestPolicyContext requestPolicyContext) {
        var requestScopeBuilder = requestPolicyContext.requestScopeBuilder();
        var rq = requestScopeBuilder.build();
        var existingScope = rq.getScopes();
        var newScopes = new HashSet<>(defaultScopes);
        newScopes.addAll(existingScope);
        if (enableDataProcessorForCatalog && requestPolicyContext instanceof RequestCatalogPolicyContext) {
            newScopes.add("org.eclipse.edc.vc.type:DataProcessorCredential:read");
        }
        requestScopeBuilder.scopes(newScopes);
        return true;
    }
}
