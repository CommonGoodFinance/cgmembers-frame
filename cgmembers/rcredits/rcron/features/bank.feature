Feature: Bank
AS a member
I WANT credit to flow from my bank account
SO I can spend it with my rCard.

Setup:
  Given members:
  | uid  | fullName | floor | minimum | flags               | achMin | risks   |*
  | .ZZA | Abe One  |     0 |     100 | co,ok,refill,bankOk | 30     | hasBank |
  | .ZZB | Bea Two  |   -50 |     100 | ok,refill           | 30     |         |
  | .ZZC | Our Pub  |   -50 |     100 | ok,co               | 50     | hasBank |
  And relations:
  | main | agent | draw |*
  |.ZZA | .ZZB  | 1    |
  
Scenario: a member is barely below target
  Given balances:
  | uid  | rewards | savingsAdd | balance |*
  | .ZZA |      20 |          0 | 99.99   |
  When cron runs "getFunds"
  Then usd transfers:
  | txid | payee | amount | channel  |*
  |    1 | .ZZA  |     30 | %TX_CRON |
  Then bank transfer count is 1
  And we notice "banked|bank tx number|available now" to member ".ZZA" with subs:
  | action    | amount | checkNum | why       |*
  | draw from | $30    |        1 | to bring your balance up to the target you set |

Scenario: a member has a negative balance
  Given balances:
  | uid  | rewards | savingsAdd | balance |*
  | .ZZA |      20 |          0 | -50     |
  When cron runs "getFunds"
  Then usd transfers:
  | txid | payee | amount | channel  |*
  |    1 | .ZZA  |  150   | %TX_CRON |
  And we notice "banked|bank tx number" to member ".ZZA" with subs:
  | action    | amount | checkNum | why       |*
  | draw from | $150   |        1 | to bring your balance up to the target you set |

Scenario: an unbanked member barely below target draws on another account
  Given balances:
  | uid  | balance |*
  | .ZZA | 200   |
  | .ZZB | 99.99 |
  When cron runs "getFunds"
  Then transactions:
  | xid | type     | amount | from | to   | goods         | taking | purpose      |*
  |   1 | transfer |   0.01 | .ZZA | .ZZB | %FOR_NONGOODS |      1 | automatic transfer to NEWZZB,automatic transfer from NEWZZA |
  And we notice "drew" to member ".ZZB" with subs:
  | amount | why       |*
  | $0.01  | to bring your balance up to the target you set |
  
Scenario: an unbanked member barely below target cannot draw on another account
  Given balances:
  | uid  | balance |*
  | .ZZA | 0      |
  | .ZZB | 99.99  |
  When cron runs "getFunds"
  Then we notice "cannot draw" to member ".ZZB" with subs:
	| why       |*
	| to bring your balance up to the target you set |

Scenario: a member is at target
  Given balances:
  | uid  | rewards | savingsAdd | balance |*
  | .ZZA |      20 |          0 |     100 |
  When cron runs "getFunds"
  Then bank transfer count is 0
  
Scenario: a member is well below target
  Given balances:
  | uid  | rewards | savingsAdd | balance | minimum |*
  | .ZZA |      25 |          0 |      50 |     151 |
  When cron runs "getFunds"
  Then usd transfers:
  | txid | payee | amount              | channel  |*
  |    1 | .ZZA  | %(100 + %R_ACHMIN) | %TX_CRON |
  And we notice "banked|bank tx number" to member ".ZZA" with subs:
  | action    | amount              | checkNum | why       |*
  | draw from | $%(100 + %R_ACHMIN) |        1 | to bring your balance up to the target you set |

Scenario: a member is under target but already requested barely enough funds from the bank
  Given balances:
  | uid  | rewards | savingsAdd | balance |*
  | .ZZA |      20 |          0 |      20 |
  | .ZZB |      20 |          0 |     100 |
  When cron runs "getFunds"
  Then usd transfers:
  | payee | amount | channel  |*
  | .ZZA  |     80 | %TX_CRON |
  When cron runs "getFunds"
