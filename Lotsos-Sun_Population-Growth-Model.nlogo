breed [birds bird]

birds-own [
  id        ;; Each bird has a unique id
  age       ;; The age of the bird in ticks
  mated?
  energy    ;; Energy of the birds, if this reaches 0 they die
]

patches-own [
  growth_area? ;;only certain areas can grow food, determined at setup
  has_food?
]

globals [
  alive_num ;; The number of alive birds
  counter   ;; The overall population as opposed to alive_num
  current_food ;; The amount of food currently on the map
]

;;
;; SETUP PROCEDURES
;;

to Setup
  clear-all
  set-default-shape birds "airplane"
  set alive_num 0
  setup_birds
  setup_patches
  set current_food 0
  ask patches [
    setup_food_source
  ]
  reset-ticks
end

to go
  ;;if ticks = 0 [set alive_num initial_population]
  ask birds [
    fly
    eat
    mate
    get_older ;; interestingly enough, this is a measure of population control too
    lose_energy ;; TODO: population control
  ]
  ;;show current_food ;;todo
  ask patches [
    grow_food
  ]

  tick
end

;; Procedure to setup the birds
;; Creates the initial population of birds on setup and sets their default variables
to setup_birds
  set counter 0

  create-birds initial_population ;; TODO: change this to a slider controlled variable later
  [
    setxy random-xcor random-ycor
    set id counter
    set age 0
    set mated? false
    set color green
    set energy bird_initial_energy
    set size 2
    set counter counter + 1
  ]
  set alive_num alive_num + initial_population
end

;; Procedure to setup the patches
;; Creates the initial distribution of food on the map based on the patches_food_chance global var
to setup_patches
  ask patches [
    set has_food? false
    if not has_food? and random-float 1 < patches_food_chance and current_food < maximum_food[
      set pcolor magenta
      set has_food? true
      set current_food current_food + 1
    ]
  ]
end

;;
;; BIRD PROCEDURES
;;
to get_older
  ;;if model = "exponential" [stop]
  if self = nobody [stop]
  set age age + 1 ;; age a year
  if age >= bird_max_age [  ;; remember to die
    set alive_num alive_num - 1
    die
  ]
end

to lose_energy
  if model = "exponential" [stop]
  if ticks mod 7 = 0 [set energy energy - energy_decay] ;; lose a unit of energy every 20 ticks
  ;show "energy"
  if energy <= 0 [  ;; die if your energy reaches 0
    ;show "because"
    ;;show "death"
    ;;show alive_num
    ;set alive_num alive_num - 1
    ;die
  ]
end

to fly
  if (ticks mod 20) = 0 [set heading random 360] ;; change direction every 20 ticks
  fd 1
end

to eat
  if model = "exponential" [stop]

  if not has_food? [stop]

  set energy energy + patches_energy_value
  set has_food? false
  set pcolor black
  ;set size 2
  ;show "eat"
  set current_food current_food - 1
end

to mate
  if mated? [stop]
  if age <= one-of [15 20] [stop]
  if not any? other birds-here [stop]
  let target-mate one-of other birds-here
  let mateddd 0
  ask target-mate [
    if mated? [stop]
    let child_num random(4)
    let child_num1 random(2)
    ifelse energy > int(bird_initial_energy * 0.8) [set mateddd child_num] [set mateddd child_num1]
    hatch mateddd [ ;; attention: when it goes below 3, the curve is weird
      setxy  random-xcor random-ycor
      set id counter
      set age 0
      set mated? false
      set energy bird_initial_energy
      set size 2
      set counter counter + 1
      set color green
    ]
    set mated? true
    set color pink

    ask self [
      set mated? true
      set color pink
      set counter counter + 1
    ]
  ]
  set alive_num (alive_num + mateddd)
end

;;
;; PATCH PROCEDURES
;;
to setup_food_source
  if model = "exponential" [stop]
  ;;if random-float 1 < patches_food_chance [
    if current_food >= maximum_food [stop]
    set pcolor magenta
    set growth_area? true
    set has_food? true
    set current_food current_food + 1
  ;;]
end

