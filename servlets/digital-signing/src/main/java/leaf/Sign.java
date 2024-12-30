package leaf;

public class Sign {

    private String key;
    private String message;
    private String status;
    private String dataToSign;

    public Sign() {}

    // Received from browser
    public Sign(String key, String dataToSign) {
        this.key = key;
        this.dataToSign = dataToSign;
    }

    // Sent to browser
    public Sign(String key, String message, String status) {
        this.key = key;
        this.message = message;
        this.status = status;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getDataToSign() {
        return dataToSign;
    }

    public void setDataToSign(String dataToSign) {
        this.dataToSign = dataToSign;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

}
