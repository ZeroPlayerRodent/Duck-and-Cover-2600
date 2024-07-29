 rem Welcome to the Duck and Cover source code!
 rem This is my first project in bAtari Basic, so the code probably isn't that good.
 rem Any feedback or suggestions to improve the code is welcome!

 rem "c" is the byte used to store modifier data.
 c = 0
 score = 0
 const font = retroputer

 COLUPF = 14

 rem "e" is a byte that stores all kinds of different data.
 e = 0

 rem "r" is the byte that counts down 1 second on the title and game over screens.
 r = 60

 rem Title screen loop.
title

 scorecolor = 14

 rem Code that allows the player to switch game modes and start the game.
 if joy0fire then r = r - 1
 if r = 0 || switchreset then e{2} = 1 : goto full_reset
 if switchselect && !e{2} then c = c + 1 : if c > 31 then c = 0 : score = 0
 if switchselect && !e{2} then gosub set_score : e{2} = 1
 if !switchselect then e{2} = 0
 if !switchrightb then z = 0

 playfield:
 ................................
 .XX..X.X..XXX.X.X...X..X.X.XX...
 .X.X.X.X.X....XX...X.X.XXX.X.X..
 .XX...X...XXX.X.X..X.X.X.X.XX...
 ................................
 ...XXX..XX..X..X.XXX.XXX........
 ..X....X..X.X..X.XX..X.X........
 ..X....X..X.X..X.X...XX.........
 ...XXX..XX...XX..XXX.X.X........
 ................................
 ................................
end

 drawscreen
 goto title

 rem This is where the game goes to fully reset after a game over.
full_reset
 score = 0

 rem "d" is the byte for storing the number of lives the player has.
 d = 4

 rem This is where the game goes to reset after losing a life.
reset
 rem Bytes for P1 and P2 "gravity".
  t = 0
  u = 0

 rem Bytes for bomb falling speed.
  a = 10 : b = 10
  if !switchleftb then a = 5 : b = 5
  m = 10

 rem Byte that remembers how many players have died.
  z = 0

 rem Byte that remembers how long a sound effect has been playing.
  j = 0

 rem Bytes for the bomb and explosion coordinates.
  h = 0 : y = 76 : k = 0
  q = 0 : p = 100 : v = 0

 rem Bytes to remember which frame animations are on.
  g = 4
  i = 4

 rem Reset "r"
  r = 60
  
 rem Reset "e"
  e = 0

 rem Bytes for player coordinates.
  s = 70
  o = 80
  w = 70
  l = 80

 rem Byte for explosion height.
  x = 20

 rem Check for big bombs and explosions.
 missile0height = 10
 if c{2} then goto hard
 goto skip_hard
hard
 x = 25
 missile0height = 15
skip_hard

 rem Define playfield.
 playfield:
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ......X..........X............X.
 X.X...X....X.....X..X...X...X.X.
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end

 missile0x = 76
 missile0y = 0

 missile1height = 5
 missile1x = 76
 missile1y = 40

 scorecolor = 14

 player0x = 76
 player0y = 80

 player1x = 0
 player1y = 0

 COLUPF = $C2
 AUDV0 = 10

 rem Main game loop.
