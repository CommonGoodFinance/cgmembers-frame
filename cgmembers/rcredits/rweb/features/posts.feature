Feature: Post
AS a person
I WANT to exchange free help with my neighbors
SO we can all thrive together.

Setup:

Scenario: Someone visits the posts page
  When someone visits "community/posts"
  Then we show "Mutual Aid Offers & Needs" with:
  | Where  |    |    |
  | Radius | 10 | Go |
  And without:
  | Post a   |

Scenario: Someone submits a locus
  When someone confirms "community/posts" with:
  | locus          | radius | latitude | longitude |*
  | Greenfield, MA | 10     | 0        | 0         |
  Then we show "Mutual Aid Offers & Needs" with:
  | Offers   | Needs | Post an Offer | Post a Need |
  And with:
  | Item | Details | |
  And with:
  | There are not yet any offers within |
  | There are not yet any needs within  |
  And cookie "locus" is "Greenfield, MA"
  And cookie "radius" is "10"
  And cookie "latitude" is "42.3791167"
  And cookie "longitude" is "-73.2819463"
  And cookie "zip" is "01301"

Scenario: Someone posts an offer
  When someone visits "community/posts/op=offer"
  Then we show "Post an Offer" with:
  | Category |
  | What |
  | Details |
  | Emergency |
  | Radius |
  | End |
  | Your Email |
  
  When someone confirms "community/posts/op=offer" with:
  | cat  | item | details | emergency | radius | end     | email |*
  | food | fish | big one | 1         | 3      | %mdY+3d | a@b.c |
  Then we show "Your Information" with:
  | Display Name |
  | Name |
  | Street Address |
  | City |
  | State |
  | Postal Code |
  | Phone |
  | Preferred Contact |
  And cookie "radius" is "3"
  And cookie "email" is "a@b.c"
  
Scenario: Someone enters personal data after posting an offer
  When someone confirms "community/posts/op=who&cat=1&item=fish&details=big one&emergency=1&radius=3&end=%now+3d&email=a@b.c&type=offer&exchange=0" with:
  | displayName | Abe |**
  | fullName    | Abe One |
  | address     | 1 A St. |
  | city        | Aville |
  | state       | MA |
  | zip         | 01001 |
  | phone       | 413-253-0001 |
  | method      | text |
  | days        | 2 |
  | washes      | 3 |
  | health      | 2 |
  Then these "posts":
  | postid | type  | item | details | cat  | exchange | emergency | radius | pid | created | end     |* 
  | 1      | offer | fish | big one | food | 0        | 1         | 3      | 1   | %today  | %now+3d |
  And these "people":
  | pid | displayName | fullName | address | city | state | zip   | phone        | email | method | confirmed | health |*
  | 1   | Abe         | Abe One  | 1 A St. | Aville | MA  | 01001 | +14132530001 | a@b.c | text   | 0         | 2 3 ok |
  And we email "confirm-post" to member "a@b.c" with subs:
  | fullName | item | date | thing | code | noFrame |*
  | Abe One  | fish | %mdY | post  |    ? |       1 |
  And we say "status": "confirm by email" with subs:
  | thing | post |**

Scenario: Someone confirms an offer once, twice
  Given these "posts":
  | postid | type  | item | details | cat  | exchange | emergency | radius | pid | created | end     |* 
  | 1      | offer | fish | big one | food | 0        | 1         | 3      | 1   | %today  | %now+3d |
  And these "people":
  | pid | displayName | fullName | address | city | state | zip   | phone        | email | method | confirmed |*
  | 1   | Abe         | Abe One  | 1 A St. | Aville | MA  | 01001 | +14132530001 | a@b.c | text   | 0         |
  When someone visits "community/posts/op=confirm&thing=post&code=%code" where code is:
  | postid | created |*
  | 1      | %today  |
  Then these "people":
  | pid | confirmed |*
  | 1   | 1         |
  And we say "status": "post success"
  
  When someone visits "community/posts/op=confirm&thing=post&code=%code" where code is:
  | postid | created |*
  | 1      | %today  |
  Then we redirect to "community/posts/op=show&postid=1"
  And we show "Edit Post" with:
  | Category:  | food |
  | Who:       | Abe |
  | Posted:    | %mdY |
  | What:      | fish |
  | Details:   | big one |
  |            | Max 500 characters |
  | Emergency: | |
  | Radius:    | 10 miles |
  | End Date:  | %mdY+3d |
  | Update     | |

  When someone confirms "community/posts/op=show&postid=1" with:
  | cat   | item   | details | emergency | radius | end     |*
  | rides | Boston | ASAP    | 1         | 5      | %mdY+5d |
  Then these "posts":
  | postid | type  | cat   | item | details | exchange | emergency | radius | pid | created | end          |* 
  | 1      | offer | rides | Boston | ASAP  | 0        | 1         | 5      | 1   | %now    | %daystart+5d |
  And we show "Mutual Aid Offers & Needs" with:
  | Offers   | Needs | Post an Offer | Post a Need |
  And we say "status": "info saved"

