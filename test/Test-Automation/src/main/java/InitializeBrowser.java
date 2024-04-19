package src.main.java;

import org.openqa.selenium.Capabilities;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
import test.java.Framework.AppVariables;

import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.concurrent.TimeUnit;

public class InitializeBrowser {

    private WebDriver driver;

    public WebDriver getRemoteDriver(String url) throws  MalformedURLException {

        ChromeOptions options = new ChromeOptions();
        if (AppVariables.headless) {
            options.addArguments("--headless", "--disable-gpu", "--window-size=1920,1200",
                    "--ignore-certificate-errors", "--disable-extensions", "--no-sandbox",
                    "--disable-dev-shm-usage");
            options.addArguments("--remote-allow-origins=*");
        } else {
            options.addArguments("--allow-running-insecure-content");
            options.addArguments("--ignore-certificate-errors");
            options.addArguments("--remote-allow-origins=*");
        }
        DesiredCapabilities cap = new DesiredCapabilities();
        cap.setCapability(ChromeOptions.CAPABILITY, options);
        return new RemoteWebDriver(new URL(url), cap);
    }

    public WebDriver getDriver(String browser) {
        switch (browser.toUpperCase()) {
            case "CHROME":
                return initializeChrome();
            default:
                throw new IllegalArgumentException("Unsupported Browser: " + browser);
        }
    }

    public WebDriver initializeChrome() {
        System.out.println("Launching Chrome");

        // Set ChromeDriver system property
        driver = new ChromeDriver();
        // Configure ChromeOptions
        ChromeOptions options = new ChromeOptions();
        if (AppVariables.headless) {
            options.addArguments("--headless", "--disable-gpu", "--window-size=1920,1200",
                    "--ignore-certificate-errors", "--disable-extensions", "--no-sandbox",
                    "--disable-dev-shm-usage");
            options.addArguments("--remote-allow-origins=*");
        } else {
            options.addArguments("--allow-running-insecure-content");
            options.addArguments("--ignore-certificate-errors");
            options.addArguments("--remote-allow-origins=*");
        }

        // Initialize ChromeDriver
        driver = new ChromeDriver(options);

        // Maximize window and set implicit wait
        driver.manage().window().maximize();
        driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);

        return driver;
    }

    public void navigateToURL(String url) {
        if (driver != null) {
            driver.get(url);
        }
    }

    public void quitBrowser() {
        if (driver != null) {
            driver.quit();
        }
    }
}
