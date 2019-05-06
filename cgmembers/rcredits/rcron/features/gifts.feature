Feature: Gifts
AS a member
I WANT my recent requested donation to CGF to go through
SO I can enjoy the rCredit system's rapid growth and be a part of that.

Setup:
  Given members:
  | uid  | fullName   | address | city  | state | zip   | country | postalAddr | flags               | risks   |*
  | .ZZA | Abe One    | 1 A St. | Atown | AK    | 01000 | US      | 1 A, A, AK | ok,confirmed,bankOk | hasBank |
  And balances:
  | uid  | balance | floor |*
  | cgf  |       0 |     0 |
  | .ZZA |     100 |   -20 |

Scenario: A brand new recurring donation can be completed
  Given these "recurs":
  | created    | payer | payee | amount | period |*
  | %yesterday | .ZZA  | cgf   |     10 |      M |
  When cron runs "recurs"
  Then transactions:
  | xid | created | amount | from | to  | purpose                    | flags          |*
  |   1 | %today  |     10 | .ZZA | cgf | regular donation (Monthly) | gift,recurs |
  And we notice "new payment linked" to member "cgf" with subs:
  | otherName | amount | payeePurpose               | aPayLink |*
  | Abe One   | $10    | regular donation (Monthly) | ?        |
  And that "notice" has link results:
  | ~name | Abe One |
  | ~postalAddr | 1 A, A, AK |
  | Physical address: | 1 A St., Atown, AK 01000 |
  | ~footer | %PROJECT |
  And we notice "recur pay" to member ".ZZA" with subs:
  | amount | purpose                    | to       |*
  |    $10 | regular donation (Monthly) | %PROJECT |
  # and many other fields
	And count "txs" is 1
	And count "usd" is 0
	And count "invoices" is 0
	When cron runs "recurs"
	Then count "txs" is 1
	And count "usd" is 0
	And count "invoices" is 0

Scenario: A second recurring donation can be completed
  Given these "recurs":
  | created   | payer | payee | amount | period |*
  | %today-3m | .ZZA  | cgf   |     10 |      M |
  And transactions:
  | xid | created    | amount | from | to  | purpose                            | flags          |*
  |   1 | %today-32d |     10 | .ZZA | cgf | regular donation (Monthly) | gift,recurs |
  When cron runs "recurs"
  Then transactions:
  | xid | created | amount | from | to  | purpose                    | flags          |*
  |   2 | %today  |     10 | .ZZA | cgf | regular donation (monthly) | gift,recurs |
	
Scenario: A donation invoice can be completed
# even if the member has never yet made an rCard purchase
  Given invoices:
  | nvid | created   | status       | amount | from | to  | for      | flags |*
  |    2 | %today    | %TX_APPROVED |     50 | .ZZA | cgf | donation | gift  |
  And member ".ZZA" has no photo ID recorded
  When cron runs "invoices"
  Then transactions: 
  | xid | created | amount | from | to  | purpose                      | flags |*
  |   1 | %today  |     50 | .ZZA | cgf | donation (Common Good inv#2) | gift  |
	And invoices:
  | nvid | created   | status | amount | from | to  | for      | flags |*
  |    2 | %today    | 1      |     50 | .ZZA | cgf | donation | gift  |	
	
Scenario: A recurring donation cannot be completed
  Given these "recurs":
  | created   | payer | payee | amount | period |*
  | %today-3m | .ZZA  | cgf   |    200 |      M |
  When cron runs "recurs"
	Then invoices:
  | nvid | created   | status       | amount | from | to  | for                                | flags          |*
  |    1 | %today    | %TX_APPROVED |    200 | .ZZA | cgf | regular donation (Monthly) | gift,recurs |	
	And count "txs" is 0
	And count "usd" is 0
	And count "invoices" is 1

  When cron runs "invoices"
	Then count "txs" is 0
  And count "usd" is 1
  And count "invoices" is 1
  And	invoices:
  | nvid | created   | status       | amount | from | to  | for                                | flags                  |*
  |    1 | %today    | %TX_APPROVED |    200 | .ZZA | cgf | regular donation (Monthly) | gift,recurs,funding |	

	When cron runs "recurs"
	Then count "txs" is 0
  And count "usd" is 1
  And count "invoices" is 1

Scenario: A non-member chooses a donation
  Given members:
  | uid  | fullName | flags  | risks   | activated | balance |*
  | .ZZD | Dee Four |        | hasBank |         0 |       0 |
  | .ZZE | Eve Five | refill | hasBank | %today-9m |     200 |
  And these "recurs":
  | created   | payer | payee | amount | period |*
  | %today-3y | .ZZD  | cgf   |      1 |      Y |
  | %today-3m | .ZZE  | cgf   |    200 |      M |
  When cron runs "recurs"
	Then count "txs" is 0
	And count "usd" is 0
	And count "invoices" is 0
	
Scenario: It's time to warn about an upcoming annual donation
  Given members:
  | uid  | fullName | flags  | risks   | activated             |*
  | .ZZD | Dee Four | ok     | hasBank | %now-1y               |
  | .ZZE | Eve Five | ok     | hasBank | %(%now-1y+7*DAY_SECS) |
  And these "recurs":
  | created               | payer | payee | amount | period |*
  | %(%now-1y+6*DAY_SECS) | .ZZD  | cgf   |      1 |      Y |
	And transactions:
  | xid | created               | amount | from | to  | purpose                    | flags          |*
  |   1 | %(%now-1y+6*DAY_SECS) |     10 | .ZZD | cgf | regular donation (Monthly) | gift,recurs |
  When cron runs "tickle"
	Then we email "annual-gift" to member "d@example.com" with subs:
	| amount | when    | aDonate |*
	|     $1 | %mdY+7d |       ? |
	And we email "annual-gift" to member "e@example.com" with subs:
	| amount | when    | aDonate |*
	|     $0 | %mdY+7d |       ? |	