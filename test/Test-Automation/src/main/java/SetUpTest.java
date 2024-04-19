// SetUpTest.java
package src.main.java;

import org.openqa.selenium.WebDriver;
import org.testng.annotations.*;
import src.main.java.InitializeBrowser;

import java.net.MalformedURLException;

public class SetUpTest {
    protected WebDriver driver;
    private InitializeBrowser browserInitiator;

    @Parameters({ "env", "browser","remote_url"})
    @BeforeMethod
    public void setUp(@Optional("https://host.docker.internal/LEAF_Request_Portal/admin/") String env, @Optional("CHROME") String browser, @Optional("") String remote_url) throws MalformedURLException {

        browserInitiator = new InitializeBrowser();
        if(remote_url.equalsIgnoreCase("")){
            driver = browserInitiator.getDriver(browser);
        }else{
            driver = browserInitiator.getRemoteDriver(remote_url);
        }
        browserInitiator.navigateToURL(env);
        driver.get(env);
        System.out.println("Title: "+driver.getCurrentUrl()+" -->"+driver.getTitle());
    }

    @AfterMethod(alwaysRun = true)
    public void tearDown(){
        if (browserInitiator !=null){
            browserInitiator.quitBrowser();
        }
    }
}
