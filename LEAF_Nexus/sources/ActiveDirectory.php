<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

class ActiveDirectory extends Data
{
   protected $dataTable;

   public function initialize() {}

   public function getTitle(int $id) : mixed
   {
      return array();
   }

   public function getGroup(int $id) : mixed
   {
      return array();
   }

   public function listMembers(int $id) : mixed
   {
      return array();
   }

   public function search(string $input, string $tag = "") : mixed
   {
      return array();
   }
}
