package zArchive;

public class GuessingGame {
	public static void main(String args[]) throws java.io.IOException {

		
		//Random r = new Random();
		//char c = (char)(r.nextInt(26) + 'a');
		
		char ch, ignore, answer = 'k';

		do {
			System.out.print("\nEnter letter for guess. ");
			ch = (char) System.in.read();

			do { // get rid of the CRLF
				ignore = (char) System.in.read();
			} while (ignore != '\n');

			if (ch == answer)
				System.out.println("***CORRECT***");
			else {
				System.out.println("Nope.");
			}
		} while (answer != ch);

//		int iAns, answer = 59;
//		int x=0;
//		
//		for(x=5; x>=0; x--) {
//			System.out.print("\nEnter number for guess. ");
//			System.out.println("You have " + x + " guesses remaining:");
//			
//			iAns = (int) System.in.read();
//		
//			if(iAns==answer) {
//				System.out.println("***CORRECT***");
//				break;
//			}
//			else System.out.println("Nope");

	}
}