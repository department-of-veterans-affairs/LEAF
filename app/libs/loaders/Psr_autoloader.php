<?php
// PhpSpreadsheet was built using Composer, this is necessary to avoid including Composer
// as a dependency and allowing classes to autoload
spl_autoload_register(function ($class_name) {
	$preg_match = preg_match('/^Psr\\\/', $class_name);

	if (1 === $preg_match) {
		require_once(__DIR__ . '/Psr.php');
	} else if (false === $preg_match) {
		assert(false, 'Error de preg_match().');
	}
});