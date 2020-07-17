Feature: Set up for integration testing with SMT

Setup:
  Given members:
  | uid  | fullName    | email | cc  | cc2  | floor | phone      | address     | city       | state | zip   | flags             |*
  | .ZZA | John Doe    | a@    | ccA | ccA2 |  -250 | 2345678901 |             |            | MA    |       | ok,ided,confirmed |
  | .ZZB | John Doe Sr | b@    | ccB | ccB2 |  -250 |            | 123 Main St | Greenfield | MA    | 01301 | ok,ided,confirmed |
  | .ZZC | John Doe    | c@    | ccC |      |     0 |            |             |            | MA    |       | ok,ided,confirmed |
  | .ZZD | John Doe Sr | d@    | ccD |      |     0 |            |             |            | MA    |       | ok,ided,confirmed |
  | .ZZE | John Doe    | e@    | ccE |      |     0 |            |             |            | MA    |       | ok,ided,confirmed |
  | .ZZF | John Doe Sr | f@    | ccF |      |     0 |            |             |            | MA    |       | ok,ided,confirmed |
  | .ZZG | John Doe    | g@    | ccG |      |     0 |            |             |            | MA    |       | ok,ided,confirmed |
  | .ZZH | John Doe Sr | h@    | ccH |      |     0 |            |             |            | MA    |       | ok,ided,confirmed |
  | .ZZI | John Doe    | i@    | ccI |      |     0 |            |             |            | MA    |       | ok,ided,confirmed |
  | .ZZJ | John Doe Sr | j@    | ccJ |      |     0 |            |             |            | MA    |       | ok,ided,confirmed |
  | .ZZK | John Doe    | k@    | ccK |      |     0 |            |             |            | MA    |       | ok,ided,confirmed |
  | .ZZL | John Doe Sr | l@    | ccL |      |     0 |            |             |            | MA    |       | ok,ided,confirmed |
  | .ZZS | NYCEC       | s@    | ccS |      |     0 |            |             |            | MA    |       | ok,ided,confirmed |

  And relations:
  | main | agent | flags   |*
  | .ZZA | .ZZS  | autopay |
  | .ZZE | .ZZS  | autopay |
  | .ZZF | .ZZS  | autopay |
  
  And balances:
  | uid  | balance |*
  | .ZZA | 240     |
  | .ZZB | 20      |
  | .ZZC | 200     |
  | .ZZD | 2000    |
  | .ZZE | 200     |
  | .ZZF | 100     |
  | .ZZG | 120     |
  | .ZZH | 240     |
  | .ZZI | 0       |
  | .ZZJ | -30     |
  | .ZZK | 25      |
  | .ZZL | 30      |
  | .ZZS | 20      |
  

Scenario: do the setup
