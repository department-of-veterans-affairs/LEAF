pong

<br/><br/><br/>****** Anything this line and down better be gone before this gets to production!!! *********
<br/>ping <br/> Have / going here temporarily.<br/><br/>

<?php
error_reporting(E_ERROR);
ini_set('display_errors', 1);
set_time_limit(0);

echo "<br/><br/>Toga chown and chmod<br/><br/>";
echo "This server's ip is: {$_SERVER['SERVER_ADDR']}<br/><br/><br/>";

include '../LEAF_Nexus/globals.php';
include '../LEAF_Nexus/config.php';
include '../LEAF_Nexus/db_mysql.php';

class User {
  private $emp_uid;
  private $user_guid;
  private $user_name;
  private $last_name;
  private $first_name;
  private $middle_name;
  private $phonetic_first_name;
  private $phonetic_last_name;
  private $domain;
  private $deleted = 0;
  private $last_updated;
  private $email;
  private $phone;
  private $work_phone;
  private $db;
  private $user_map = array("empUID"=>"emp_uid", 'new_empUUID'=>'user_guid', 'userName'=>'user_name', 'lastName'=>'last_name',
          'firstName'=>'first_name','middleName'=>'middle_name', 'phoneticFirstName'=>'phonetic_first_name',
          'phoneticLastName'=>'phonetic_last_name', 'domain'=>'domain', 'deleted'=>'deleted', 'lastUpdated'=>'last_updated');
  private $map_user;
  private $user_data = array(5=>'work_phone', 6=>'email', 16=>'phone' );
  public $rando_users;
  private $rando_pick_count;

  public function __construct(string $user_id='1', string $user_guid=''){
    $this->map_user  = array_flip($this->user_map);
    $this->last_updated = time();
    echo "User Id: {$user_id}<br/><br/>";
    $this->db = new Db(DATABASE_HOST, DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_DB_DIRECTORY);
    if (!empty($user_id)) $this->emp_uid = $user_id;
    // $this->setUser($user_id, $user_guid);
  }

  public function setUser(string $user_id='', string $user_guid=''){
    if(!empty($user_guid)){
      $sql = "SELECT * FROM employee
        where ({$this->map_user['user_guid']} = '{$user_guid}' ||
          {$this->map_user['user_name']} = '{$user_guid}')";
    } elseif(!empty($user_id)){
      $sql = "select * from employee where empUID='{$user_id}'";
    } else {
      return TRUE;
    }

    $users = $this->db->query($sql);
    // echo "<pre>";
    // var_dump($users[0]);
    // echo "</pre><br/><br/>";
    foreach($this->user_map as $sql_param=>$class_param){
      $this->$class_param = $users[0][$sql_param];
    }
    return $this->getUser();
  }

  private function create_guid(int $count=5, string $salt='fizbinn', array $char_count=array(8, 4, 4, 4, 12)) {
    $guid_arr = array();
    $namespace = rand(11111, 99999);
    $uid = uniqid('', true);
    $data = $namespace;
    $data .= $_SERVER['REQUEST_TIME'];
    $data .= $_SERVER['HTTP_USER_AGENT'];
    $data .= $_SERVER['REMOTE_ADDR'];
    $data .= $_SERVER['REMOTE_PORT'];
    $hash = strtolower(hash('sha384', $uid . $salt . md5($data)));
    // echo "<br/>Hash count: ". strlen($hash) . "  -- Hash: {$hash}<br/><br/>";
    $alpha = 0;
    for($i=0; $i<$count; $i++){
      $omega = $x+$char_count[$i];
      $guid_arr[$i] = substr($hash,  $alpha, $omega);
      $alpha += $char_count[$i];
      if ($alpha > strlen($hash)) break;
    }
    $guid = implode("-", $guid_arr);
    return $guid;
  }

