About Pepper
------------

[saltybet.com](http://saltybet.com/) runs matches between fighting game AI's and allows users to place bets on the outcome.
It is amazing and fun. Congratulations to its creator.
Pepper collects the result of each match and constructs a database of match outcomes and a ranked rating of players.


Saltybet no longer publishes in text what characters are playing in an effort to prevent betting bots.
This makes the collector for Pepper no longer function.
It's been fun making the site but all good things must come to an end.

Rating System
-------------

Ratings are determined using a version of the [Elo rating system](http://en.wikipedia.org/wiki/Elo_rating_system).
Each player has a rating that represents their estimated skill level.
The higher the rating, the better the player.
Given two players, you can determine the probability that one will defeat the other.
When one player defeats another, the winner's rating increases, and the loser's decreases.
If one player was expected to win, but actually lost, then they lose more points than if the odds had been more even.

A rating of 10 is average.
Every new player gets a rating of 10, indicating that given no information about the player, we can only assume they are average.

Technical Details
-----------------

A python script grabs the [betting data](http://saltybet.com/betdata.json) and stores it in a [redis](http://redis.io/) database.
The frontend server is written in Haskell using the [scotty](https://github.com/xich/scotty) web framework.
It reads data from the redis database and presents it.
You can find the code on [github](https://github.com/smadge/pepper).
