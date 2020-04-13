<?php

use Phinx\Migration\AbstractMigration;

require_once __DIR__ . '/util.inc';

class CreateTableTxRules extends AbstractMigration
{
  const REF_LIST = 'anybody account anyCompany industry group';
  const ACT_LIST = 'pay now gift';

  const SAME_AS_PAYER = -1;
  const SAME_AS_PAYEE = -2;

  /**
   * Change Method.
   *
   * Write your reversible migrations using this method.
   *
   * More information on writing migrations is available here:
   * http://docs.phinx.org/en/latest/migrations.html#the-abstractmigration-class
   *
   * The following commands can be used in this method and Phinx will
   * automatically reverse them when rolling back:
   *
   *    createTable
   *    renameTable
   *    addColumn
   *    renameColumn
   *    addIndex
   *    addForeignKey
   *
   * Remember to call "create()" or "update()" and NOT "save()" when working
   * with the Table class.
   */
  public function change()
  {
    $table = $this->table('tx_rules', ['comment' => 'Occurrences of a rule']);
    $table
      ->addColumn('payer', 'biginteger', ['null' => true, 'default' => null,
                                          'comment' => 'Payer party to base transaction, null if anybody'])
      ->addColumn('payerType', 'enum', ['values' => ray(self::REF_LIST),
                                        'comment' => 'Type of payer'])
      ->addColumn('payee', 'biginteger', ['null' => true, 'default' => null,
                                          'comment' => 'Payee party to base transaction, null if anybody'])
      ->addColumn('payeeType', 'enum', ['values' => ray(self::REF_LIST),
                                        'comment' => 'Type of payee'])
      ->addColumn('from', 'biginteger', ['comment' => 'Who to transfer money from'])
      ->addColumn('to', 'biginteger', ['comment' => 'Who to transfer money to'])
      ->addColumn('action', 'enum', ['values' => ray(self::ACT_LIST),
                                     'comment' => 'Action that triggers templates of this type'])
      ->addColumn('amount', 'decimal', ['precision' => 11, 'scale' => 2, 'default' => 0, 'signed' => false,
                                        'comment' => 'Fixed amount to transfer'])
      ->addColumn('portion', 'decimal', ['precision' => 7, 'scale' => 6, 'default' => 0, 'signed' => false,
                                         'comment' => 'Proportional amount, e.g., 5%, to transfer, expressed as a decimal, e.g., 0.05'])
      ->addColumn('purpose', 'string', ['length' => 255, 'default' => '',
                                        'comment' => 'Text to appear on statements explaining this'])
      ->addColumn('minimum', 'decimal', ['precision' => 11, 'scale' => 2, 'default' => 0, 'signed' => false,
                                         'comment' => 'Minimum amount of transaction that this template applies to'])
      ->addColumn('useMax', 'integer', ['null' => true, 'default' => null, 'signed' => false,
                                        'comment' => 'Maximum number of uses per member, NULL if no max'])
      ->addColumn('extraMax', 'decimal', ['precision' => 11, 'scale' => 2, 'null' => true, 'default' => null,
                                          'signed' => false,
                                          'comment' => 'Maximum amount to transfer, NULL if no limit'])
      ->addColumn('template', 'integer', ['null' => true, 'default' => null,
                                          'comment' => 'Template of which this is an occurrence'])
      ->addColumn('start', 'biginteger', ['default' => 0,
                                          'comment' => 'Start of period for which this occurrence applies'])
      ->addColumn('end', 'biginteger', ['null' => true,
                                        'comment' => 'End of period for which this occurrence applies, NULL if it does not end'])
      ->addColumn('code', 'integer', ['null' => true, 'default' => null,
                                      'comment' => 'For gift cards the individual code'])
      /* ->addForeignKey('template', 'tx_templates', 'id', ['delete' => 'restrict']) */
      ->create();
  }
}