  public function transmorgrifyUserData(){
    $rando_user_map = array('uid'=>'user_guid', 'user_name'=>'user_name', 'last_name'=>'last_name',
    'first_name'=>'first_name','middle_name'=>'middle_name', 'phonetic_first_name'=>'phonetic_first_name',
    'phonetic_last_name'=>'phonetic_last_name', 'domain'=>'domain', 'phone'=>'phone', 'email'=>'email',
    'work_phone'=>'work_phone', 'job_title'=>'job_title', 'ssn'=>'ssn', 'location'=>'location');
    // , 'deleted'=>'deleted', 'lastUpdated'=>'last_updated'
    $user = $this->randomite("user");
    $phone = $this->randomite("phone");
    $numbers = $this->randomite("numbers");
    $commerce = $this->randomite("commerce");
    $user_full = $this->randomite("user_complete");
    $user->user_name = strtoupper("vtr".$user->initials.$user->female_first_name);
    $user->phonetic_first_name = strtolower(preg_replace('#[aeiou\s]+#i', '', $user->first_name));
    $user->phonetic_last_name = strtolower(preg_replace('#[aeiou\s]+#i', '', $user->last_name));
    $user->domain = "VTR-".$numbers->id;
    $user->phone = $phone->cell_phone;
    $user->work_phone = $phone->phone_number;
    $user->email = "{$user->first_name}.{$user->last_name}@fake-email.com";
    $user->job_title = htmlspecialchars($user_full->employment->title);
    $user->ssn = $user_full->social_insurance_number;
    $user->location = $user_full->address->city . ", " . $user_full->address->state;


    foreach($rando_user_map as $key=>$cls){
      $clean = array('user_name', 'last_name', 'first_name', 'middle_name', 'domain', 'job_title', 'location');
      if(in_array($key, $clean)){
        $user->key = htmlspecialchars($user->$key);
      }
      $this->$cls = $user->$key;
      // echo "<br/>{$this->$cls}<br/>";
    }
    // echo "<pre>";print_r($user); echo "</pre>";
  }

  public function randomite(string $type='numbers', int $size=0){
    $api = "https://random-data-api.com/api";
    switch ($type){
      case "user":
        $api .= "/name/random_name";
        break;
      case "user_complete":
        $api .= "/users/random_user";
        break;
      case "phone":
        $api .= "/phone_number/random_phone_number";
        break;
      case "numbers":
        $api .= "/number/random_number";
        break;
      case "crypto":
        $api .= "/crypto/random_crypto";
        break;
      case "commerce":
        $api .= "/commerce/random_commerce";
        break;
      case "hipster":
        $api .= "/hipster/random_hipster_stuff";
        break;
    }
    if($size > 0){$api .= "/?size=$size";}

    $gimme_rando = $this->api_curling($api);
    if ($gimme_rando['code'] == 200){
      $rando_return = $gimme_rando['data'];
    } else {
      $rando_return = array("Request failed");
    }
    return $rando_return;
  }

