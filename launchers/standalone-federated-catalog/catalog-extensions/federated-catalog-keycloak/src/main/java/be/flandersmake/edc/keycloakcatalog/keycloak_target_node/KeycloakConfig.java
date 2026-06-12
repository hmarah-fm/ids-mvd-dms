package be.flandersmake.edc.keycloakcatalog.keycloak_target_node;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;

//class for reading keycloak
public class KeycloakConfig {

    private final String host;
    private final String token;
    private final String port;
    private final String realm;
    private final String attribute;
    private final boolean inferFromDID;
    private final String admin_user;
    private final String admin_password;

    public KeycloakConfig(Path configPath) {
        Properties props = new Properties();

        try (var input = Files.newInputStream(configPath)) {
            props.load(input);
        } catch (IOException e) {
            throw new RuntimeException("Failed to load Keycloak config", e);
        }

        this.admin_user = props.getProperty("admin_user");
        this.admin_password = props.getProperty("admin_password");
        this.token = props.getProperty("token");
        this.host = props.getProperty("host");
        this.port = props.getProperty("port");
        this.realm = props.getProperty("realm");
        this.attribute = props.getProperty("attribute");
        this.inferFromDID = Boolean.parseBoolean(props.getProperty("inferFromDID"));
    }

    public String host() { return host; }
    public String port() { return port; }
    public String token() { return token; }
    public String realm() { return realm; }
    public String attribute() { return attribute; }
    public boolean inferFromDID() { return inferFromDID; }
    public String admin_user() {return admin_user;}
    public String admin_password() {return admin_password;}

}
