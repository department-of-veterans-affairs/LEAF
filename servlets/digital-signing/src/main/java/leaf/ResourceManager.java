package leaf;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Hashtable;

class ResourceManager {

    private static Hashtable<String, String> fileCache = new Hashtable<>();

    static String extract(String jarFilePath){

        if (jarFilePath == null) {
            return null;
        }

        if (fileCache.contains(jarFilePath)) {
            return fileCache.get(jarFilePath);
        }

        try {
            InputStream fileStream = ResourceManager.class.getClassLoader().getResourceAsStream(jarFilePath);
            if (fileStream == null) {
                return null;
            }
            String[] chopped = jarFilePath.split("\\/");
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
            fileCache.put(jarFilePath, tempFile.getAbsolutePath());
            fileStream.close();
            out.close();
            return tempFile.getAbsolutePath();
        } catch (IOException e) {
            return null;
        }
    }
}