  private function api_curling(string $url, array $post_fields=array(), array $header_fields=array()){
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_HEADER, FALSE);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
    if(count($post_fields)){
      curl_setopt($s,CURLOPT_POST,true);
      curl_setopt($s,CURLOPT_POSTFIELDS, $post_fields);
    }
    $respData = curl_exec($ch);
    $respCode = curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    curl_close($ch);
    if (in_array($respCode, array(200,301,302))) $respCode = 200;
    $curl_return = array('code'=>$respCode, 'data'=>json_decode($respData));
    return $curl_return;
  }

  private function prettyfy_user(){
    if(empty($this->user_guid)) $this->user_guid = $this->create_guid(5,"jacksparrow");
    $this->user_name = strtoupper($this->user_name);
  }

  public function getUser(){
    $user = array();
    foreach($this->user_map as $id){
      // echo "ID: {$id} = {$this->$id}<br/>";
      $user[$id] = $this->$id;
    }
    return $user;
  }
  public function getUserData(){
    $data = array();
    foreach($this->user_data as $key){
      $datum = $this->$key;
    }
    return $data;
  }
  public function storeUser(){
    $set_list = array();
    foreach($this->user_map as $sql=>$att){
      $new = htmlspecialchars($this->$att);
      $col_list[] = $sql;
      $set_list[$sql] = "'$new'";
    }
    $user_sql = "replace into employee (".implode(", ", $col_list).") values(".implode(", ",$set_list).")";
    echo $user_sql;
    $this->db->query($user_sql);
  }

  public function storeUserData(){
    $push_arr[] = "replace into employee_data
      values('{$this->emp_uid}', '5', '{$this->work_phone}', 'system', {$this->last_updated})";
    $push_arr[] = "replace into employee_data
      values('{$this->emp_uid}', '6', '{$this->email}', 'system', {$this->last_updated})";
    $push_arr[] = "replace into employee_data
      values('{$this->emp_uid}', '16', '{$this->phone}', 'system', {$this->last_updated})";
    $push_arr[] = "replace into employee_data
      values('{$this->emp_uid}', '-1', '{$this->domain}', 'system', {$this->last_updated})";
    $push_arr[] = "replace into employee_data
      values('{$this->emp_uid}', '-2', 'Yes', 'system', {$this->last_updated})";
    $push_arr[] = "replace into employee_data
      values('{$this->emp_uid}', '23', '{$this->job_title}', 'system', {$this->last_updated})";
    $push_arr[] = "replace into employee_data
      values('{$this->emp_uid}', '8', '{$this->location}', 'system', {$this->last_updated})";

    $push_sql = implode(";", $push_arr);
    echo "<br/><br/><br/>Toga: $push_sql<br/>";
    $this->db->query($push_sql);
  }

  public function getRandoUser(int $pool_size=10){
    $this->rando_pick_count++;
    // echo "JOJO pool: $pool_size pickCt: {$this->rando_pick_count}<br/>";
    if(empty($this->rando_users) || $this->rando_pick_count > $pool_size){
      $this->rando_users = $this->db->query("select * from employee limit {$pool_size}");
      $this->rando_pick_count = 0;
      // echo "I'm in the if<pre>"; print_r($this->rando_users); echo "</pre>";
    }
    $rand_user = $this->rando_users[array_rand($this->rando_users)];
    // echo "user: <pre>"; print_r($rand_user);echo "</pre>";
    return $rand_user;
  }
}


function resetGroupTable(int $limit=4){
  $db_config = new Config();
  $db = new Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
  $tmc = new User(1);
  for($i=2; $i<200; $i++){
    $stuffs = $tmc->randomite('commerce');
    $groupTitle = $stuffs->material . " " . $stuffs->department;
    $groupAbbreviation = $stuffs->color;
    $phoneticGroupTitle = preg_replace('#[aeiou\s]+#i', '', $groupTitle);
    $sql = "replace into groups values({$i},0,'{$groupTitle}','{$groupAbbreviation}','{$phoneticGroupTitle}')";
    $db->query($sql);
    $tag = $stuffs->product_name;
    $sql = "replace into group_tags values($i,'$tag')";
    $db->query($sql);
    echo "fasdf<pre>"; print_r($stuffs); echo "</pre>$sql";

  }
}

function createUserDb(int $total=300){
  for($i=2; $i<=350; $i++){
    $uc = new User($i);
    $uc->transmorgrifyUserData(TRUE);
    $uc->storeUser();
    $uc->storeUserData();
  }

}

function cleanRecords(){
  $db_config = new Config();
  $db_user = new Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
  $db_config->dbName = "leaf_portal";
  $db_portal = new Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
  $sql = "select recordID, serviceID from records";
  $records = $db_portal->query($sql);
  foreach($records as $record){
    if($record['serviceID'] == 0) $record['serviceID'] = 1;
    $u_sql = "select userName from employee where empUID={$record['serviceID']}";
    $user = $db_user->query($u_sql);
    echo "<br/>RecId: {$record['recordID']} -- ServId: {$record['serviceID']} -- New User: {$user[0]['userName']}<br/>";
    $fill_sql = "update records set userID='{$user[0]['userName']}' where recordID={$record['recordID']}";
    echo "$fill_sql<br/>";
    $db_portal->query($fill_sql);
  }
}

