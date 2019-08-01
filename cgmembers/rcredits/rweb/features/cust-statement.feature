Feature: Customer Statements
AS a member company
I WANT a prinatable report of my invoices and transactions with any specific customer
SO we can keep things straight between us.

Setup:
  Given members:
  | uid  | fullName   | floor | acctType    | flags | created    | address | activated |*
  | .ZZA | Abe One    | -100  | personal    | ok    | %today-15m | 1 A St. | %now-3m   |
  | .ZZB | Bea Two    | -200  | personal    | ok    | %today-15m | 2 B St. | %now-3m   |
  | .ZZC | Corner Pub | -300  | corporation | ok,co | %today-15m | 3 C St. | %now-3m   |
  And relations:
  | main | agent | permission |*
  | .ZZC | .ZZB  | buy        |
  And usd transfers:
  | txid | payee | amount | created   | completed |*
  | 1001 |  .ZZA |   1000 | %today-3m | %today-3m |
  | 1003 |  .ZZC |   3000 | %today-3m | %today-3m |
  And invoices:
  | nvid | created   | amount | from | to   | purpose  | status       |*
  |    1 | %today-3m |    240 | .ZZA | .ZZB | what G   |  5           |
  |    2 | %today-2m |    120 | .ZZA | .ZZC | this Q   | 17           |
  |    3 | %today-1m |     80 | .ZZA | .ZZC | this CF  | 19           |
  |    4 | %today-5d |     90 | .ZZA | .ZZC | wrongly  | %TX_DENIED   |
  |    5 | %today-2d |   2000 | .ZZA | .ZZC | realist  | %TX_APPROVED |
  And transactions: 
  | xid | created   | amount | from | to   | purpose  | payerTid | payeeTid |*
  |  14 | %today-4m |    100 | .ZZC | .ZZA | that F   |       23 |       33 |
  |  15 | %today-2w |     50 | .ZZA | .ZZC | cacao P  |       24 |       34 |
  |  16 | %today-9d |    240 | .ZZA | .ZZC | what G   |       25 |       35 |
  |  17 | %today-8d |    120 | .ZZA | .ZZC | this Q   |       26 |       36 |
  |  18 | %today-4d |    100 | .ZZA | .ZZB | thug V   |       27 |       37 |
  |  19 | %today-3d |     80 | .ZZA | .ZZC | this CF  |       28 |       38 |
  |  20 | %today-1d |    100 | .ZZC | .ZZA | pool CJ  |       29 |       39 |

Scenario: A company looks at a customer statement
  When agent "C:B" views "customer" statement for member ".ZZA"
  Then we show "Corner Pub" with:
  || 3 C St. |
  || Abe One: Account NEWZZA |
  || 1 A St. |
  || STATEMENT |
  And with:
  | Date    |        | Description     | Invoiced | Paid    |  Balance |
# NOTE: Description must be in last position because that's the order it is generated in.
# | Date    |        | Invoiced | Paid    |  Balance | Description     |
  |         |        |          |         |     0.00 | Opening balance |
  | %mdY-4m | tx #14 |          | -100.00 |   100.00 | that F          |
  | %mdY-2m | inv #2 |   120.00 |         |   220.00 | this Q          |
  | %mdY-1m | inv #3 |    80.00 |         |   300.00 | this CF         |
  | %mdY-2w | tx #15 |          |   50.00 |   250.00 | cacao P         |
  | %mdY-9d | tx #16 |          |  240.00 |    10.00 | what G          |
  | %mdY-8d | tx #17 |          |  120.00 |  -110.00 | this Q          |
  | %mdY-3d | tx #19 |          |   80.00 |  -190.00 | this CF         |
  | %mdY-2d | inv #5 | 2,000.00 |         | 1,810.00 | realist         |
  | %mdY-1d | tx #20 |          | -100.00 | 1,910.00 | pool CJ         |
  And with:
  || Total due: $1,910.00 |
