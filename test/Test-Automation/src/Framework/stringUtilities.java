package Framework;

import org.testng.Assert;

public class stringUtilities {
	
	public String getRequestNumber(String fullText) {    //  12 is length for 3 digit request #	
		
		String requestNum = "";
		int len = fullText.length();
		
		if(len == 12) {
			requestNum = fullText.substring(len - 3);	//3 digit #
		} else if(len == 13) {
			requestNum = fullText.substring(len - 4);
		} else if(len == 14) {
			requestNum = fullText.substring(len - 5);
		} else {
			Assert.fail("String length outside boundaries");
		}
		
		System.out.println("getRequestNumber() returned: " + requestNum);
		return requestNum;
	} 		
	
	
}  //class