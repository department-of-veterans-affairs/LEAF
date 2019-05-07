package leaf;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Hashtable;

public class ResourceManager {

    private static Hashtable<String, String> fileCache = new Hashtable<>();

    public static File extractResource(String file) {
        try {
            InputStream fileStream = ResourceManager.class.getClassLoader().getResourceAsStream(file);
            if (fileStream == null) {
                return null;
            }
            String[] chopped = file.split("\\/");
            String fileName = chopped[chopped.length-1];
            File tempFile = File.createTempFile("temp_", fileName);
            tempFile.deleteOnExit();
            OutputStream out = new FileOutputStream(tempFile);
            byte[] buffer = new byte[1024];
            int len = fileStream.read(buffer);
            while (len != -1) {
                out.write(buffer, 0, len);
                len = fileStream.read(buffer);
            }
            fileCache.put(file, tempFile.getAbsolutePath());
            fileStream.close();
            out.close();
            return tempFile;
        } catch (IOException e) {
            return null;
        }
    }

}
