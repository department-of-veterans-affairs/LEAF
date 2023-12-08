package LEAF.MavenJava_CICD;
	
import java.io.File;
import java.io.FileWriter;

public class vbsMsgBox {

	private vbsMsgBox() {  }

	  public static boolean isServiceRunning(String serviceName) {
	    try {
	       File file = File.createTempFile("vbsTempFile",".vbs");		// was:  realhowto.vbs
	       file.deleteOnExit();
	       FileWriter fw = new java.io.FileWriter(file);

	       String vbs = "Set sh = CreateObject(\"Shell.Application\") \n"
	                  + "If sh.IsServiceRunning(\""+ serviceName +"\") Then \n"
	                  + "   wscript.Quit(1) \n"
	                  + "End If \n"
	                  + "wscript.Quit(0) \n";
	       fw.write(vbs);
	       fw.close();
	       Process p = Runtime.getRuntime().exec("wscript " + file.getPath());
	       p.waitFor();
	       return (p.exitValue() == 1);
	    } catch(Exception e){
	        e.printStackTrace();
	    }
	    return false;
	  }


	  public static void main(String[] args){
	    //
	    // DEMO
	    //
	    String result = "";
	    msgBox("Check if service 'Themes' is running (should be yes)");
	    result = isServiceRunning("Themes") ? "" : " NOT ";
	    msgBox("service 'Themes' is " + result + " running ");

	    msgBox("Check if service 'foo' is running (should be no)");
	    result = isServiceRunning("foo") ? "" : " NOT ";
	    msgBox("service 'foo' is " + result + " running ");
	  }

	  public static void msgBox(String msg) {
	    javax.swing.JOptionPane.showConfirmDialog((java.awt.Component)
	       null, msg, "VBSUtils", javax.swing.JOptionPane.DEFAULT_OPTION);
	  }





}    //Class