mainloop

 rem Animate and render player 1.
 if !e{0} && e{2} then gosub flap
 if !e{0} && !e{2} then gosub notflap
 if !e{0} && e{6} && (o > 79) then gosub scuttle
 if !e{0} && e{4} then REFP0 = 8
 if !e{0} then COLUP0 = 30 : player0x = s : player0y = o

 rem Animate and render player 2.
 if e{0} && e{3} then gosub flap
 if e{0} && !e{3} then gosub notflap
 if e{0} && e{7} && (l > 79) then gosub scuttle
 if e{0} && e{5} then REFP0 = 8
 if e{0} then COLUP0 = 14 : player0x = w : player0y = l

 COLUP1 = 42
 NUSIZ0 = $20
 NUSIZ1 = $25


 rem Flicker player 1 and 2 in mutliplayer mode.
 if !switchrightb && z = 0 then e{0} = !e{0}

 rem Mute audio after it is finished playing.
 if (j > 0) then j = j - 1
 if (j < 1) then AUDC0 = 0

 rem Collision detection.
 if (player0x + 8) > y && (player0x + 8) < (y + 8) && (player0y - 8) < h && player0y > (h - missile0height) then gosub checkdeath
 if (player0x + 0) > k && (player0x + 16) < (k + 25) && player0y > (80 - x) then gosub checkdeath
 if (player0x + 8) > p && (player0x + 8) < (p + 8) && (player0y - 8) < q && player0y > (q - missile0height) then gosub checkdeath
 if (player0x + 0) > v && (player0x + 16) < (v + 25) && player0y > (80 - x) then gosub checkdeath

 rem End the game if both players are dead.
 if z >= 2 then goto lost_life

 rem Move bread if modifier is active.
 if c{3} then missile1x = missile1x + 1
 if c{3} && (missile1x > 140) then missile1x = 20

 rem Let players collect bread.
 if collision(player0,missile1) then missile1x = (rand&115) + 25 : missile1y = (rand&50) + 20 : score = score + 25 : AUDF0 = 10 : AUDC0 = 7 : j = 5

 rem Handle bombs exploding when they hit the ground.
 if (h > 80) then g = 4
 if (h > 80) then k = (y-5) : player1y = 80 : y = (player0x + 3) : m = m - 1 : j = 5 : AUDF0 = 10 : AUDC0 = 8 : h = 0

 if (q > 80) then v = (p-5) : player1y = 80 : i = 4
 if (q > 80) then p = (rand&115) + 25 : m = m - 1 : j = 5 : AUDC0 = 8 : q = 0

 rem Speed bombs up.
 if (m < 1) then b = b - 1 : m = 10
 if (b < 3) then b = 3

 rem Move bombs.
 a = a - 1
 if (a < 1) then q = q + 4 : a = b : h = h + 5


 rem Animate and render first mushroom cloud.
 e{1} = !e{1}
 if !e{1} && g = 4 then gosub mf4
 if !e{1} && g = 3 then gosub mf3
 if !e{1} && g = 2 then gosub mf2
 if !e{1} && g = 1 then gosub mf1
 if !e{1} && g = 0 then gosub mf1
 if !e{1} && (g > 1) then g = g - 1
 if !e{1} then missile0x = y : missile0y = h : player1x = k

 rem Animate and render second mushroom cloud.
 if e{1} && i = 4 then gosub mf4
 if e{1} && i = 3 then gosub mf3
 if e{1} && i = 2 then gosub mf2
 if e{1} && i = 1 then gosub mf1
 if e{1} && i = 0 then gosub mf1
 if e{1} && (i > 1) then i = i - 1
 if e{1} then missile0x = p : missile0y = q : player1x = v

 rem Duck jump height.
 temp1 = 6
 if c{0} then temp1 = 10
 
 rem Duck move speed.
 temp2 = 1
 if c{1} then temp2 = 2

 rem Handle player 1 movement.
 if (t > 1) then o = o - 3 : t = t - 1
 if t = 0 && (o < 80) then o = o + 1
 if joy0fire && !e{2} then t = temp1 : e{2} = 1
 if !joy0fire then e{2} = 0
 if joy0right then s = s + temp2 : e{4} = 0
 if joy0left then s = s - temp2 : e{4} = 1
 if !e{0} && joy0right && (o > 79) then e{6} = !e{6}
 if !e{0} && joy0left && (o > 79) then e{6} = !e{6}

 rem Handle player 2 movement.
 if (u > 1) then l = l - 3 : u = u - 1
 if u = 0 && (l < 80) then l = l + 1
 if joy1fire && !e{3} then u = temp1 : e{3} = 1
 if !joy1fire then e{3} = 0
 if joy1right then w = w + temp2 : e{5} = 0
 if joy1left then w = w - temp2 : e{5} = 1
 if e{0} && joy1right && (l > 79) then e{7} = !e{7}
 if e{0} && joy1left && (l > 79) then e{7} = !e{7}

 rem Handle screen borders.
 if c{4} && (s > 140) then s = 20
 if (s > 140) then s = 140
 if c{4} && (s < 20) then s = 140
 if (s < 20) then s = 20
 if (o < 3) then t = 0 : o = 3
 if c{4} && (w > 140) then w = 20
 if (w > 140) then w = 140
 if c{4} && (w < 20) then w = 140
 if (w < 20) then w = 20
 if (l < 3) then u = 0 : l = 3

 drawscreen
 goto mainloop

 rem Game over loop.
