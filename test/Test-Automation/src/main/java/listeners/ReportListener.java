package main.java.listeners;

import org.testng.ITestContext;
import org.testng.ITestListener;
import org.testng.ITestResult;

import com.relevantcodes.extentreports.LogStatus;

import main.java.report.ExtentReportManager;
import main.java.util.ReportUtil;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * The listener interface for receiving report events. The class that is
 * interested in processing a report event implements this interface, and the
 * object created with that class is registered with a component using the
 * component's <code>addReportListener<code> method. When the report event
 * occurs, that object's appropriate method is invoked.
 *
 * @see ReportEvent
 */
public class ReportListener implements ITestListener {

	/**
	 * Gets the test name.
	 *
	 * @param result the result
	 * @return the test name
	 */
	public String getTestName(ITestResult result) {
		return result.getTestName() != null ? result.getTestName()
				: result.getMethod().getConstructorOrMethod().getName();
	}

	/**
	 * Gets the test description.
	 *
	 * @param result the result
	 * @return the test description
	 */
	public String getTestDescription(ITestResult result) {
		return result.getMethod().getDescription() != null ? result.getMethod().getDescription() : getTestName(result);
	}

	/**
	 * Gets the current timestamp.
	 *
	 * @return the current timestamp
	 */
	private String getCurrentTimeStamp() {
		return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
	}

	@Override
	public void onTestStart(ITestResult result) {
		ExtentReportManager.startTest(getTestName(result), getTestDescription(result));
		ExtentReportManager.getCurrentTest().log(LogStatus.INFO, "Test started at: " + getCurrentTimeStamp());
	}

	@Override
	public void onTestSuccess(ITestResult result) {
		ExtentReportManager.getCurrentTest().log(LogStatus.PASS, "Test passed at: " + getCurrentTimeStamp());
		ReportUtil.addScreenShot(LogStatus.PASS, "Test Passed");
	}

	@Override
	public void onTestFailure(ITestResult result) {
		Throwable t = result.getThrowable();
		String cause = t != null ? t.getMessage() : "Unknown cause";
		ExtentReportManager.getCurrentTest().log(LogStatus.FAIL, "Test failed at: " + getCurrentTimeStamp());
		ExtentReportManager.getCurrentTest().log(LogStatus.FAIL, "Cause: " + cause);
		ReportUtil.addScreenShot(LogStatus.FAIL, "Test Failed: " + cause);
	}

	@Override
	public void onTestSkipped(ITestResult result) {
		ExtentReportManager.getCurrentTest().log(LogStatus.SKIP, "Test skipped at: " + getCurrentTimeStamp());
	}

	@Override
	public void onTestFailedButWithinSuccessPercentage(ITestResult result) {
	}

	@Override
	public void onStart(ITestContext context) {
	}

	@Override
	public void onFinish(ITestContext context) {
		ExtentReportManager.endCurrentTest();
		ExtentReportManager.getExtentReports().flush();
	}
}
