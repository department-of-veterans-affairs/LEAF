package leaf;

import io.vertx.core.logging.Logger;
import io.vertx.core.logging.LoggerFactory;

public class JsonSerializer {

    private static Logger logger = LoggerFactory.getLogger(JsonSerializer.class);

    public static String serialize(String key, String message, String status, String publicKey) {
         return "{\"key\":\"" + key
                 + "\",\"message\":\"" + message
                 + "\",\"status\":\"" + status
                 + "\",\"publicKey\":\"" + publicKey + "\"}";
    }

    public static Sign deserialize(String json) {
        String key = json.substring(json.indexOf(":") + 2, json.indexOf(",") - 1).trim();
        logger.info("key: " + key);
        String dataToSign = json.substring(json.lastIndexOf("{"), json.length() - 2).trim();
        logger.info("dataToSign: " + dataToSign);
        return new Sign(key, dataToSign);
    }

}
