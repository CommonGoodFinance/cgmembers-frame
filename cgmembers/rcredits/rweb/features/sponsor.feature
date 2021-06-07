Feature: Sponsor
AS a community-spirited not-for-profit organization or project without 501c3 status
I WANT to accept tax-deductible donations
SO I/we can fund our operations with grants and donations from people who need the deduction

Setup:
  Given members:
  | uid  | fullName | flags   |*
  | .ZZA | Abe One  | ok,confirmed      |
  | .ZZB | Bea Two  | ok,confirmed      |
  | .ZZC | Cor Pub  | ok,confirmed,co   |
  And relations:
  | main | other | permission |*
  | .ZZC | .ZZA  | read       |
  | .ZZC | .ZZB  | manage     |

Scenario: A non-member applies for fiscal sponsorship
  When member "?" visits "co/sponsor"
  Then we show "Fiscal Sponsorship" with:
  | Your Name     |
  | Organization  |
  | Org Phone     |
  | Org Email     |
  | Country       |
  | Postal Code   |
  | Referred By   |
  | Mission       |
  | Activities    |
  | Annual Income |
  | Employees     |
  | Checks In     |
  | Checks Out    |
  | Comments      |
  | Submit        |
  
  When member "?" submits "co/sponsor" with:
  | contact    | Jane Dough |**
  | fullName   | Bread Co   |
  | phone      | 413-987-6543 |
  | email      | jd@example.com |
  | country    | US |
  | zip        | 01301 |
  | source     | news |
  | mission    | thrive |
  | activities | do stuff |
  | gross      | 123456.78 |
  | employees  | 9 |
  | checksIn   | 30 |
  | checksOut  | 40 |
  | comments   | cool! |
  Then we say "status": "got application|meanwhile join"
  And we tell admin "Fiscal Sponsorship Application" with subs:
  | contact    | Jane Dough |
  | fullName   | Bread Co   |
  # etc
  And members:
  | uid        | .AAA |**
  | contact    | Jane Dough |
  | fullName   | %PROJECT FBO Bread Co   |
  | legalName  | %CGF_LEGALNAME |
  | federalId  | %CGF_EIN |
  | flags      | co nonudge |
  | coFlags    |  |
  | phone      | 413-987-6543 |
  | email      | jd@example.com |
  | country    | US |
  | zip        | 01301 |
  | source     | news |
  | mission    | thrive |
  | activities | do stuff |
  | gross      | 123456.78 |
  | employees  | 9 |
  | checksIn   | 30 |
  | checksOut  | 40 |

Scenario: A signed-in individual member applies for fiscal sponsorship
  When member ".ZZA" visits "co/sponsor"
  Then we show "Fiscal Sponsorship" with:
  | Your Name     |
  | Organization  |
  | Org Phone     |
  | Org Email     |
  | Country       |
  | Postal Code   |
  | Referred By   |
  | Mission       |
  | Activities    |
  | Annual Income |
  | Employees     |
  | Checks In     |
  | Checks Out    |
  | Comments      |
  | Submit        |

  When member ".ZZA" submits "co/sponsor" with:
  | contact    | Jane Dough |**
  | fullName   | Bread Co   |
  | phone      | 413-987-6543 |
  | email      | jd@example.com |
  | country    | US |
  | zip        | 01301 |
  | source     | news |
  | mission    | thrive |
  | activities | do stuff |
  | gross      | 123456.78 |
  | employees  | 9 |
  | checksIn   | 30 |
  | checksOut  | 40 |
  | comments   | cool! |
  Then we say "status": "got application|meanwhile join"
  And we tell admin "Fiscal Sponsorship Application" with subs:
  | contact    | Jane Dough |
  | fullName   | Bread Co   |
  # etc
  And members:
  | uid        | .AAA |**
  | contact    | Jane Dough |
  | fullName   | %PROJECT FBO Bread Co   |
  | legalName  | %CGF_LEGALNAME |
  | federalId  | %CGF_EIN |
  | flags      | co nonudge |
  | coFlags    |  |
  | phone      | 413-987-6543 |
  | email      | jd@example.com |
  | country    | US |
  | zip        | 01301 |
  | source     | news |
  | mission    | thrive |
  | activities | do stuff |
  | gross      | 123456.78 |
  | employees  | 9 |
  | checksIn   | 30 |
  | checksOut  | 40 |

