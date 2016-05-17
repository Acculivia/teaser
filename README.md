#teaser
****
##Intro: it's just a half-done game

teaser is a game I made with Apple's SpriteKit. Basically, it's similar to a barrage game.

Before every stage start you have a short time to adjust your position, during which you're invulnerable. Then let's rocks.

It only contains 5 stages. I was to make music to suit it, but now the music should only stay in my mind.

Due to some nasty bugs of SpriteKit as well as my lacking of experience in the field of coding, I decided to open its source code and ask for suggestions.

Maybe I should put effort on stuying WebGL & OpenGL?

##Problem 1: Messy Messy Stage Script

Behind the seems-beautiful appearence is but a mess, which I can't handle. teaser is written in swift and I was too inpatient to write this game out.

You can easily find out how I write the script in StageScript.swift. I just nastily put 5 stages in a huge tuple and blah blah blah. How should I do to avoid such a stupid doing?

##Problem 2: Maybe it is SpriteKit's fault

This one is quite simple. Just after registering the SKPhysicsContactDelegate, and implementing the collide method, I've found that sometimes the contact bodyA or bodyB would get a nil. At this case though, if you were to do some method on them such as 

````swift
bodyA.removeFromParent()
````

, that node works fine. But when it gets to

````swift
bodyA as! Player //Which is just an Example
````

, then Xcode will say it unexpectedly found a nil.

****

Maybe more problem will be added into this readme soon.

But if you are to make suggestions, thanks a lot.
