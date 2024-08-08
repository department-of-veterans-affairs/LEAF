package main.java.util;

import org.testng.IRetryAnalyzer;
import org.testng.ITestResult;

/**
 * Retry analyzer to retry failed tests up to a specified number of times.
 */

public class RetryAnalyzerUtil implements IRetryAnalyzer {

    private int retryCount = 0;
    private static final int maxRetryCount = 3;

    @Override
    public boolean retry(ITestResult result) {
        if(!result.isSuccess()) {
            if (retryCount < maxRetryCount) {
                retryCount++;
                LoggerUtil.log("Retrying" + result.getName() + "again, attempt" + retryCount);
                return true;
            }
        }
        return false;
    }

}
