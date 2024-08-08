package main.java.listeners;

import org.testng.IAnnotationTransformer;
import org.testng.IRetryAnalyzer;
import org.testng.annotations.ITestAnnotation;
import main.java.util.RetryAnalyzerUtil;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;

/**
 * Listener to apply retry logic globally to all test methods.
 */
public class RetryListener implements IAnnotationTransformer {

    @Override
    public void transform(ITestAnnotation annotation, Class testClass, Constructor testConstructor, Method testMethod) {

            annotation.setRetryAnalyzer(RetryAnalyzerUtil.class);

    }
}