Scenario: A signed-in company applies for fiscal sponsorship without manage permission
  When member "C:A" visits "co/sponsor"
  Then we say "error": "no sponsor perm"

Scenario: A signed-in company applies for fiscal sponsorship
  Given members have:
  | uid | .ZZC |**
  | phone      | 413-987-6543 |
  | email      | c@ |
  | country    | US |
  | zip        | 01301 |
  | source     | news |
  | gross      | 123456.78 |
  | employees  | 9 |
  
  When member "C:B" visits "co/sponsor"
  Then we show "Fiscal Sponsorship" with:
  | Mission       | |
  | Activities    | |
  | Annual Income | 123456.78 |
  | Employees     | 9 |
  | Checks In     | |
  | Checks Out    | |
  | Comments      | |
  | Submit        | |
  And without:
  | Your Name     |
  | Organization  |
  | Org Phone     |
  | Org Email     |
  | Country       |
  | Postal Code   |
  | Referred By   |
  
  When member "C:B" submits "co/sponsor" with:
  | mission    | thrive |**
  | activities | do stuff |
  | gross      | 123456.78 |
  | employees  | 9 |
  | checksIn   | 30 |
  | checksOut  | 40 |
  | comments   | cool! |
  Then we say "status": "got application|meanwhile join"
  And we tell admin "Fiscal Sponsorship Application" with subs:
  | contact    | Bea Two |
  | fullName   | Cor Pub |
  # etc
  And members:
  | uid        | .AAA |**
  | contact    | Bea Two |
  | fullName   | %PROJECT FBO Cor Pub |
  | legalName  | %CGF_LEGALNAME |
  | federalId  | %CGF_EIN |
  | flags      | co nonudge |
  | coFlags    |  |
  | phone      | 413-987-6543 |
  | email      | c@ |
  | country    | US |
  | zip        | 01301 |
  | source     | news |
  | mission    | thrive |
  | activities | do stuff |
  | gross      | 123456.78 |
  | employees  | 9 |
  | checksIn   | 30 |
  | checksOut  | 40 |

Scenario: A fiscally sponsored applicant updates its settings
  Given members:
  | uid        | .ZZF |**
  | contact    | Bea Two |
  | fullName   | %PROJECT FBO Far Co   |
  | legalName  | %CGF_LEGALNAME |
  | federalId  | %CGF_EIN |
  | flags      | co,ok |
  | coFlags    |  |
  | phone      | 413-987-6543 |
  | email      | f@ |
  | country    | US |
  | zip        | 01301 |
  | source     | news |
  | mission    | thrive |
  | activities | do stuff |
  | gross      | 123456.78 |
  | employees  | 9 |
  | checksIn   | 30 |
  | checksOut  | 40 |
  And relations:
  | main | other | permission |*
  | .ZZF | .ZZB  | manage     |
  When member "F:B" visits "co/sponsor"
  Then we show "Fiscal Sponsorship" with:
  | Mission       | thrive  |
  | Activities    | do stuff |
  | Checks In     | 30        |
  | Checks Out    | 40        |
  | Update        |           |
  And without:
  | Your Name     |
  | Organization  |
  | Org Phone     |
  | Org Email     |
  | Country       |
  | Postal Code   |
  | Referred By   |
  | Annual Income |
  | Employees     |
  | Comments      |

  When member "F:B" submits "co/sponsor" with:
  | mission    | thrive more |**
  | activities | do more |
  | checksIn   | 35 |
  | checksOut  | 45 |
  Then we say "status": "info saved"
  And members:
  | uid        | .ZZF |**
  | contact    | Bea Two |
  | fullName   | %PROJECT FBO Far Co |
  | legalName  | %CGF_LEGALNAME |
  | federalId  | %CGF_EIN |
  | flags      | co,member,ok,ided |
  | coFlags    |  |
  | phone      | 413-987-6543 |
  | email      | f@ |
  | country    | US |
  | zip        | 01301 |
  | source     | news |
  | mission    | thrive more |
  | activities | do more |
  | gross      | 123456.78 |
  | employees  | 9 |
  | checksIn   | 35 |
  | checksOut  | 45 |