Scenario: Someone views the details of an offer
  Given these "posts":
  | postid | type  | item | details | cat  | exchange | emergency | radius | pid | created | end     |* 
  | 1      | offer | fish | big one | food | 0        | 1         | 3      | 1   | %now    | %now+3d |
  And these "people":
  | pid         | 1 |**
  | displayName | Abe |
  | fullName    | Abe One |
  | address     | 1 A St. |
  | city        | Aville |
  | state       | MA |
  | zip         | 01001 |
  | phone       | +14132530001 |
  | email       | a@b.c |
  | method      | text |
  | confirmed   | 1 |
  | latitude    | 42.5 |
  | longitude   | -72.8 |
  When someone visits "community/posts/op=show&postid=1"
  Then we show "Details" with:
  | Type            | offer |
  | Category        | food |
  | Who             | Abe |
  | Offer           | (In emergency) fish |
  | Details         | big one |
  | Message to Send | Max 200 characters |
  | Your Email      | |
  
Scenario: Someone replies to an offer
  Given these "posts":
  | postid | type  | item | details | cat  | exchange | emergency | radius | pid | created | end     |* 
  | 1      | offer | fish | big one | food | 0        | 1         | 26     | 1   | %now    | %now+3d |
  And these "people":
  | pid         | 1 |**
  | displayName | Abe |
  | fullName    | Abe One |
  | address     | 1 A St. |
  | city        | Aville |
  | state       | MA |
  | zip         | 01330 |
  | phone       | +14132530001 |
  | email       | a@b.c |
  | method      | text |
  | confirmed   | 1 |
  | latitude    | 42.5 |
  | longitude   | -72.8 |
  And cookie "locus" is "Greenfield, MA"
  And cookie "radius" is "100"
  And cookie "latitude" is "42.3791167"
  And cookie "longitude" is "-73.2819463"
  And cookie "zip" is "01301"

  When someone visits "community/posts"
  Then we show "Mutual Aid Offers & Needs" with:
  | Where    | Greenfield, MA |    |
  | Radius   | 100   | Go |

  When someone confirms "community/posts" with:
  | locus          | radius | latitude | longitude |*
  | Greenfield, MA | 100    | 0        | 0         |
  Then we show "Mutual Aid Offers & Needs" with:
  | Offers   | Needs | Post an Offer | Post a Need |
  And with:
  |          | Item    | Details | |
  | food     | !! fish | big one | |

  When someone confirms "community/posts/op=show&postid=1" with:
  | email | message      |*
  | b@c.d | Hello there! |
  Then we show "Your Information" with:
  | Display Name |
  | Name |
  | Street Address |
  | City |
  | State |
  | Postal Code |
  | Phone |
  | Preferred Contact |
  And cookie "email" is "b@c.d "

Scenario: Someone enters personal data after replying to an offer
  Given these "posts":
  | postid | type  | item | details | cat  | exchange | emergency | radius | pid | created | end     |* 
  | 1      | offer | fish | big one | food | 0        | 1         | 3      | 1   | %now    | %now+3d |
  And these "people":
  | pid | displayName | fullName | address | city     | state | zip   | phone        | email | method | confirmed |*
  | 1   | Abe         | Abe One  | 1 A St. | Greenfield | MA  | 01301 | +14132530001 | a@b.c | text   | 1         |
  When someone confirms "community/posts/op=who&email=b@c.d&message=Hello there!&postid=1" with:
  | displayName | Bea |**
  | fullName    | Bea Two |
  | address     | 2 B St. |
  | city        | Greenfield |
  | state       | MA |
  | zip         | 01301 |
  | phone       | 413-253-0002 |
  | method      | email |
  | days        | 2 |
  | washes      | 3 |
  | health      | 2 |
  Then these "messages":
  | id | postid | sender | message      | created |*
  | 1  | 1      | 2      | Hello there! | %now    |
  And these "people":
  | pid | displayName | fullName | address | city     | state | zip   | phone     | email | method | confirmed | health |*
  | 2   | Bea         | Bea Two  | 2 B St. | Greenfield | MA  | 01301 | +14132530002 | b@c.d | email  | 0      | 2 3 ok |
  And we email "confirm-message" to member "b@c.d" with subs:
  | fullName | item | date | thing   | code | noFrame |*
  | Bea Two  | fish | %mdY | message |    ? |       1 |
  And we say "status": "confirm by email" with subs:
  | thing | message |**

  When someone visits "community/posts/op=confirm&thing=message&code=%code" where code is:
  | id | created |*
  | 1  | %now    |
  Then we email "post-message" to member "a@b.c" with subs:
  | fullName | item | date | thing | message      | noFrame |*
  | Abe One  | fish | %mdY | post  | Hello there! |       1 |
  And we say "status": "message sent"
