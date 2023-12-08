package LEAF.MavenJava_CICD;

import java.io.IOException;

public class vbsExecutor {

	public static void executeVBS(String filePath, String fileName) {
		
		//String script = System.getProperty("user.dir") + "\\DelTempFiles.vbs" ;
		String script = filePath + fileName;
		try {
			Runtime.getRuntime().exec ( "wscript " + script);
		} catch (IOException e) {
			e.printStackTrace();
			System.out.println("VB Script Failed to execute");
		}	
	}
	
	
	
}  //class