to grow_food
  if not (ticks mod 7 = 0) [stop]
  if model = "exponential" [stop]
  if has_food? [stop]
  if current_food >= maximum_food [stop]
  if growth_area? = true[
    set pcolor magenta
    set has_food? true
    set current_food current_food + 1
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
270
12
707
450
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
15
25
120
58
NIL
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
14
75
120
108
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
13
239
213
389
how many birds
ticks
birds
0.0
100.0
0.0
1000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot alive_num"

CHOOSER
12
168
185
213
model
model
"exponential" "logistic"
1

SLIDER
269
473
441
506
bird_max_age
bird_max_age
10
500
60.0
10
1
ticks
HORIZONTAL

SLIDER
269
516
441
549
bird_initial_energy
bird_initial_energy
1
200
82.0
1
1
NIL
HORIZONTAL

SLIDER
515
471
707
504
patches_food_chance
patches_food_chance
0.01
1
0.42
0.01
1
NIL
HORIZONTAL

SLIDER
515
512
707
545
maximum_food
maximum_food
1
100
99.0
2
1
bites
HORIZONTAL

SLIDER
514
556
707
589
patches_energy_value
patches_energy_value
1
10
7.0
1
1
NIL
HORIZONTAL

SLIDER
269
555
441
588
energy_decay
energy_decay
1
10
8.0
1
1
NIL
HORIZONTAL

SLIDER
13
121
185
154
initial_population
initial_population
10
200
92.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model showcases two population growth models: the exponential and the logistic model. The exponential model shows how a population grows when it has unlimited resources and no relevant constraints while the logistic model shows how a population growth is affected by resource constraints.

## HOW IT WORKS

The microworld is populated by birds (a breed of turtles) that fly randomly over a grid of patches (the map). As the birds fly around the map they have a chance of making contact with eachother and if certain conditions are met, they will mate, producing exactly one offspring.
The birds are colored either blue or pink, indicating whether they have mated before. If a bird's color is pink, then it has mated before and if it hasn't, it's colored green. A collision between two green birds will result in them mating successfully. A successful mating will produce a green offspring and turn the parents pink.
When exploring the exponential model, the birds are free to fly around indefinitely, without any constraints, searching for an eligible mate. However, under the logistic model, the birds are subject to constraints that will affect the growth rate of the population. More specifically, under the logistic model, the birds will:
  - Age every few ticks and die once they've reached a maximum age set by the user.
  - Lose energy every few ticks and die if their energy reaches 0
To replenish their energy, the birds need to fly over a patch that has food, which is colored magenta, and eat it. When the food from a patch is eaten, its color reverts to black.
The map can only have a limited amount of food at any given time and if the current amount of food available on the map is less than the maximum, every patch has a chance to grow some food.

## HOW TO USE IT

Use the drop-down menu to the right of the canvas to select which model you would like to explore and then hit the setup and go buttons to start the simulation.
Before doing so, you may play around with the initial population size, the lifespan of the birds, and other relevant parameters to the model to see how they affect the growth of the population. Note that variables that have to do with the birds' age, energy and the food availability of the map are only relevant when exploring the logistic model.

## THINGS TO NOTICE

Notice the plot of the current number of birds in the population which is shown on the left of the canvas. How does switching from one model to the other affect the shape of the curve? Also, observe how different variables affect the slope of the curve under any given model, as well as whether they result in a sustainable population size (i.e. whether the birds die out or not).

## THINGS TO TRY

Try playing around with the initial population size, the lifespan of the birds, and the other relevant parameters to the model to see how they affect the growth rate of the population.

## EXTENDING THE MODEL

The method of mating has been chosen arbitrarily to require the birds to make contact in order to mate. Try imposing different mating conditions to see how this affects the population growth rate. Could the birds reproduce without a partner? From a distance? Randomly perhaps?
A logical next step when exploring population constraints would be the addition of a predator population (as in the wolf-sheep model). How do you think that would affect the population?
Currently, the map size and shape are set to the default values of a NETLOGO model. That is, the map is a wrapping rectangle (a torus). How would changing the topology of the simulation affect the population?

## NETLOGO FEATURES

Note the use of the other and breed-here keywords used in combination to create the `mate` procedure.

## RELATED MODELS

Wolf-Sheep model: 

## CREDITS AND REFERENCES

Credit to:
Meixuan Sun, meixuansun2022@u.northwestern.edu
Alexandros Lotsos, alexandroslotsos2026@u.northwestern.edu
Reference:
https://www.khanacademy.org/science/ap-biology/ecology-ap/population-ecology-ap/a/exponential-logistic-growth
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
