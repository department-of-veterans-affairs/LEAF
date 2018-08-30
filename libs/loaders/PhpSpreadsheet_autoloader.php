<?php
// PhpSpreadsheet was built using Composer, this is necessary to avoid including Composer
// as a dependency and allowing classes to autoload
spl_autoload_register(function ($class_name) {
	$preg_match = preg_match('/^PhpOffice\\\PhpSpreadsheet\\\/', $class_name);

	if (1 === $preg_match) {
		$class_name = preg_replace('/\\\/', '/', $class_name);
		$class_name = preg_replace('/^PhpOffice\\/PhpSpreadsheet\\//', '', $class_name);
		require_once(__DIR__ . '/../PhpSpreadsheet/src/PhpSpreadsheet/' . $class_name . '.php');
	}
});