package main.java.util;

import java.util.Random;

public class CommonUtility {
    public static String generate_AlphaNumeric_RandomString(int length)
    {
        String CHAR_LOWER1 = "abcdefghijkl";
        String CHAR_LOWER2 = "mnopqrstuvwxyz";
        String CHAR_UPPER1 = CHAR_LOWER1.toUpperCase();
        String CHAR_UPPER2 = CHAR_LOWER2.toUpperCase();
        String NUMBER = "0123456789";
        String DATA_FOR_RANDOM_STRING = CHAR_LOWER1 + NUMBER + CHAR_UPPER2 + NUMBER + CHAR_LOWER2 + NUMBER + CHAR_UPPER1;

        Random random = new Random();
        if (length < 1) throw new IllegalArgumentException();
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++)
        {
            int rndCharAt = random.nextInt(DATA_FOR_RANDOM_STRING.length());
            char rndChar = DATA_FOR_RANDOM_STRING.charAt(rndCharAt);

            sb.append(rndChar);
        }
        return sb.toString();
    }// generate_AlphaNumeric_RandomString
}
