package main.Utility;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.openqa.selenium.WebDriver;

public class BrowserHelper {
    static final Logger logger = LogManager.getLogger(BrowserHelper.class);

    public static void navigate(String url, WebDriver driver) {
        driver.navigate().to(url);
        String infoMsg = "navigate: " + url;
        logger.info(infoMsg);
  //      reporter.deepReportStep(StepStatus.INFO, infoMsg);
    //    KronosLogger.traceLeave();
    }

    public static void navigateBack(WebDriver driver) {
        KronosLogger.traceEnter();
        driver.navigate().back();
        String infoMsg = "navigateBack: " + driver.getCurrentUrl();
        logger.info(infoMsg);
        reporter.deepReportStep(StepStatus.INFO, infoMsg);
        KronosLogger.traceLeave();
    }

    public static void navigateForward(WebDriver driver) {
        KronosLogger.traceEnter();
        driver.navigate().forward();
        String infoMsg = "navigateForward: " + driver.getCurrentUrl();
        logger.info(infoMsg);
        reporter.deepReportStep(StepStatus.INFO, infoMsg);
        KronosLogger.traceLeave();
    }

    public static void refreshPage(WebDriver driver) {
        KronosLogger.traceEnter();
        driver.navigate().refresh();
        String infoMsg = "refreshPage: " + driver.getCurrentUrl();
        logger.info(infoMsg);
        reporter.deepReportStep(StepStatus.INFO, infoMsg);
        KronosLogger.traceLeave();
    }

    public static String getCookieValueByName(WebDriver driver, String cookieName) {
        KronosLogger.traceEnter();
        String cookieValue = null;
        cookieValue = driver.manage().getCookieNamed(cookieName).getValue();
        String infoMsg = "getCookieValueByName: " + cookieName;
        logger.info(infoMsg);
        KronosLogger.traceLeave();
        return cookieValue;
    }

    public static String getCurrentWindowHandle(WebDriver driver) {
        String winHandle = driver.getWindowHandle();
        logger.info("getCurrentWindowHandle: [" + winHandle + "]");
        return winHandle;
    }

    public static String openWindow(WebDriver driver) throws KronosCoreUIException {
        String infoMsg = "Open Window ";
        Set<String> beforeWinHandles = driver.getWindowHandles();
        ((JavascriptExecutor)driver).executeScript("window.open();", new Object[0]);
        Set<String> afterWinHandles = driver.getWindowHandles();
        afterWinHandles.removeAll(beforeWinHandles);
        logger.info(infoMsg);
        return afterWinHandles.isEmpty() ? null : (String)afterWinHandles.toArray()[0];
    }

    public static void switchAndCloseWindow(WebDriver driver, String windowHandle) throws KronosCoreUIException {
        KronosLogger.traceEnter();
        String infoMsg = "switchAndCloseWindow: ";
        if (!driver.getWindowHandles().contains(windowHandle)) {
            infoMsg = infoMsg + "Cannot find the window [" + windowHandle + "] which you are trying to close.";
            logger.error(infoMsg);
            reporter.deepReportStep(StepStatus.FAIL, infoMsg);
            throw new KronosCoreUIException(infoMsg);
        } else {
            switchToWindow(driver, windowHandle);
            driver.close();
            logger.info(infoMsg);
            KronosLogger.traceLeave();
        }
    }

    public static void closeWindow(WebDriver driver, String windowHandle) throws KronosCoreUIException {
        String infoMsg = "Close Window: ";
        if (driver.getWindowHandles().contains(windowHandle)) {
            try {
                driver.close();
            } catch (Exception var4) {
                logger.error(infoMsg, var4);
                reporter.deepReportStep(StepStatus.FAIL, infoMsg);
                throw new KronosCoreUIException(infoMsg, var4);
            }
        } else {
            infoMsg = infoMsg + "Cannot find the window [" + windowHandle + "] which you are trying to close.";
            logger.error(infoMsg);
            reporter.deepReportStep(StepStatus.FAIL, infoMsg);
            throw new KronosCoreUIException(infoMsg);
        }
    }

