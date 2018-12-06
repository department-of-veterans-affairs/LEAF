package leaf;

public class JsonSerializer {

    public static String serialize(String key, String message, String status) {
         return "{\"key\":\"" + key + "\",\"message\":\"" + message + "\",\"status\":\"" + status + "\"}";
    }

    public static Sign deserialize(String json) {

        String strip = json.trim().substring(1, json.length() - 1).replace("\"", "");
        String[] kvs = strip.split(",");
        String key = "No key found", dataToSign = "No data to sign found";
        for (String kv : kvs) {
            String[] pair = kv.split(":");
            if (pair[0].equals("key")) key = pair[1];
            else if (pair[0].equals("dataToSign")) dataToSign = pair[1];
        }
        return new Sign(key, dataToSign);
    }

}
