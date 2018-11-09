Feature: Joint
AS a pair of members with a joint account
WE WANT to transfer money from our bank account to our joint account
SO BOTH OF US can make purchases with those funds.

Setup:
  Given members:
  | uid  | fullName | floor | minimum | flags            | achMin | risks   | jid  |*
  | .ZZA | Abe One  |     0 |     100 | ok,refill,bankOk | 30     | hasBank | .ZZB |
  | .ZZB | Bea Two  |     0 |       0 | ok               | 10     |         | .ZZA |
  And relations:
  | main | agent | permission |*
  | .ZZA | .ZZB  | joint      |
  | .ZZB | .ZZA  | joint      |
  And transactions: 
  | xid | created   | type   | amount | from | to   | purpose |*
  | 1   | %today-6m | signup |    250 | ctty | .ZZA | signup  |
  | 2   | %today-6m | signup |    250 | ctty | .ZZB | signup  |
  Then balances:
  | uid  | balance |*
  | ctty |       0 |
  | .ZZA |       0 |
  | .ZZB |       0 |

Scenario: a joint account needs refilling
  Given balances:
  | uid  | balance |*
  | .ZZA |   50.00 |
  | .ZZB |   49.99 |
  When cron runs "getFunds"
  Then usd transfers:
  | txid | payee | amount |*
  |    1 | .ZZA  |  30    |
  And we notice "banked|bank tx number|available now" to member ".ZZA" with subs:
  | action    | amount | checkNum | why       |*
  | draw from | $30    |        1 | to bring your balance up to the target you set |

Scenario: a joint account does not need refilling
  Given balances:
  | uid  | balance |*
  | .ZZA |   50.01 |
  | .ZZB |   49.99 |
  When cron runs "getFunds"
  Then bank transfer count is 0