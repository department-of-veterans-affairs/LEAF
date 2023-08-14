package Framework;

import java.io.File;
import java.io.IOException;

public class vbsExecutor2 {

	    public static void main(String[] args) throws IOException {
	        try {
	            System.out.println(new File("a.vbs").getAbsolutePath());
	            Runtime.getRuntime().exec("wscript.exe " + new File("samplevbs.vbs").getAbsolutePath());

	        } catch (IOException ex) {

	        }
	    }
	
}  //class
