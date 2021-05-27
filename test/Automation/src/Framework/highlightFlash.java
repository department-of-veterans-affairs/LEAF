package Framework;

public static void highlightFlash(WebElement element,String color,int milli){

if(CommonLocal.demo){try{String existingStyle=null;try{existingStyle=element.getAttribute("style");if(!existingStyle.equals("")){existingStyle=existingStyle+"; ";}}catch(Exception e){existingStyle="";}

WrapsDriver wrappedElement=(WrapsDriver)element;

JavascriptExecutor driver=(JavascriptExecutor)wrappedElement.getWrappedDriver();

driver.executeScript("arguments[0].setAttribute('style', arguments[1]);",element,existingStyle+"background-color: "+color+";");

Thread.sleep(milli);

// REMOVE background color
existingStyle=element.getAttribute("style");existingStyle=existingStyle.replaceAll("background-color: "+color+";","");

driver.executeScript("arguments[0].setAttribute('style', arguments[1]);",element,existingStyle);

}catch(Exception e){log.logger.info("Exception Color highlighting element:  "+e);}}

}