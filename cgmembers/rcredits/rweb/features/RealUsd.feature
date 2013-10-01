Feature: Real USD
AS a member
I WANT my rCredits transaction history to reflect accurately my Dwolla balance
SO I don't lose money or get confused.
# Dwolla's "reflector account" is:
#	Dwolla	812-713-9234
#	Email	reflector@dwolla.com
#	Phone	(406) 699-9999
#	Facebook	dwolla.reflector
#	Twitter	@DwollaReflector

# Assumes real TESTER balance is at least $0.20
# TESTER must have a Dwolla account set up and connected

Setup:
  Given members:
  | id   | fullName   | dw | country | email | flags              |
  | .ZZA | Abe One    |  1 | US      | a@    | dft,ok,person,bona |
  | .ZZB | Bea Two    |  0 | US      | b@    | dft,ok,person,bona |
  And transactions: 
  | xid | created   | type   | amount | from | to   | purpose | taking |
  |   1 | %today-6m | signup |     10 | ctty | .ZZA | signup  | 0      |
  And balances:
  | id   | dw/usd |
  | .ZZA |      5 |
  
Scenario: A mixed rCredits/USD transaction happens
  When member ".ZZA" confirms form "pay" with values:
  | op  | who     | amount | goods | purpose |
  | pay | Bea Two | 10.20  | 1     | labor   |
  Then transactions: 
  | xid | type     | state | amount | r    | from | to   | purpose      | taking |
  |   2 | transfer | done  |  10.20 |   10 | .ZZA | .ZZB | labor        | 0      |
  |   3 | rebate   | done  |    .51 |  .51 | ctty | .ZZA | rebate on #2 | 0      |
  |   4 | bonus    | done  |   1.02 | 1.02 | ctty | .ZZB | bonus on #1  | 0      |
  And usd transfers:
  | payer | payee | amount |
  | .ZZA  |  .ZZB |   0.20 |
  And balances:
  | id   | r    | dw/usd | rewards |
  | .ZZA | 0.51 |   4.80 |   10.51 |
  When member ".ZZA" visits page "transactions/period=365"
  Then we show "Transaction History" with:
  |_Start Date |_End Date |
  | %dmy-12m   | %dmy     |
  And with:
  | Starting | From You | To You | Rewards | Ending  |
  | $0.00    | 10.20    |   0.00 |   10.51 |   $0.31 |
  | PENDING  | 0.00     |   0.00 |    0.00 | + $0.00 |
  And with:
  |_tid | Date | Name    | From you | To you | Status  |_buttons | Purpose | Reward |
  | 2   | %dm  | Bea Two | 10.20    | --     | %chk    | X       | labor   |   0.51 |

Scenario: A member confirms payment with insufficient USD balance
  When member ".ZZA" confirms form "pay" with values:
  | op  | who     | amount | goods | purpose |
  | pay | Bea Two | 15.01  | 1     | labor   |
  Then we say "error": "short to" with subs:
  | short |
  | $0.01 |
  And balances:
  | id   | r  | dw/usd | rewards |
  | .ZZA | 10 |      5 |      10 |
  
Scenario: A member buys something when Dwolla is down
  Given Dwolla is down
  When member ".ZZA" confirms form "pay" with values:
  | op  | who     | amount | goods | purpose |
  | pay | Bea Two | 10.20  | 1     | labor   |
  Then transactions: 
  | xid | type     | state | amount | r    | from | to   | purpose      | taking | usdXid |
  |   2 | transfer | done  |  10.20 |   10 | .ZZA | .ZZB | labor        | 0      |     -1 |
  |   3 | rebate   | done  |    .51 |  .51 | ctty | .ZZA | rebate on #2 | 0      |        |
  |   4 | bonus    | done  |   1.02 | 1.02 | ctty | .ZZB | bonus on #1  | 0      |        |
  And balances:
  | id   | r    | dw/usd | rewards |
  | .ZZA | 0.51 |   4.80 |   10.51 |
  And usd transfer count is 0
  