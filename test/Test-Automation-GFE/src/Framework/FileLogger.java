package Framework;

import java.io.*;

public class FileLogger {
	public static void log(String filename, String message) {
		PrintWriter file;
		try {
			file = new PrintWriter(new FileWriter(filename, true), true);
			file.write(message);
			file.close();
			System.out.println("File closed");

		} catch (IOException e) {
			System.out.println("Error: " + e);
		}
	}

}
