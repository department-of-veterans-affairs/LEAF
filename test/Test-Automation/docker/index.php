<?php
  $result = exec("cd /app && mvn test -Denv=remote", $output, $return_var);

  if ($return_var === 0) {
    // Output the results
    foreach ($output as $line) {
        echo $line . "<br>";
    }
  } else {
      echo "Error executing command";
  }

?>