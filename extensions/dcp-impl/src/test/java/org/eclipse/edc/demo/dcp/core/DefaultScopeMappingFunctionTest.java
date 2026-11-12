package org.eclipse.edc.demo.dcp.core;

import org.eclipse.edc.policy.context.request.spi.RequestCatalogPolicyContext;
import org.eclipse.edc.policy.context.request.spi.RequestContractNegotiationPolicyContext;
import org.eclipse.edc.policy.model.Policy;
import org.eclipse.edc.spi.iam.RequestContext;
import org.eclipse.edc.spi.iam.RequestScope;
import org.junit.jupiter.api.Test;

import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

class DefaultScopeMappingFunctionTest {
    private static final String MEMBERSHIP = "org.eclipse.edc.vc.type:MembershipCredential:read";
    private static final String DATA_PROCESSOR = "org.eclipse.edc.vc.type:DataProcessorCredential:read";

    @Test
    void catalogRequestsIncludeDataProcessorWhenEnabled() {
        var scopes = RequestScope.Builder.newInstance().scope("existing-scope");
        var context = new RequestCatalogPolicyContext(mock(RequestContext.class), scopes);
        var function = new DefaultScopeMappingFunction(Set.of(MEMBERSHIP), true);

        assertThat(function.apply(Policy.Builder.newInstance().build(), context)).isTrue();

        assertThat(scopes.build().getScopes()).containsExactlyInAnyOrder(MEMBERSHIP, DATA_PROCESSOR, "existing-scope");
    }

    @Test
    void catalogRequestsDoNotAddDataProcessorWhenDisabled() {
        var scopes = RequestScope.Builder.newInstance().scope("existing-scope");
        var context = new RequestCatalogPolicyContext(mock(RequestContext.class), scopes);
        var function = new DefaultScopeMappingFunction(Set.of(MEMBERSHIP), false);

        assertThat(function.apply(Policy.Builder.newInstance().build(), context)).isTrue();

        assertThat(scopes.build().getScopes()).containsExactlyInAnyOrder(MEMBERSHIP, "existing-scope");
    }

    @Test
    void defaultConstructorPreservesMembershipOnlyBehavior() {
        var scopes = RequestScope.Builder.newInstance();
        var context = new RequestCatalogPolicyContext(mock(RequestContext.class), scopes);
        var function = new DefaultScopeMappingFunction(Set.of(MEMBERSHIP));

        assertThat(function.apply(Policy.Builder.newInstance().build(), context)).isTrue();

        assertThat(scopes.build().getScopes()).containsExactly(MEMBERSHIP);
    }

    @Test
    void enabledCatalogFlagDoesNotChangeNegotiationScopes() {
        var scopes = RequestScope.Builder.newInstance().scope("existing-scope");
        var context = new RequestContractNegotiationPolicyContext(mock(RequestContext.class), scopes);
        var function = new DefaultScopeMappingFunction(Set.of(MEMBERSHIP), true);

        assertThat(function.apply(Policy.Builder.newInstance().build(), context)).isTrue();

        assertThat(scopes.build().getScopes()).containsExactlyInAnyOrder(MEMBERSHIP, "existing-scope");
    }
}
