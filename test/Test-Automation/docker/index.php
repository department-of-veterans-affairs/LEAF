<?php
  $result = exec("mvn test -Dbrowser=remote", $output, $return_var);
  if ($return_var === 0) {
    // Output the results
    foreach ($output as $line) {
      if(stripos($line, "WARNING") || stripos($line, 'info')){
        continue;
      } else {
        $toga = str_ireplace("[[1;31mERROR[m]", "Error: ", $line);
        echo $toga . "<br>";
      }
    }
  } else {
      echo "Error executing command";
  }

?>