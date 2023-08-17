<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

class ActiveDirectory
{
   private $server = AD_SRV;
   private $rdn = LEAF_SVC; // Use the LEAF service account.
   private $dataTable;
   private $conn;
   private $bind;
   private $base = LDAP_BASE;
   private $PORT = LDAP_PORT;

   public function __construct() {
      $this->conn = ldap_connect($this->server, $this->PORT);

      ldap_set_option($this->conn, LDAP_OPT_PROTOCOL_VERSION, 3);
      ldap_set_option($this->conn, LDAP_OPT_REFERRALS, 0);

      $this->bind = ldap_bind($this->conn, $this->rdn, AD_PW);
   }

   public function searchMember(string $uid = "") : ?array
   {
      $info = [];
      $filter = "(&(objectCategory=Person)(objectClass=User)(anr=$uid))"; // search only for users classified as persons (i.e. not service accounts)
      $attr = ["objectClass", "sn", "givenName","initials","title","description","telephoneNumber","mail","sAMAccountName","objectGUID","mobile","physicalDeliveryOfficeName"]; // fields for each result to return
      if ($this->bind) {
         $results = ldap_search($this->conn, $this->base, $filter, $attr);
         $info = ldap_get_entries($this->conn, $results);
      }
      return $info;
   }

   public function searchGroup(string $input = "") : array
   {
      $info = [];
      $filter = "(&(objectClass=Group)(anr=$input))"; // search only for groups
      $attr = ["objectClass", "cn", "title", "sAMAccountName", "managedBy", "member", "description", "objectGUID"]; // fields for each result to return
      if ($this->bind) {
         $results = ldap_search($this->conn, $this->base, $filter, $attr);
         $info = ldap_get_entries($this->conn, $results);
      }
      return $info;
   }

   public function listMembers(array $members = []) : array
   {
      $info = [];
      $fmtMembers = implode(")(", $members);
      $filter = "(/($fmtMembers))"; /// search only for users classified as persons (i.e. not service accounts)
      $attr = ["objectClass", "sn", "givenName","initials","title","description","telephoneNumber","mail","sAMAccountName","objectGUID","mobile","physicalDeliveryOfficeName"]; // fields for each result to return
      if ($this->bind) {
         $results = ldap_search($this->conn, $this->base, $filter, $attr);
         $info = ldap_get_entries($this->conn, $results);
      }
      return $info;
   }
}
