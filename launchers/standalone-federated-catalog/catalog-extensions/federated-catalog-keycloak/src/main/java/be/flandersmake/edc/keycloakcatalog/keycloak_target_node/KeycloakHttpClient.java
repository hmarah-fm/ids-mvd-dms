package be.flandersmake.edc.keycloakcatalog.keycloak_target_node;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;


import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import org.eclipse.edc.crawler.spi.TargetNode;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

//class for querying keycloack clients in the unimaass realm
public class KeycloakHttpClient {

    private HttpClient http_client;
    private final String host;
    private final String token;
    private final String port;
    private final String realm;
    private final Boolean inferFromDID;
    private final String attribute;
    private final String admin_user;
    private final String admin_password;

    private static final ObjectMapper mapper = new ObjectMapper();

    public KeycloakHttpClient(String config_path) {
        KeycloakConfig config = new KeycloakConfig(Path.of(config_path));
        this.admin_user = config.admin_user();
        this.admin_password = config.admin_password();
        this.host = config.host();
        this.port = config.port();
        this.realm = config.realm();
        this.attribute = config.attribute();
        this.inferFromDID=config.inferFromDID();
        this.http_client = HttpClient.newBuilder()
        .version(HttpClient.Version.HTTP_1_1)
        .build();
        this.token = InitializeToken(config.token()); 
    }

    public String InitializeToken(String token){
        if(token != null){
            return token;
        } else{
            HttpClient client = HttpClient.newHttpClient();

            String form = "client_id=admin-cli" +
              "&username=" + admin_user +
              "&password=" + admin_password +
              "&grant_type=password";

        HttpRequest tokenRequest = HttpRequest.newBuilder()
        .uri(URI.create("http://" + host + ":" + port + "/realms/master/protocol/openid-connect/token"))
        .header("Content-Type", "application/x-www-form-urlencoded")
        .POST(HttpRequest.BodyPublishers.ofString(form))
        .build();

        try {
            HttpResponse<String> response = client.send(tokenRequest, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
            throw new RuntimeException("Failed to get token. Status: " + response.statusCode() +
                    " Body: " + response.body());
        }

        JsonNode json = mapper.readTree(response.body());
        return json.get("access_token").asText();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (InterruptedException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
            return null;
        } 
    }

    public List<KeycloakParticipant> getParticipants() {
        List<KeycloakParticipant> participants = new ArrayList<>();
HttpRequest request = HttpRequest.newBuilder()
        .uri(URI.create(host + ":" + port + "/admin/realms/" + realm + "/clients"))
        .GET()
        .header("Accept", "application/json")
        .header("Authorization", "Bearer " + token) // you MUST include this
        .build();

HttpResponse<String> response;
try {
    response = http_client.send(request, HttpResponse.BodyHandlers.ofString());
    return parseParticipants(response.body());
} catch (IOException e) {
    // TODO Auto-generated catch block
    e.printStackTrace();
} catch (InterruptedException e) {
    // TODO Auto-generated catch block
    e.printStackTrace();
}
return participants;

    }

        public List<TargetNode> getParticipantsTargetNode() {
        List<TargetNode> participants = new ArrayList<>();
HttpRequest request = HttpRequest.newBuilder()
        .uri(URI.create("http://" + host + ":" + port + "/admin/realms/" + realm + "/clients"))
        .GET()
        .header("Accept", "application/json")
        .header("Authorization", "Bearer " + token) 
        .build();

HttpResponse<String> response;
try {
    response = http_client.send(request, HttpResponse.BodyHandlers.ofString());
    return parseParticipantsToTargetNode(response.body());
} catch (IOException e) {
    // TODO Auto-generated catch block
    e.printStackTrace();
} catch (InterruptedException e) {
    // TODO Auto-generated catch block
    e.printStackTrace();
}
return participants;

    }

    public List<TargetNode> parseParticipantsToTargetNode(String json){
        
        try {
        JsonNode root = mapper.readTree(json);

        System.out.println("Node type = " + root.getNodeType());
        System.out.println("Array size = " + root.size());
        List<TargetNode> participants = new ArrayList<>();

        for (JsonNode client : root) {
            
            if(!attribute.equals("clientId")){
            JsonNode attributes = client.get("attributes");

            if (attributes != null && attributes.has(attribute)) {
                String clientId = client.path("clientId").asText();
                String attribute_value = attributes.path(attribute).asText();

                participants.add(new KeycloakParticipant(clientId, attribute_value, inferFromDID).toTargetNode());
            }
            }else {
                String clientId = client.path("clientId").asText();
                if(!clientId.startsWith("did:web")){
                    continue; //skip this client
                }

                participants.add(new KeycloakParticipant(clientId, "", inferFromDID).toTargetNode());

            }
            
        }

        return participants;

    } catch (Exception e) {
        throw new RuntimeException("Failed to parse Keycloak client list", e);
    }
    }


    public List<KeycloakParticipant> parseParticipants(String json) {
    try {
        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(json);

        List<KeycloakParticipant> participants = new ArrayList<>();

        for (JsonNode client : root) {
            
            if(attribute != "clientId"){
            JsonNode attributes = client.get("attributes");

            if (attributes != null && attributes.has(attribute)) {
                String clientId = client.path("clientId").asText();
                String attribute_value = attributes.path(attribute).asText();

                participants.add(new KeycloakParticipant(clientId, attribute_value, inferFromDID));
            }
            }else {
                String clientId = client.path("clientId").asText();
                participants.add(new KeycloakParticipant(clientId, "", inferFromDID));

            }
            
        }

        return participants;

    } catch (Exception e) {
        throw new RuntimeException("Failed to parse Keycloak client list", e);
    }
}

    
}


