Feature: Invoices
AS a member
I WANT to charge other members and pay invoices from other members automatically at night, if necessary
SO I can buy and sell stuff.

Setup:
  Given members:
  | uid  | fullName | risks   | floor | minimum | flags                           |*
  | .ZZA | Abe One  | hasBank |  -250 |     500 | ok,confirmed,refill,debt,bankOk |
  | .ZZB | Bea Two  |         |  -250 |     100 | ok,confirmed,debt               |
  | .ZZC | Our Pub  |         |  -250 |       0 | ok,confirmed,co,debt            |
  | .ZZE | Eve Five | hasBank |  -250 |     200 | bankOk                          |
  And relations:
  | main | agent | permission |*
  | .ZZC | .ZZB  | buy        |

  Scenario: Unpaid invoices get handled
  Given transactions: 
  | xid | created | amount | from | to   | purpose | taking |*
  |   1 | %today  |    100 | ctty | .ZZA | grant   |        |
  And invoices:
  | nvid | created   | status       | amount | from | to   | for   |*
  |    1 | %today    | %TX_APPROVED |    100 | .ZZA | .ZZC | one   |
  |    2 | %today    | %TX_APPROVED |    200 | .ZZA | .ZZC | two   |
  |    3 | %today    | %TX_APPROVED |    300 | .ZZB | .ZZC | three |
  |    4 | %today-1w | %TX_PENDING  |    400 | .ZZA | .ZZC | four  |
  Then balances:
  | uid  | balance |*
  | .ZZA |     100 |
  | .ZZB |       0 |
  | .ZZC |       0 |
  
  When cron runs "invoices"
  Then transactions: 
  | xid | created | amount | from | to   | purpose              | taking | type  |*
  |   2 | %today  |    100 | .ZZA | .ZZC | one (%PROJECT inv#1) |        | prime |
  |   3 | %today  |    200 | .ZZA | .ZZC | two (%PROJECT inv#2) |        | prime |
  |   4 | %today  |      0 |  256 | .ZZA | from bank            |      1 | bank  |
	Then count "txs" is 4
	And count "usd" is 1
	And count "invoices" is 4
	And usd transfers:
  | txid | payee | amount | created | completed | deposit |*
  |    1 | .ZZA  |    700 | %today  |         0 |       0 |
  And invoices:
  | nvid | created   | status       | amount | from | to   | for   | flags   |*
  |    1 | %today    | 2            |    100 | .ZZA | .ZZC | one   |         |
  |    2 | %today    | 3            |    200 | .ZZA | .ZZC | two   | funding |
  |    3 | %today    | %TX_APPROVED |    300 | .ZZB | .ZZC | three |         |
  |    4 | %today-1w | %TX_PENDING  |    400 | .ZZA | .ZZC | four  |         |

  And we notice "banked|bank tx number" to member ".ZZA" with subs:
  | action | tofrom | amount | checkNum | why               |*
  | draw   | from   | $700   |        1 | to pay invoice #2 |
  And we notice "short invoice|when funded|how to fund" to member ".ZZB" with subs:
  | short | payeeName | nvid |*
  | $50   | Our Pub   |    3 |
  And we message "stale invoice" to member ".ZZA" with subs:
  | daysAgo | amount | purpose | nvid | payeeName |*
  |       7 | $400   | four    |    4 | Our Pub   |
  And we message "stale invoice report" to member ".ZZC" with subs:
  | daysAgo | amount | purpose | nvid | payerName | created |*
  |       7 | $400   | four    |    4 | Abe One   | %mdY-1w |
  Then balances:
  | uid  | balance |*
  | .ZZA |    -200 |
  | .ZZB |       0 |
  | .ZZC |     300 |

  When cron runs "getFunds"
	Then usd transfer count is 1

  When cron runs "invoices"
  Then usd transfer count is 1

Scenario: Non-member unpaid invoice does not generate a transfer request
  Given invoices:
  | nvid | created   | status       | amount | from | to   | for   |*
  |    1 | %today    | %TX_APPROVED |    100 | .ZZE | .ZZC | one   |
  Then balances:
  | uid  | balance |*
  | .ZZC |       0 |
  | .ZZE |       0 |
  When cron runs "invoices"
	Then count "txs" is 0
	And count "usd" is 0
	And count "invoices" is 1
  
Scenario: Second invoice gets funded too for a non-refilling account
  Given members have:
  | uid  | flags               |*
  | .ZZA | ok,confirmed,bankOk |
  And these "usd":
  | txid | payee | amount | created   | completed | deposit |*
  |    1 | .ZZA  |    100 | %today-1d |         0 |       0 |
  And invoices:
  | nvid | created   | status       | amount | from | to   | for   | flags   |*
  |    1 | %today-1d | %TX_APPROVED |    100 | .ZZA | .ZZC | one   | funding |
  |    2 | %today    | %TX_APPROVED |    200 | .ZZA | .ZZC | two   |         |
  When cron runs "invoices"
	Then these "usd":
  | txid | payee | amount | created   | completed | deposit |*
  |    1 | .ZZA  |    300 | %today-1d |         0 |       0 |
  # still dated yesterday, so it doesn't lose its place in the queue
  And invoices:
  | nvid | created   | status       | amount | from | to   | for   | flags   |*
  |    1 | %today-1d | %TX_APPROVED |    100 | .ZZA | .ZZC | one   | funding |
  |    2 | %today    | %TX_APPROVED |    200 | .ZZA | .ZZC | two   | funding |
  And we notice "banked|combined|bank tx number" to member ".ZZA" with subs:
  | action | tofrom | amount | previous | total | checkNum | why               |*
  | draw   | from   | $200   |     $100 |  $300 |        1 | to pay invoice #2 |

Scenario: A languishing invoice gets funded again
  Given invoices:
  | nvid | created   | status       | amount | from | to   | for   | flags   |*
  |    1 | %today-1m | %TX_APPROVED |    900 | .ZZA | .ZZC | one   | funding |
  When cron runs "invoices"
	Then these "usd":
  | txid | payee | amount | created | completed | deposit |*
  |    1 | .ZZA  |    900 | %today  |         0 |       0 |

Scenario: An invoice is approved from an account with a negative balance
  Given members have:
  | uid  | flags               | balance |*
  | .ZZA | ok,confirmed,bankOk |    -500 |
  And invoices:
  | nvid | created   | status       | amount | from | to   | for   | flags   |*
  |    1 | %today-1m | %TX_APPROVED |    400 | .ZZA | .ZZC | one   | funding |
  When cron runs "invoices"
	Then these "usd":
  | txid | payee | amount | created | completed | deposit |*
  |    1 | .ZZA  |    900 | %today  |         0 |       0 |