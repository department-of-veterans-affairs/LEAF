package zArchive;

public class arrays {

	public static void main(String[] args) {
		int[] aryTypeI = {6,7,8,9,-55,16,7,72,81};			//Not used
		int[] ary = new int[10];
		int min, max;
		
		
		ary[0] = 6;
		ary[1] = 7;
		ary[2] = 8;
		ary[3] = 9;
		ary[4] = -55;
		ary[5] = 16;
		ary[6] = 7;
		ary[7] = 72;
		ary[8] = 81;
		
		min = max = ary[0];

		for (int i = 0; i < ary.length; i++) {
			if (ary[i] < min)
				min = ary[i];
			if (ary[i] > max)
				max = ary[i];
		}

		System.out.println("Min: " + min + "\n" + "Max: " + max + "\n------\n" + "nums.length = " + ary.length + "\n");
	}

}
