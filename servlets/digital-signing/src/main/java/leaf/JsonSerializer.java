package leaf;

import io.vertx.core.logging.Logger;
import io.vertx.core.logging.LoggerFactory;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import java.util.Map;

public class JsonSerializer {

    private static Logger logger = LoggerFactory.getLogger(JsonSerializer.class);


    public static String serialize(String key, String message, String status) {
         return "{\"key\":\"" + key + "\",\"message\":\"" + message + "\",\"status\":\"" + status + "\"}";
    }

    public static Sign deserialize(String json) {

        ScriptEngine scriptEngine = new ScriptEngineManager().getEngineByName("javascript");

        String script = "Java.asJSONCompatible(" + json + ")";
        Map result = null;
        try {
            result = (Map) scriptEngine.eval(script);
        } catch (ScriptException e) {
            e.printStackTrace();
        }
        Map kvs = (Map) result;
        return new Sign((String) kvs.get("key"), (String) kvs.get("dataToSign"));
    }

}
