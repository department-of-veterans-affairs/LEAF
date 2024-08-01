<?php
  $result = exec("mvn test", $output, $return_var);
  if ($return_var === 0) {
    // Display results page
    include './ExtentReports/AutomationResult.html';

  } else {
      echo "Error executing command";
  }

?>