# (again)  
  Then bank transfer count is 1
  
Scenario: a member is under target and has requested insufficient funds from the bank
# This works only if member requests more than R_USDTX_QUICK the first time (hence ZZD, whose target is 300)
  Given members:
  | uid  | fullName | floor | minimum | flags            | achMin | risks   |*
  | .ZZD | Dee Four |   -50 |     300 | ok,refill,bankOk | 30     | hasBank |
  And balances:
  | uid  | rewards | savingsAdd | balance |*
  | .ZZD |      20 |          0 |      20 |
  When cron runs "getFunds"
  Then usd transfers:
  | payee | amount | deposit |*
  | .ZZD  |    280 |       0 |
  Given balances:
  | uid  | rewards | savingsAdd | balance |*
  | .ZZD |      20 |          0 |   19.99 |
  When cron runs "getFunds"
  Then usd transfers:
  | payee | amount |*
  | .ZZD  | %(280+R_ACHMIN) |

Scenario: a member member with zero target has balance below target
  Given balances:
  | uid  | minimum | balance |*
  | .ZZA |       0 | -10     |
  When cron runs "getFunds"
  Then usd transfers:
  | payee | amount |*
  | .ZZA  |     30 |
  
Scenario: an unbanked member with zero target has balance below target
  Given balances:
  | uid  | minimum | balance |*
  | .ZZA |       0 |   0 |
  | .ZZB |       0 | -10 |
  When cron runs "getFunds"
  Then bank transfer count is 0

Scenario: a member has a deposited but not completed transfer
  Given balances:
  | uid  | balance |*
  | .ZZA |  80 |
  | .ZZB | 100 |
  And usd transfers:
  | txid | payee | amount | created   | completed | deposit    |*
  | 5001 | .ZZA  |     50 | %today-4d |         0 | %(%today-%R_USDTX_DAYS*%DAY_SECS-9) |
  # -9 in case the test takes a while (elapsed time is slightly more than R_USDTX_DAYS days)
  When cron runs "getFunds"
  Then bank transfer count is 1

Scenario: an account has a target but no refills
  Given members have:
  | uid  | flags     |*
  | .ZZB | ok,bankOk |
  And balances:
  | uid  | rewards | balance |*
  | .ZZA |       0 |     100 |
  | .ZZB |      20 |     -50 |
  When cron runs "getFunds"
  Then bank transfer count is 0

Scenario: a non-member has a target and refills
  Given members:
  | uid  | fullName | floor | minimum | flags         | achMin | risks   |*
  | .ZZE | Eve Five |     0 |     100 | refill,bankOk | 30     | hasBank |
	When cron runs "getFunds"
  Then usd transfers:
  | txid | payee | amount | channel  |*
  |    1 | .ZZA  |    100 | %TX_CRON |
	And count "txs" is 0
	And count "usd" is 1
	And count "invoices" is 0
	
Scenario: member's bank account has not been verified
  Given members have:
  | uid  | balance | flags     |*
  | .ZZA |      10 | ok,refill |
  When cron runs "getFunds"
  Then usd transfers:
  | txid | payee | amount | created           | completed | deposit |*
  |    1 | .ZZA  |      0 | %today            |         0 |       0 |
	|    2 | .ZZA  |     90 | %(%NOW+%DAY_SECS) |         0 |       0 |

Scenario: a member's bank account gets verified
  Given members have:
  | uid  | balance | flags     |*
  | .ZZA |       0 | ok,refill |
  And usd transfers:
  | txid | payee | amount | created   | completed | deposit   |*
  |    1 | .ZZA  |      0 | %today-2d |         0 | %today-1d |
	When cron runs "everyDay"
  Then count "usd" is 0
	And members have:
  | uid  | balance | flags            |*
  | .ZZA |       0 | ok,refill,bankOk |
	