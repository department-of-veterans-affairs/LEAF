package test.java.Framework;

import java.text.SimpleDateFormat;
import java.util.Date;

public class dateAndTimeMethods {

	
	public static String getDate() {
	      String pattern = "MM/dd HH:mm";
	      SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);

	      String date = simpleDateFormat.format(new Date());
	      System.out.println(date);
	      
	      return date;
	}
	
	
	
	
}  //class
