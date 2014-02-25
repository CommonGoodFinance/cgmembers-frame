Feature: Gifts
AS a member
I WANT my recent requested contribution to CGF to go through
SO I can enjoy the rCredit system's rapid growth and be a part of that.

Setup:
  Given members:
  | id   | fullName   | address | city  | state  | postalCode | country | email         | flags           |
  | .ZZA | Abe One    | 1 A St. | Atown | Alaska | 01000      | US      | a@ | dft,ok,person    |
  And balances:
  | id   | usd  | r   | rewards |
  | cgf  |    0 |   0 |       0 |
  | .ZZA |  100 |  20 |      20 |

Scenario: A contribution can be completed
  Given gifts:
  | id   | giftDate   | amount | often | honor  | honored | share | completed |
  | .ZZA | %yesterday |     10 |     1 | memory | Jane Do |    10 |         0 |
  And next DO code is "whatever"
  When cron runs "gifts"
  Then transactions:
  | xid   | created | type     | state | amount | from      | to      | purpose      |
  | .AAAB | %today  | transfer | done  |     10 | .ZZA      | cgf     | contribution |
  | .AAAC | %today  | rebate   | done  |   0.50 | community | .ZZA    | rebate on #1 |
  | .AAAD | %today  | bonus    | done  |   1.00 | community | cgf     | bonus on #1  |
  And gifts:
  | id   | giftDate   | amount | often | honor  | honored | share | completed |
  | .ZZA | %yesterday |     10 |     1 | memory | Jane Do |    10 | %today    |
  And we notice "new payment|reward other" to member "cgf" with subs:
  | otherName  | amount | payeePurpose | otherRewardType | otherRewardAmount |
  | <a href=''do/id=1&code=whatever''>Abe One</a> | $10 | contribution | reward | $1 |
  And we notice "gift sent" to member ".ZZA" with subs:
  | amount | rewardAmount |
  |    $10 |        $0.50 |
  And we tell staff "gift accepted" with subs:
  | amount | myName  | often | rewardType | 
  |     10 | Abe One |     1 | reward     |
  # and many other fields

Scenario: A recurring contribution can be completed
  Given gifts:
  | id   | giftDate   | amount | often | honor  | honored | share | completed |
  | .ZZA | %yesterday |     10 |     Q | memory | Jane Do |    10 |         0 |
  And next DO code is "whatever"
  When cron runs "gifts"
  Then transactions:
  | xid   | created | type     | state | amount | from      | to      | purpose      |
  | .AAAB | %today  | transfer | done  |     10 | .ZZA      | cgf     | contribution (recurs Quarterly) |
  | .AAAC | %today  | rebate   | done  |   0.50 | community | .ZZA    | rebate on #1 |
  | .AAAD | %today  | bonus    | done  |   1.00 | community | cgf     | bonus on #1  |
  And gifts:
  | id   | giftDate      | amount | often | honor  | honored | completed |
  | .ZZA | %yesterday    |     10 |     Q | memory | Jane Do | %today    |
  | .ZZA | %yesterday+3m |     10 |     Q |        |         |         0 |
  And we notice "new payment|reward other" to member "cgf" with subs:
  | otherName | amount | payeePurpose | otherRewardType | otherRewardAmount |
  | <a href=''do/id=1&code=whatever''>Abe One</a> | $10 | contribution (recurs Quarterly) | reward | $1 |
  And we tell staff "gift accepted" with subs:
  | amount | myName  | often | rewardType |
  |     10 | Abe One |     Q | reward     |
  # and many other fields
