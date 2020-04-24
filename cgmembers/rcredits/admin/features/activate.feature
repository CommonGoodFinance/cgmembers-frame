Feature: Activate
AS a regional administrator
I WANT to activate (or deactivate) a Common Good account
SO the new member can participate (or stop participating)

Setup:
  Given members:
  | uid  | fullName | address | city | state | zip | email | flags                   | minimum | federalId | dob      |*
  | .ZZA | Abe One  | 1 A St. | Aton | MA    | 01000      | a@    | ok,admin         |     100 | 111111111 | %now-30y |
  | .ZZB | Bea Two  | 2 B St. | Bton | MA    | 02000      | b@    | ok               |     200 | 222222222 | %now-30y |
  | .ZZD | Dee Four | 4 D St. | Dton | MA    | 04000      | d@    | member,confirmed |     400 | 444444444 | %now-19y |
  And relations:
  | main | agent | num | permission |*
  | .ZZD | .ZZA  |   1 | manage     |
# relationship is here only so we can identify which account admin is managing

Scenario: Admin activates an account
  Given member ".ZZD" has no photo ID recorded
  When member "D:A" completes form "summary" with values:
  | mediaConx | active | helper  | federalId  | adminable        | tickle | dob      |*
  |         1 |      1 | Bea Two | %R_ON_FILE | member,confirmed |        | %mdy-19y |
  Then members:
  | uid  | flags                        | helper |*
  | .ZZD | member,confirmed,ok,underage |   .ZZB |
  And we message "approved|suggest completion" to member ".ZZD" with subs:
  | youName  | inviterName | otherName |*
  | Dee Four | Bea Two     |           |
  
Scenario: Admin activates an account unconfirmed
  Given member ".ZZD" has no photo ID recorded
  And members have:
  | uid  | flags  |*
  | .ZZD | member |
  When member "D:A" completes form "summary" with values:
  | mediaConx | active | helper | federalId  | adminable | tickle | dob      |*
  |         1 |      1 |      1 | %R_ON_FILE | member    |        | %mdy-19y |
  Then members:
  | uid  | flags              | helper |*
  | .ZZD | member,ok,underage |      1 |
  And we message "approved|must confirm uninvited|suggest completion" to member ".ZZD" with subs:
  | youName  | inviterName          | otherName |*
  | Dee Four | System Administrator |           |

Scenario: Admin deactivates an account
  Given members have:
  | uid  | flags          | activated |*
  | .ZZB | ok,member,ided | %now-3m   |
  # (tests add the ided bit by default when creating an active account)
  When member "B:A" completes form "summary" with values:
  | active | federalId  | adminable | tickle |*
  |        | %R_ON_FILE | member    |        |
  Then members:
  | uid  | flags       | activated |*
  | .ZZB | member,ided | %now-3m   |