function cleanServiceChiefs(){
  $db_config = new Config();
  $db_user = new Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
  $db_config->dbName = "leaf_portal";
  $db_portal = new Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
  $sql = "select serviceID, userID from service_chiefs order by serviceID";
  $records = $db_portal->query($sql);
  $id_arr = array();
  foreach($records as $record){
    if($record['serviceID'] == 0) $record['serviceID'] = 1;
    $user_pull = $record['serviceID'];
    if(in_array($user_pull, $id_arr)){
      $user_pull = $user_pull + count($id_arr);
    }
    $id_arr[$record['serviceID']] = $record['serviceID'];
    $u_sql = "select userName from employee where empUID={$user_pull}";
    $user = $db_user->query($u_sql);
    echo "<br/>ServId: {$record['serviceID']} -- New User: {$user[0]['userName']}<br/>";
    $fill_sql = "update service_chiefs set userID='{$user[0]['userName']}'
      where serviceID={$record['serviceID']} && userID='{$record['userID']}'";
    echo "$fill_sql<br/>";
    $db_portal->query($fill_sql);
  }
}

function buildPortalUsers(int $user_count=300){
  $db_config = new Config();
  $db_user = new Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
  $db_config->dbName = "leaf_portal";
  $db_portal = new Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
  $groups = $db_portal->query("select groupID from groups where groupID>0");
  // echo "<pre>";print_r($groups);echo "</pre>";
  for($i=2; $i<$user_count; $i++){
    $key = array_rand($groups);
    $group = $groups[$key]['groupID'];
    $user_name = $db_user->query("select userName from employee where empUID={$i}")[0]['userName'];
    echo "<br/>ID: $i -- User: $user_name -- Group: $group";
    $new_user_sql = "insert into users values('$user_name', $group, null, 0, 0, 1)";
    echo "<br/>$new_user_sql";
    $db_portal->query($new_user_sql);
  }

}

function cleanIndicators(int $seed_size=3){
  $db_config = new Config();
  $db_config->dbName = "leaf_portal";
  $db_portal = new Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
  $rando_miter = new User();
  $bulk_hippy = $rando_miter->randomite('hipster',$seed_size);
  $hippy_dippy = array();
  foreach($bulk_hippy as $hippy){
    $hippy_array[] = array_merge($hippy->words, $hippy->sentences); //, $hippy->paragraphs
  }
  foreach($hippy_array as $key=>$hippy_talk){
    $hippy_dippy = array_merge($hippy_dippy, $hippy_talk);
  }

  for($i=300; $i<2282; $i++){
    $hd = htmlspecialchars($hippy_dippy[array_rand($hippy_dippy)]);
    $sql = "update indicators set name='$hd' where indicatorID=$i";
    $db_portal->query($sql);
  }
  echo "<pre>"; print_r($hippy_dippy); echo "</pre>";

}

