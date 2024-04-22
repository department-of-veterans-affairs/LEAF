package main.java;
/*
import org.apache.commons.compress.archivers.dump.InvalidFormatException;
import org.apache.commons.io.FileUtils;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.time.Duration;
import java.util.Random;

public class Utils {
    public static int pageLoadTimeOut= 60;
    public static int implicitWaitTime = 30;
    public static WebDriverWait explicitWait;
    //Defined our WebDriver
    public static WebDriver driver = null;
    //Current directory address
    public static String currentDir = System.getProperty("user.dir");

    //Constructor of Utils class calling super class
    public Utils(){
        super();
    }

    //Added screenshot method
    public static String takeScreenshot(WebDriver driver) throws IOException {
        TakesScreenshot screenshot = ((TakesScreenshot) driver);
        File file = screenshot.getScreenshotAs(OutputType.FILE);
        //Generating random number for screenshot name
        Random rd = new Random();
        int i = rd.nextInt();
        File destination = new File(currentDir+"//Screenshot/screenshot_"+i+".png");
        FileUtils.copyFile(file,destination);
        String scr_path = currentDir+"//Screenshot/screenshot_"+i+".png";
        return scr_path;
    }

    //Getting the pageTitle of current page
    public String getPageTitle(){
        String pageTitle = driver.getTitle();
        System.out.println("Page title of current page is :"+pageTitle);
        return pageTitle;
    }

    //Adding explicit wait
    public void setExplicitWait(int seconds){
        explicitWait = new WebDriverWait(driver, Duration.ofSeconds(seconds));
    }

    static Workbook book;
    static Sheet sheet;

    public static Object[][] getTestData(String sheetName)  {
        FileInputStream file = null;
        try{
            file = new FileInputStream(TESTDATA_SHEET_PATH);
        }catch (FileNotFoundException e){
            e.printStackTrace();
        }
        try{
            book = WorkbookFactory.create(file);
        }catch (InvalidFormatException e){
            e.printStackTrace();
        }catch (IOException e){
            e.printStackTrace();
        }
        sheet = book.getSheet(sheetName);
        Object[][] data = new Object[sheet.getLastRowNum()][sheet.getRow(0).getLastCellNum()];
        for(int i =0;i<sheet.getLastRowNum();i++){
            for(int j =0; j<sheet.getRow(0).getLastCellNum(); j++){
                data[i][j] = sheet.getRow(i+1).getCell(j).toString();
            }
        }
        return data;
    }

}

 */
