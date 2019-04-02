Feature: Gifts
AS a member
I WANT to make recurring payments
SO I can save on memory and labor.

Setup:
  Given members:
  | uid  | fullName | address | city  | state | zip   | country | postalAddr | flags               | risks   | floor |*
  | .ZZA | Abe One  | 1 A St. | Atown | AK    | 01000 | US      | 1 A, A, AK | ok,confirmed,bankOk | hasBank |   -20 |
  | .ZZC | Cor Pub  | 3 C St. | Ctown | CT    | 03000 | US      | 3 C, C, CT | ok,co,confirmed     |         |     0 |
  And transactions:
  | xid | created    | amount | from | to   | purpose | flags  |*
  |   1 | %yesterday |    100 | ctty | .ZZA | random  |        |
  Then balances:
  | uid  | balance | floor |*
  | cgf  |       0 |     0 |
  | .ZZA |     100 |   -20 |

Scenario: A recurring donation happened yesterday
  Given these "recurs":
  | created    | payer | payee | amount | period |*
  | %yesterday | .ZZA  | .ZZC  |     10 |      M |
  And transactions:
  | xid | created    | amount | from | to   | purpose         | flags  |*
  |   2 | %yesterday |     10 | .ZZA | .ZZC | monthly payment | recurs |
  When cron runs "recurs"
  Then count "tx_hdrs" is 2
  
Scenario: A recurring donation happened long enough ago to repeat
  Given these "recurs":
  | created    | payer | payee | amount | period |*
  | %today-35d | .ZZA  | .ZZC  |     10 |      M |
  And transactions:
  | xid | created    | amount | from | to   | purpose         | flags  |*
  |   2 | %today-35d |     10 | .ZZA | .ZZC | monthly payment | recurs |
  When cron runs "recurs"
  Then count "tx_hdrs" is 3
  And transactions:
  | xid | created | amount | from | to   | purpose         | flags  |*
  |   3 | %today  |     10 | .ZZA | .ZZC | monthly payment | recurs |
