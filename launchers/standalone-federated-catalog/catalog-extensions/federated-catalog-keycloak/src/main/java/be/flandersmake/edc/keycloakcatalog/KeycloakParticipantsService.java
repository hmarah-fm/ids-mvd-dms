package be.flandersmake.edc.keycloakcatalog;

import org.eclipse.edc.crawler.spi.TargetNodeDirectory;
import org.eclipse.edc.runtime.metamodel.annotation.Inject;
import org.eclipse.edc.spi.monitor.Monitor;
import org.eclipse.edc.spi.system.ServiceExtension;
import org.eclipse.edc.spi.system.ServiceExtensionContext;

import be.flandersmake.edc.keycloakcatalog.keycloak_target_node.KeycloakNodeDirectory;

public class KeycloakParticipantsService implements ServiceExtension {

    @Inject
    private Monitor monitor;

    @Override
    public String name() {
        return "Keycloak Target Node Directory Extension";
    }

    private final String config_path = System.getenv("KEYCLOAK_CONFIG_PATH");

    @Override
    public void initialize(ServiceExtensionContext context) {
        monitor.info("Initializing Keycloak TargetNodeDirectory");

        // Load your config
        var configPath = config_path;
        System.out.print(configPath);
        //TODO: change the path according to federated catalog config: 
        // context.getConfig().getString("edc.keycloak.directory.config");

        // Create your directory
        var directory = new KeycloakNodeDirectory(configPath);

        // Register it as a service so the Federated Catalog can find it
        context.registerService(TargetNodeDirectory.class, directory);

        monitor.info("Keycloak TargetNodeDirectory registered");
    }
}
