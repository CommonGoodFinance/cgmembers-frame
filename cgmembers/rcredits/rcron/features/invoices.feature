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
  And invoices:
  | nvid | created   | status       | amount | from | to   | for   |*
  |    1 | %today    | %TX_APPROVED |    100 | .ZZA | .ZZC | one   |
  |    2 | %today    | %TX_APPROVED |    200 | .ZZA | .ZZC | two   |
  |    3 | %today    | %TX_APPROVED |    300 | .ZZB | .ZZC | three |
  |    4 | %today-1w | %TX_PENDING  |    400 | .ZZA | .ZZC | four  |
  Then balances:
  | uid  | balance |*
  | .ZZA |       0 |
  | .ZZB |       0 |
  | .ZZC |       0 |

  Scenario: Unpaid invoices get handled
	Given balances:
  | uid  | balance |*
  | .ZZE |     500 |
  When cron runs "invoices"
  Then transactions: 
  | xid | created | amount | from | to   | purpose                         | taking |*
  |   1 | %today  |    100 | .ZZA | .ZZC | one (%PROJECT inv#1)            |        |
  |   2 | %today  |    100 |  256 | .ZZA | transfer to CG,transfer to bank |      1 |
	Then count "txs" is 2
	And count "usd" is 2
	And count "invoices" is 4
	And usd transfers:
  | txid | payee | amount | created | completed |*
  |    1 | .ZZA  |    100 | %today  |    %today |
  |    2 | .ZZA  |    200 | %today  |         0 |
  And invoices:
  | nvid | created   | status       | amount | from | to   | for   | flags   |*
  |    1 | %today    | 1            |    100 | .ZZA | .ZZC | one   | funding |
  |    2 | %today    | %TX_APPROVED |    200 | .ZZA | .ZZC | two   | funding |
  |    3 | %today    | %TX_APPROVED |    300 | .ZZB | .ZZC | three |         |
  |    4 | %today-1w | %TX_PENDING  |    400 | .ZZA | .ZZC | four  |         |
  And we notice "banked|bank tx number|available now" to member ".ZZA" with subs:
  | action    | amount | checkNum | why               |*
  | draw from | $100   |        1 | to pay invoice #1 |
  And we notice "banked|bank tx number" to member ".ZZA" with subs:
  | action    | amount | checkNum | why               |*
  | draw from | $200   |        2 | to pay invoice #2 |
	# checkNum=1 again because the transfers get consolidated
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
  | .ZZA |       0 |
  | .ZZB |       0 |
  | .ZZC |     100 |

  When cron runs "invoices"
  Then usd transfer count is 2
  And usd transfers:
  | txid | payee | amount | created | completed |*
  |    1 | .ZZA  |    100 | %today  |    %today |
  |    2 | .ZZA  |    200 | %today  |         0 |
  When cron runs "getFunds"
	Then usd transfer count is 2
  And usd transfers:
  | txid | payee | amount | created | completed |*
  |    1 | .ZZA  |    100 | %today  |    %today |
  |    2 | .ZZA  |    700 | %today  |         0 |

Scenario: Non-member unpaid invoice does not generate a transfer request
  Given invoices:
  | nvid | created   | status       | amount | from | to   | for   |*
  |    5 | %today    | %TX_APPROVED |    100 | .ZZE | .ZZC | one   |
  Then balances:
  | uid  | balance |*
  | .ZZC |       0 |
  | .ZZE |       0 |
  When cron runs "invoices"
	Then count "txs" is 2
	And count "usd" is 2
	And count "invoices" is 5