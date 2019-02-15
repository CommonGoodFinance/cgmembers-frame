Feature: Statements
AS a member
I WANT a prinatable report of my transactions for the month
SO I have a formal record of them.

Setup:
  Given members:
  | uid  | fullName   | floor | acctType    | flags | created    |*
  | .ZZA | Abe One    | -100  | personal    | ok    | %today-15m |
  | .ZZB | Bea Two    | -200  | personal    | ok,co | %today-15m |
  | .ZZC | Corner Pub | -300  | corporation | ok,co | %today-15m |
  And members have:
  | uid  | fullName |*
  | ctty | ZZrCred  |
  And relations:
  | main | agent | permission |*
  | .ZZA | .ZZB  | buy        |
  | .ZZB | .ZZA  | read       |
  | .ZZC | .ZZB  | buy        |
  | .ZZC | .ZZA  | sell       |
  And usd transfers:
  | txid | payee | amount | created   | completed |*
  | 1001 |  .ZZA |   1000 | %today-3m | %today-3m |
  | 1002 |  .ZZB |   2000 | %today-3m | %today-3m |
  | 1003 |  .ZZC |   3000 | %today-3m | %today-3m |
  | 1004 |  .ZZA |     11 | %lastm+5d | %lastm+5d |
  | 1005 |  .ZZA |    -22 | %lastm+8d | %lastm+8d |
  | 1006 |  .ZZA |    -33 | %lastm+9d | %lastm+9d |
  Then balances:
  | uid  | balance |*
  | .ZZA |     956 |
  | .ZZB |    2000 |
  | .ZZC |    3000 |
  Given transactions: 
  | xid| created   | type     | amount | from | to   | purpose | taking |*
  | 4  | %lastm+3d | transfer |     10 | .ZZB | .ZZA | cash E  | 0      |
  | 5  | %lastm+4d | transfer |   1100 | .ZZC | .ZZA | usd F   | 1      |
  | 6  | %lastm+5d | transfer |    240 | .ZZA | .ZZB | what G  | 0      |

  | 9  | %lastm+6d | transfer |     50 | .ZZB | .ZZC | cash P  | 0      |
  | 10 | %lastm+7d | transfer |    120 | .ZZA | .ZZC | this Q  | 1      |

  | 13 | %lastm+8d | transfer |    100 | .ZZA | .ZZB | cash V  | 0      |
  Then balances:
  | uid  | balance |*
  | .ZZA |    1606 |
  | .ZZB |    2280 |
  | .ZZC |    2070 |

Scenario: A member looks at a statement for previous month
  When member ".ZZA" views statement for %lastmy
  Then we show "ZZA" with:
  | Starting | From Bank | Paid   | Received | Ending   |
  | 1,000.00 | -44.00    | 460.00 | 1,110.00 | 1,606.00 |
#   |     0.00 |           |        |        | 268.00  |   268.00 |
  And with:
  | Tx   | Date       | Name       | Purpose  | Amount  |
#  | 1    | %lastmd+1d | ZZrCred    | signup  |     0.00 |
  | 1    | %lastmd+3d | Bea Two    | cash E  |    10.00 |
  | 2    | %lastmd+4d | Corner Pub | usd F   | 1,100.00 |
  | 3    | %lastmd+5d | Bea Two    | what G  |  -240.00 |
  | 1004 | %lastmd+5d | --         | from bank |  11.00 |
  | 4    | %lastmd+7d | Corner Pub | this Q  |  -120.00 |
  | 5    | %lastmd+8d | Bea Two    | cash V  |  -100.00 |
  | 1005 | %lastmd+8d | --         | to bank |   -22.00 |
  | 1006 | %lastmd+9d | --         | to bank |   -33.00 |
  And without:
  | rebate  |
  | bonus   |
