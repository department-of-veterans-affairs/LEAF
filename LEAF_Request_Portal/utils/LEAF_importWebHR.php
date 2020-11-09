<?php
set_time_limit(0);

include __DIR__ . '/../Login.php';
include __DIR__ . '/../form.php';

$db = new DB($db_config->dbHost, $$db_config->dbUser, $$db_config->dbPass, $$db_config->dbName);
$db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);

$login = new Login($db_phonebook, $db);
$login->setBaseDir(__DIR__ . '/../');
$login->loginUser();
if(!$login->isLogin() || !$login->isInDB()) {
	echo 'Your computer login is not recognized. Is your account managed by IRM? If you are looking for the Resource Site demo, please visit: https://vhawasweb1.v05.med.va.gov/resource_demo/';
	exit;
}

$form = new Form($db, $login);
importData($_POST['webHR'], $form, $db);

function importData($data, $form, $db)
{
	$rawdata = explode("\n", $data);
	// extract table headings
	$rawheaders = trim(array_shift($rawdata));
	$headers = explode("\t", $rawheaders);
	$idx = 0;
	$csvdeIdx = array();
	foreach($headers as $header) {
		$csvdeIdx[$header] = $idx;
		$idx++;
	}

//	print_r($csvdeIdx);
//	exit();

	$count = 0;
	foreach($rawdata as $line) {
		$t = splitWithEscape($line, "\t");
		array_walk($t, 'trim');

		$vars = array(':arpa' => $t[$csvdeIdx['ARPA ID']]); // ARPA #
		$res = $db->prepared_query('SELECT * FROM data
										WHERE indicatorID=372
											AND data=:arpa', $vars);

		if(count($res) == 1) {
			$_POST = array();
			$_POST['CSRFToken'] = $_SESSION['CSRFToken'];
			$_POST['series'] = 1;
			$_POST['256'] = $t[$csvdeIdx['Specialist']];
			$_POST['366'] = $t[$csvdeIdx['Milestone Local Use 2']];
			$_POST['354'] = $t[$csvdeIdx['Vacancy Ann. Number']];
			$_POST['250'] = $t[$csvdeIdx['Vac. Ann. Open Date']];
			$_POST['251'] = $t[$csvdeIdx['Vac. Ann. Close Date']];
			$_POST['252'] = $t[$csvdeIdx['Date Vac. Ann. Certificate to Service']];
			$_POST['253'] = $t[$csvdeIdx['Date Vac. Ann. Certificate from Service']];
			$_POST['255'] = $t[$csvdeIdx['Selectee Name']];
			$_POST['257'] = $t[$csvdeIdx['Date Selectee Contacted']];
			$_POST['328'] = $t[$csvdeIdx['Date of EOD']];
			$_POST['355'] = $t[$csvdeIdx['Position Title']];
			$_POST['397'] = $t[$csvdeIdx['Local Remarks']];
//			$_POST['402'] = $t[$csvdeIdx['Date Fingerprints Taken (SAC)']];
//			$_POST['403'] = $t[$csvdeIdx['Date Background Check Initiated (eQIP)']];
			$_POST['404'] = $t[$csvdeIdx['Date Background Check Results Adjudicated']];
//			$_POST['405'] = $t[$csvdeIdx['Date Credentialing Started (VETPRO)']];
//			$_POST['406'] = $t[$csvdeIdx['Date Credentialing Completed (VETPRO)']];
//			$_POST['407'] = $t[$csvdeIdx['Date Physician Compensation Panel Convened']];
//			$_POST['408'] = $t[$csvdeIdx['Date Physician Compensation Panel Completed']];
//			$_POST['409'] = $t[$csvdeIdx['Date Professional Standard Board Convened']];
//			$_POST['410'] = $t[$csvdeIdx['Date Professional Standard Board Completed']];
//			$_POST['411'] = $t[$csvdeIdx['Date of Physical Examination']];
//			$_POST['412'] = $t[$csvdeIdx['Date Physical Exam Cleared']];
			$_POST['415'] = $t[$csvdeIdx['Occupational Series']];
			$form->doModify($res[0]['recordID']);

			$count++;
			echo "RequestID# {$res[0]['recordID']} | ARPA {$res[0]['data']} updated\n";
		}
	}
	
	echo "{$count} imported successfully.";
}

// workaround for excel
// author: tajhlande at gmail dot com
function splitWithEscape ($str, $delimiterChar = ',', $escapeChar = '"') {
	$len = strlen($str);
	$tokens = array();
	$i = 0;
	$inEscapeSeq = false;
	$currToken = '';
	while ($i < $len) {
		$c = substr($str, $i, 1);
		if ($inEscapeSeq) {
			if ($c == $escapeChar) {
				// lookahead to see if next character is also an escape char
				if ($i == ($len - 1)) {
					// c is last char, so must be end of escape sequence
					$inEscapeSeq = false;
				} else if (substr($str, $i + 1, 1) == $escapeChar) {
					// append literal escape char
					$currToken .= $escapeChar;
					$i++;
				} else {
					// end of escape sequence
					$inEscapeSeq = false;
				}
			} else {
				$currToken .= $c;
			}
		} else {
			if ($c == $delimiterChar) {
				// end of token, flush it
				array_push($tokens, $currToken);
				$currToken = '';
			} else if ($c == $escapeChar) {
				// begin escape sequence
				$inEscapeSeq = true;
			} else {
				$currToken .= $c;
			}
		}
		$i++;
	}
	// flush the last token
	array_push($tokens, $currToken);
	return $tokens;
}