function cleanRecordsnData(int $seed_size=4){
  $db_config = new Config();
  $db_config->dbName = "leaf_portal";
  $db_portal = new Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
  $rando_miter = new User();
  $bulk_hippy = $rando_miter->randomite('hipster',$seed_size);
  $bulk_user = $rando_miter->randomite('user_complete', $seed_size);
  foreach($bulk_hippy as $hippy){
    $hippy_words = array_merge((array)$hippy_words, $hippy->words);
    $hippy_sentences = array_merge((array)$hippy_sentences, $hippy->sentences);
    $hippy_paragraphs = array_merge((array)$hippy_paragraphs, $hippy->paragraphs);
  }
  // echo "<pre>"; print_r($hippy_array); echo "</pre>";


  $sql = "select recordID, serviceID, userID from records";
  $records = $db_portal->query($sql);
  $list_of_formats = array();
  foreach($records as $record){
    $up_sql = array();
    $data_sql = "select data.*, format from data
          LEFT JOIN indicators using (indicatorID)
          where recordID={$record['recordID']} ";
    $data = $db_portal->query($data_sql);
    // echo "$data_sql<pre>"; print_r($data); echo "</pre>";
    foreach($data as $key=>$datum){
      $user_data = $bulk_user[array_rand($bulk_user)];
      $datum['format'] = strtolower(preg_split('/\s+/', $datum['format'])[0]);
      $list_of_formats[$datum['format']] = $datum['format'];
      switch($datum['format']){
        case "orgchart_employee":
          $datum['data'] = $rando_miter->getRandoUser($seed_size)['userName'];
          // echo "<pre>";print_r($rando_miter->getRandoUser($seed_size)); echo "</pre>";
          break;
        case "orgchart_group":
          $datum['data'] = rand(1,200);
          break;
        case "orgchart_position":
          $datum['data'] = rand(1,40);
          break;
        case "date":
          $datum['data'] = date_format(date_create($user_data->date_of_birth), "m/d/Y");
          break;
        case "currency":
          $datum['data'] = substr_replace($user_data->id,".",-2,0);
          break;
        case "number":
          $datum['data'] = $user_data->social_insurance_number;
          break;
        case "checkbox":
        case "checkboxes":
        case "radio":
        case "dropdown":
          $datum['data'] = $hippy_words[array_rand($hippy_words)];
          break;
        case "raw_data":
        case "textarea":
          $datum['data'] = $hippy_sentences[array_rand($hippy_sentences)];
          break;
        case "text":
          $datum['data'] = $hippy_sentences[array_rand($hippy_sentences)];
          break;
        case "fileupload":
          $datum['data'] = "FM_Pam_21-13.gov";
          break;
        case "grid":
          // this looks clean at this time.
          break;
        default:
          $datum['data'] = ucwords($hippy_sentences[array_rand($hippy_sentences)]);
          break;
      }
      $datum['userID'] = $record['userID'];
      // echo "<pre>";print_r($datum);echo "</pre>";
      $new_data = htmlspecialchars($datum['data'], ENT_QUOTES);
      $up_sql[] = "update data set data='{$new_data}', userID='{$record['userID']}'
        where recordID={$datum['recordID']} && indicatorID={$datum['indicatorID']} && series={$datum['series']}";
      $up_sql[] = "update data_history set data='{$new_data}', userID='{$record['userID']}'
        where recordID={$datum['recordID']} && indicatorID={$datum['indicatorID']} && series={$datum['series']}";
    }

    $new_title = ucwords(rtrim(htmlspecialchars($hippy_sentences[array_rand($hippy_sentences)], ENT_QUOTES), "."));
    $up_sql[] = "update records set title='{$new_title}' where recordID={$record['recordID']}";
    $db_portal->query(implode(";",$up_sql));
    //echo "<pre>";print_r($up_sql);echo "</pre><hr/>";
  }
  echo "All d formats: <pre>";print_r($list_of_formats); echo "</pre>";
}

function historyCleaner(int $seed_size=99){
  $db_config = new Config();
  $db_config->dbName = "leaf_portal";
  $db_portal = new Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
  $rando_miter = new User();
  $bulk_hippy = $rando_miter->randomite('hipster',$seed_size);
  foreach($bulk_hippy as $hippy){
    $hippy_words = array_merge((array)$hippy_words, $hippy->words);
    $hippy_sentences = array_merge((array)$hippy_sentences, $hippy->sentences);
    $hippy_paragraphs = array_merge((array)$hippy_paragraphs, $hippy->paragraphs);
  }
  for($i=1; $i<664; $i++){
    $sentence = htmlspecialchars($hippy_sentences[array_rand($hippy_sentences)], ENT_QUOTES);
    $sql[] = "update action_history set comment='{$sentence}' where actionID=$i";
  }
  $sql_push = implode(";", $sql);
  $db_portal->query($sql_push);
  echo "<pre>"; print_r($sql_push);echo "</pre>";
  echo "<pre>"; print_r($sql);echo "</pre>";
}


// createUserDb(350);
// resetGroupTable(4);
// cleanRecords();
// cleanServiceChiefs();
// buildPortalUsers(200);
////////// cleanIndicators(100);
// cleanRecordsnData(100);
// historyCleaner();
?>