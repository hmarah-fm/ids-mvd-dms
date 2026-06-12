package be.flandersmake.edc.keycloakcatalog.keycloak_target_node;

import java.util.List;

import org.eclipse.edc.crawler.spi.TargetNode;
import org.eclipse.edc.crawler.spi.TargetNodeDirectory;

public class KeycloakNodeDirectory implements TargetNodeDirectory{

    private final String config_path;

    public KeycloakNodeDirectory(String config_path){
        this.config_path = config_path;
    }

@Override
    public List<TargetNode> getAll() {
        KeycloakHttpClient httpClient = new KeycloakHttpClient(config_path);
        return httpClient.getParticipantsTargetNode();
    }

    @Override
    public void insert(TargetNode node) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Method unsupported for Keycloak based implementation");
    }

    @Override
    public TargetNode remove(String id) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Method unsupported to Keycloak based implementation");
    }

    

}