dead
 AUDC0 = 0
 COLUP0 = $32
 missile0x = 0
 missile0y = 0
 missile1x = 0
 missile1y = 0
 player1x = 0
 player1y = 0
 drawscreen

 rem Let players choose a new game mode and restart game.
 if joy0fire then r = r - 1
 if r = 0 || switchreset then e{2} = 1 : goto full_reset
 if switchselect && !e{2} then c = c + 1 : if c > 31 then c = 0 : score = 0
 if switchselect && !e{2} then gosub set_score : e{2} = 1
 if !switchselect then e{2} = 0
 if !switchrightb then z = 0
 
 goto dead

 rem Increment player death count.
checkdeath
 z = z + 1
 return

 rem Make the player lose a life when they die.
lost_life
 r = 50
 d = d - 1

 AUDF0 = 5
 AUDC0 = 9

 j = 5

  player1:
 %01111100
 %11111110
 %11111110
 %11111110
 %11111110
 %10111110
 %01011100
 %00111000
end

 rem Loop shortly to display remaining lives.
death_loop
 COLUP0 = $32
 COLUP1 = 14
 missile0x = 0
 missile0y = 0
 missile1x = 0
 missile1y = 0
 player1x = 20
 player1y = 20

 j = j - 1
 if j = 0 then AUDC0 = 0

 if d = 3 then NUSIZ1 = $03
 if d = 2 then NUSIZ1 = $01
 if d = 1 then NUSIZ1 = $00
 if d = 0 then player1x = 0 : player1y = 0
 drawscreen
 r = r - 1
 if r = 0 && d = 0 then r = 60 : goto dead
 if r = 0 then goto reset
 goto death_loop


 rem Sprites for mushroom cloud.
mf4
  player1:
 %00011000
 %00111000
 %00011000
 %00011010
 %00011000
 %01011001
 %00011000
 %10011010
end
 return

mf3
  player1:
 %01111110
 %00111100
 %00011001
 %01011000
 %10011010
 %00011000
 %00111001
 %00011000
 %00011000
 %00111100
 %10111100
 %00111100
end
 return

mf2
  player1:
 %01111110
 %00111100
 %10011000
 %00011001
 %00011000
 %01111110
 %00011000
 %00011000
 %10011001
 %11111111
 %01111110
 %00111100
end
 return

mf1
  player1:
 %11111111
 %01111110
 %00111100
 %00011000
 %00011000
 %00011000
 %00011000
 %00011000
 %00011000
 %00011000
 %00011000
 %11111111
 %00011000
 %00011000
 %00011000
 %00011000
 %01111110
 %11111111
 %11111111
 %11111111
 %01111110
end
 if c{2} then goto big
 goto regular
big
  player1:
 %11111111
 %01111110
 %00111100
 %00011000
 %00011000
 %00011000
 %00011000
 %00011000
 %00011000
 %00011000
 %00011000
 %11111111
 %00011000
 %00011000
 %00011000
 %00011000
 %00011000
 %00011000
 %01111110
 %11111111
 %11111111
 %11111111
 %11111111
 %11111111
 %01111110
end
regular
 return

 rem Sprites for players.
flap
  player0:
 %00100100
 %11111111
 %01111110
 %00111100
 %00111100
 %00111111
 %00110100
 %00011000
 %00000100
end
 return

notflap
  player0:
 %00100100
 %00111100
 %01111110
 %11111111
 %00111100
 %00111111
 %00110100
 %00011000
 %00000100
end
 return

scuttle
  player0:
 %00011000
 %00111100
 %01111110
 %11111111
 %00111100
 %00111111
 %00110100
 %00011000
 %00000100
end
 return

 rem Change score to display game mode.
set_score
 score = 0
 if c{0} then score = score + 1
 if c{1} then score = score + 2
 if c{2} then score = score + 4
 if c{3} then score = score + 8
 if c{4} then score = score + 16
 if c{5} then score = score + 32
 if c{6} then score = score + 64
 if c{7} then score = score + 128
 return

 rem That's it for the source code!
 rem Right now it's really hard to read because I wrote most of it before I knew how to "dim" variables.
 rem I will most likely "dim" the variables and generally improve the code later on.