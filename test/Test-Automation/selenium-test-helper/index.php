<?php
  $result = exec("cd /app && mvn test -Dremote.url=http://192.168.0.16:4445 -Dapp.url=host.docker.internal/LEAF_Request_Portal/admin/ -Dclass.name=test.java.formWorkflow.formWorkflow_Test", $output, $return_var);

  if ($return_var === 0) {
    // Output the results
    foreach ($output as $line) {
        echo $line . "<br>";
    }
  } else {
      echo "Error executing command";
  }