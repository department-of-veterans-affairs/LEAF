package leaf;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Hashtable;
import java.util.Properties;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class ResourceManager {

    private static Hashtable<String, String> fileCache = new Hashtable<>();
    private static ClassLoader loader = Thread.currentThread().getContextClassLoader();
    private static Properties properties;

    public static Properties getProperties() {
        if (properties == null) {
            properties = new Properties();
            String resourceFile = "config.properties";
            InputStream resourceStream = loader.getResourceAsStream(resourceFile);
            try {
                properties.load(resourceStream);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return properties;
    }

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

    public static String extractZip(String jarFilePath) {
        if (jarFilePath == null) {
            return null;
        }
        if (fileCache.contains(jarFilePath)) {
            return fileCache.get(jarFilePath);
        }
        try {
            InputStream fileInputStream = ResourceManager.class.getClassLoader().getResourceAsStream(jarFilePath);
            ZipInputStream zipInputStream = new ZipInputStream(fileInputStream);
            ZipEntry zipEntry = zipInputStream.getNextEntry();
            String fileName = zipEntry.getName();
            String[] chopped = fileName.split("\\/");
            fileName = chopped[chopped.length-1];
            File tempFile = File.createTempFile("temp_", fileName);
            FileOutputStream fileOutputStream = new FileOutputStream(tempFile);
            byte[] buffer = new byte[1024];
            int len;
            while ((len = zipInputStream.read(buffer)) > 0) {
                fileOutputStream.write(buffer, 0, len);
            }
            fileCache.put(jarFilePath, tempFile.getAbsolutePath());
            fileInputStream.close();
            fileOutputStream.close();
            return tempFile.getAbsolutePath();
        } catch (IOException e) {
            return null;
        }
    }

}
