Feature: Relations
AS a member
I WANT to manage my account's relations with other rCredits accounts
SO I can buy and sell stuff on behalf of other accounts, and they on mine.

Setup:
  Given members:
  | id      | full_name  | account_type  | flags         |
  | NEW.ZZA | Abe One    | %R_PERSONAL   | %BIT_DEFAULTS |
  | NEW.ZZB | Bea Two    | %R_PERSONAL   | %BIT_PARTNER  |
  | NEW.ZZC | Corner Pub | %R_COMMERCIAL | %BIT_RTRADER  |

  And relations:
  | id      | main    | agent   | permission        |
  | NEW:ZZA | NEW.ZZA | NEW.ZZB | buy and sell      |
  | NEW:ZZB | NEW.ZZB | NEW.ZZA | read transactions |
  | NEW:ZZC | NEW.ZZC | NEW.ZZB | buy and sell      |
  | NEW:ZZD | NEW.ZZC | NEW.ZZA | sell              |
  And transactions: 
  | tx_id    | created   | type       | amount | from      | to      | purpose | taking |
  | NEW.AAAB | %today-6m | %TX_SIGNUP |    250 | community | NEW.ZZA | signup  | 0      |
  | NEW.AAAC | %today-6m | %TX_SIGNUP |    250 | community | NEW.ZZB | signup  | 0      |
  | NEW.AAAD | %today-6m | %TX_SIGNUP |    250 | community | NEW.ZZC | signup  | 0      |
  Then balances:
  | id        | balance |
  | community |    -750 |
  | NEW.ZZA   |     250 |
  | NEW.ZZB   |     250 |
  | NEW.ZZC   |     250 |

Scenariot: A member looks at transactions for the past year
  When member "NEW.ZZA" visits page "txs" with options "period=365"
  Then we show page "txs" with:
  
  Then we show "confirm charge" with subs:
  | amount | other_name |
  | $100   | Bea Two    |
