package be.flandersmake.edc.keycloakcatalog.keycloak_target_node;

import java.io.IOException;
import java.lang.annotation.Target;
import java.net.URI;
import java.net.URLDecoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.List;

import org.eclipse.edc.crawler.spi.TargetNode;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public class KeycloakParticipant {

    String clientId;
    String attribute;
    Boolean inferFromDID;
    private static final ObjectMapper MAPPER = new ObjectMapper();

    public KeycloakParticipant(String clientId, String attribute, Boolean inferFromDID){
        this.clientId = clientId;
        this.attribute = attribute;
        this.inferFromDID = inferFromDID;
    }

public TargetNode toTargetNode() {
    String id;
    String url;
    String name;

    if (inferFromDID && clientId.startsWith("did:web:")) {
        // Example DID: did:web:localhost%3A9876:connector1
        String withoutPrefix = clientId.substring("did:web:".length());
        String[] parts = withoutPrefix.split(":");

        //encoded host:port
        String encodedHostPort = parts[0];
        String did_url = java.net.URLDecoder.decode(encodedHostPort, java.nio.charset.StandardCharsets.UTF_8);

        // participant name
        name = parts[parts.length - 1];
        id = name;

        return resolveFromDidWeb(did_url, name);

    }else {
        // Fallback: use Keycloak attributes in case the catalog url gets saved as an attribute
        id = clientId;
        name = clientId;
        url = attribute;
        List<String> supportedProtocols = List.of("dataspace-protocol-http");//default protocol

        //System.err.println("Target node from keycloak:" + id + " name:" + name + " url:" + url);

        return new TargetNode(id, name, url, supportedProtocols);
    }

}

    public static TargetNode resolveFromDidWeb(String didWebUrl, String connectorName) {
        try {
            String didJsonUrl = "http://" + didWebUrl + "/.well-known/did.json";
            System.out.println("Get did url:" + didJsonUrl);

            // Fetch DID document
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(didJsonUrl))
                    .GET()
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            JsonNode didDoc = MAPPER.readTree(response.body());
            String rawDid = didDoc.get("id").asText(); // "did:web:localhost%3A7093"
            String decodedDid = URLDecoder.decode(rawDid, StandardCharsets.UTF_8); 

            // Extract DSP service endpoint
            JsonNode services = didDoc.get("service");
            if (services == null || !services.isArray()) {
                throw new IllegalStateException("No service entries found in DID document.");
            }

            String dspEndpoint = null;
            for (JsonNode svc : services) {
                if (svc.has("type") && 
                    (svc.get("type").asText().equalsIgnoreCase("ProtocolEndpoint") || svc.get("type").asText().equalsIgnoreCase("DataspaceProtocol"))) {
                    dspEndpoint = svc.get("serviceEndpoint").asText();
                    break;
                }
            }

            if (dspEndpoint == null) {
                throw new IllegalStateException("No DataspaceProtocol service endpoint found in DID document.");
            }

            // Build catalog endpoint
            String catalogUrl = dspEndpoint;/* .endsWith("/")
                    ? dspEndpoint + "catalog"
                    : dspEndpoint + "/catalog";*/

            // Build TargetNode
           System.err.println("Target node from did:" + rawDid + " name:" + connectorName + " url:" + catalogUrl);
            TargetNode target =  new TargetNode(connectorName, rawDid, catalogUrl, List.of("dataspace-protocol-http"));

            System.err.println("TargetNode ID = " + target.id());
            return target;
        } catch (IOException | InterruptedException e) {
            throw new RuntimeException("Failed to resolve DID document: " + e.getMessage(), e);
        }
    }

}
