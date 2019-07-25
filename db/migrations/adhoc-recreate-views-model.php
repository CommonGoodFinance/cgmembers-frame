<?php
use Phinx\Migration\AbstractMigration;

require_once __DIR__ . '/util.inc';

class Views extends AbstractMigration {
  public function up() {createViews($this);}

  private function chg($oldId, $newId) {
    $this->execute("UPDATE tx_entries_all SET id=$newId WHERE id=$oldId"); // don't use doSql here (too much output)
//    pr("changed $oldId to $newId\n");
  }

  public function doSql($sql) {
    pr("$sql\n");
    $this->execute($sql);
  }
}