    public static void switchToWindow(WebDriver driver, String windowHandle) throws KronosCoreUIException {
        String infoMsg = "switchToWindow: ";
        if (driver.getWindowHandles().contains(windowHandle)) {
            try {
                driver.switchTo().window(windowHandle);
            } catch (Exception var4) {
                logger.error(infoMsg, var4);
                reporter.deepReportStep(StepStatus.FAIL, infoMsg);
                throw new KronosCoreUIException(infoMsg, var4);
            }
        } else {
            infoMsg = infoMsg + "Cannot find the window [" + windowHandle + "] which you are trying to switch to";
            logger.error(infoMsg);
            reporter.deepReportStep(StepStatus.FAIL, infoMsg);
            throw new KronosCoreUIException(infoMsg);
        }
    }

    public static Alert getAlert(WebDriver driver) throws KronosCoreUIException {
        KronosLogger.traceEnter();
        String infoMsg = "getAlert: ";

        try {
            Alert alert = driver.switchTo().alert();
            logger.info(infoMsg);
            KronosLogger.traceLeave();
            return alert;
        } catch (Exception var3) {
            reporter.deepReportStep(StepStatus.FAIL, infoMsg, BasicPageSyncHelper.saveAsScreenShot(driver), var3);
            logger.error(infoMsg, var3);
            throw new KronosCoreUIException(infoMsg, var3);
        }
    }

    public static void acceptAlert(WebDriver driver) throws KronosCoreUIException {
        KronosLogger.traceEnter();
        String infoMsg = "getAlert: ";

        try {
            Alert alert = getAlert(driver);
            alert.accept();
            logger.info(infoMsg);
        } catch (Exception var3) {
            logger.error(infoMsg, var3);
            reporter.deepReportStep(StepStatus.FAIL, infoMsg, BasicPageSyncHelper.saveAsScreenShot(driver), var3);
            throw new KronosCoreUIException(infoMsg, var3);
        }

        KronosLogger.traceLeave();
    }

    public static void dismissAlert(WebDriver driver) throws KronosCoreUIException {
        KronosLogger.traceEnter();
        String infoMsg = "dismissAlert:";

        try {
            Alert alert = getAlert(driver);
            alert.dismiss();
            logger.info(infoMsg);
        } catch (Exception var3) {
            logger.error(infoMsg, var3);
            reporter.deepReportStep(StepStatus.FAIL, infoMsg, BasicPageSyncHelper.saveAsScreenShot(driver), var3);
            throw new KronosCoreUIException(infoMsg, var3);
        }

        KronosLogger.traceLeave();
    }

    public static String getAlertText(WebDriver driver) throws KronosCoreUIException {
        KronosLogger.traceEnter();
        String alertText = null;
        String infoMsg = "getAlertText: %s";

        try {
            Alert alert = getAlert(driver);
            alertText = alert.getText();
            infoMsg = String.format(infoMsg, alertText);
            logger.info(infoMsg);
        } catch (Exception var4) {
            infoMsg = String.format(infoMsg, alertText);
            logger.error(infoMsg, var4);
            reporter.deepReportStep(StepStatus.FAIL, infoMsg, BasicPageSyncHelper.saveAsScreenShot(driver), var4);
            throw new KronosCoreUIException(infoMsg, var4);
        }

        KronosLogger.traceLeave();
        return alertText;
    }

    public static String getTitle(WebDriver driver) {
        String title = null;
        KronosLogger.traceEnter();
        title = driver.getTitle();
        String infoMsg = "getTitle: " + title;
        logger.info(infoMsg);
        KronosLogger.traceLeave();
        return title;
    }

    public static String getPageUrl(WebDriver driver) {
        String title = null;
        KronosLogger.traceEnter();
        title = driver.getCurrentUrl();
        String infoMsg = "getPageUrl: " + title;
        logger.info(infoMsg);
        KronosLogger.traceLeave();
        return title;
    }

    public static void maximizeBrowser(WebDriver driver) {
        KronosLogger.traceEnter();
        if (!System.getProperty("os.name").contains("Mac")) {
            driver.manage().window().maximize();
        } else {
            Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
            int width = (int)(screenSize.getWidth() * 0.97);
            org.openqa.selenium.Dimension dimension = new org.openqa.selenium.Dimension(width, (int)screenSize.getHeight());
            driver.manage().window().setSize(dimension);
        }

        String infoMsg = "maximizeBrowser";
        logger.info(infoMsg);
        KronosLogger.traceLeave();
    }

}
