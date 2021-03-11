;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     This code has been written by    ;;
;; Julien Carbonnell and Marc Schopman  ;;
;; at Wageningen University & Research  ;;
;;                                      ;;
;; You are welcome to use and extend it ;;
;;    We would be glad to be updated    ;;
;;                                      ;;
;;         Drop us a message :          ;;
;;     julien.carbonnell@gmail.com      ;;
;;         marc.schopman@wur.nl         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

breed [citizens citizen] ;; this creates the citizens breed

globals [
  ; num-citizens ;; size of the population from slider
  ; scenario ;; chose a parameters combination from the interface.
  ; input-filename ;; empirical data of engagement-scores, imported from interface.
  total-talks ;; total of talks = sum of individual num-talks / 2
  majority-opinion ;; select max value between the number num-red and num-blue
  pct-highly-engaged ;; (counts number of (engagement-score > 0.75) * 100) / num-citizens
  global-engagement-level ;; sums the individual engagement scores in a societal value
]

;patches-own ;; this is relevant in case we are using a background with meeting places having a different property than common patches
;[
;  value-xcor
;  value-ycor
;  meeting-place ;; boolean value 0: no and 1: yes
;]

turtles-own
[
  ;; age
  ;; gender
  ;; category
  ;; type
  ;; influencers
  ;; quality of relationship with each category
  opinion ;; a random value between 0: very negative and 1: very positive.
  engagement-score ;; from 0: not engaged at all, to 1: very engaged.
  highly-engaged ;; engagement-score > 0.75 0: no, 1: yes.
  vision ;; highly-engaged have an extended vision to target the less engaged of 2 nearest neighbors
  social-status ;; each time an agent wins an argument with another, he gains social-status
;  speed ;; the speed of move depends on social-status
  talking ;; boolean value true/false says if the citizen is talking or not
  peer ;; id number of the agent our citizen is talking to
  num-talks ;; each time an agent talk to another one, num-talks + 1
  talk-length ;; a talk takes some ticks (time) which decreases
  previous-peer ;; a short-term memory records which was the id of the last citizen, in order to avoid it
]


; setup parameters

to setup
  clear-all
;  if generate-random-seed? [
;    set experiment-seed new-seed
;  ]
  random-seed experiment-seed
  ;; setup-patches
  scenario?
  check-opinion
  reset-ticks
end

;to setup-patches
;    ask patches [ ;; the following code draws a meeting places among common public spaces where the opinion influences are more intense.
;     set pcolor grey + 1
;    if pxcor >= -13 and pxcor <= 13 and Pycor >= -13 and pycor <= 13 [
;      set pcolor grey + 3 ]
;    if pxcor >= -10 and pxcor <= 10 and pycor >= -10 and pycor <= 10 [
;      set pcolor brown + 4 ]
;    if pxcor >= -10 and pxcor <= -5 and pycor >= -10 and pycor <= -5 [
;      set pcolor green + 1 ]
;    if pxcor >= 5 and pxcor <= 10 and pycor >= 5 and pycor <= 10 [
;      set pcolor green + 1 ]
;    if pxcor >= -2 and pxcor <= 2 and pycor >= 13 [
;      set pcolor grey + 3 ]
;    if pxcor >= -2 and pxcor <= 2 and pycor <= -13 [
;      set pcolor grey + 3 ]
;    if pxcor <= -13 and pycor >= -2 and pycor <= 2 [
;      set pcolor grey + 3 ]
;    if pxcor >= 13 and pycor >= -2 and pycor <= 2 [
;      set pcolor grey + 3 ]
;    if pcolor = grey + 1 [
;      set meeting-place 1 ]
;    if pcolor = green + 1 [
;      set meeting-place 1 ]
;  ]
;end

to scenario?
  if city-id = "taipei" [
    setup-taipei ]
  if city-id = "telaviv" [
    setup-telaviv ]
  if city-id = "tallinn" [
    setup-tallinn ]
  if city-id = "manual setup" [
    manual-setup ]
end

to setup-taipei
  create-citizens 122 [
    setxy random-xcor random-ycor
    set shape "person"
    set opinion -1 + random-float 2 ;; will need to input the opinion data accordingly
    import-taipei
    set social-status 1 ;; define initial social-status at 1
    set talking false
    recolor-citizens
    highly-engaged?
    resize-citizens
    rescale-vision
;    rescale-speed
  ]
end

to import-taipei
    file-open "taipei-engagement-data.txt"
    while [ not file-at-end? ]
    [ set engagement-score item 0 file-read ]
    file-close
end

to setup-telaviv
  create-citizens 122 [
    setxy random-xcor random-ycor
    set shape "person"
    set opinion -1 + random-float 2 ;; will need to input the opinion data accordingly
    import-telaviv
    set social-status 1 ;; define initial social-status at 1
    set talking false
    recolor-citizens
    highly-engaged?
    resize-citizens
    rescale-vision
;    rescale-speed
  ]
end

to import-telaviv
    file-open "telaviv-engagement-data.txt"
    while [ not file-at-end? ]
    [ set engagement-score item 0 file-read ]
    file-close
end

to setup-tallinn
  create-citizens 122 [
    setxy random-xcor random-ycor
    set shape "person"
    set opinion -1 + random-float 2 ;; will need to input the opinion data accordingly
    import-tallinn
    set social-status 1 ;; define initial social-status at 1
    set talking false
    recolor-citizens
    highly-engaged?
    resize-citizens
    rescale-vision
;    rescale-speed
  ]
end

to import-tallinn
    file-open "tallinn-engagement-data.txt"
    while [ not file-at-end? ]
    [ set engagement-score item 0 file-read ]
    file-close
end

to manual-setup ;; engagement-score and opinion are setup randomly, based on set up parameters from interface
  ;; create the non-highly engaged citizens
  create-citizens num-citizens * (1 - initial-highly-engaged-pct / 100) [
    setxy random-xcor random-ycor
    set shape "person"
    set opinion -1 + random-float 2 ;; citizens are assigned a random opinion between -1: very negative to 1: very positive
    set engagement-score random-float 0.75 ;; non-highly engaged citizens are assigned a random engagement level from 0 to 0.75
    set social-status 1 ;; define initial social-status at 1
    set talking false
    set num-talks 0
    recolor-citizens
    highly-engaged?
    resize-citizens
    rescale-vision
;    rescale-speed
  ]
  ;; create the highly engaged citizens
  create-citizens num-citizens * (initial-highly-engaged-pct / 100) [
    setxy random-xcor random-ycor
    set shape "person"
    set opinion -1 + random-float 2
    set engagement-score 0.75 + random-float 0.25 ;; highly engaged citizens are assigned a random engagement level from 0.75 to 1
    set social-status 1
    set talking false
    set num-talks 0
    recolor-citizens
    highly-engaged?
    resize-citizens
    rescale-vision
;    rescale-speed
  ]
  check-engagement
end

to recolor-citizens ;; based on opinion
  if opinion >= 0.5
  [ set color blue ]
  if opinion <= -0.5
  [ set color red ]
  if opinion > -0.5 and opinion < 0.5
  [ set color grey ]
end

to highly-engaged? ;; based on engagement-score
  ifelse engagement-score > 0.75
  [ set highly-engaged 1 ]
  [ set highly-engaged 0 ]
end

to resize-citizens ;; based on engagement-score
    ifelse engagement-score > 0.75
    [ set size 2 ]
    [ set size 1 ]
end

to rescale-vision ;; based on engagement-score
  ifelse engagement-score > 0.75
  [ set vision 2 ]
  [ set vision 1 ]
end

;to rescale-speed ;; speed is based on social-status
;  ask citizens
;  [ set speed 1 * social-status ]
;end

;; Checks if the SETUP gives expected percentage of highly engaged citizens, depending on slider
to check-engagement
  let expected-highly-engaged (count turtles * initial-highly-engaged-pct / 100)
  let diff-highly-engaged (count turtles with [ engagement-score > 0.75 ]) - expected-highly-engaged
  if diff-highly-engaged > (.1 * expected-highly-engaged) [
    print "Initial number of highly-engaged citizens is more than expected."
  ]
  if diff-highly-engaged < (- .1 * expected-highly-engaged) [
    print "Initial number of highly-engaged citizens is less than expected."
  ]
end

  ;; Checks if the SETUP gives a balanced number of red and blue
to check-opinion
  let expected-red (count turtles with [color = red])
  let diff-red-blue (count turtles with [color = blue]) - expected-red
  if diff-red-blue < 0 [
    print "There is more red than blue."
  ]
  if diff-red-blue > 0 [
    print "There is more blue than red."
  ]
  if diff-red-blue = 0 [
  print "There is an equal number of red and blue."
  ]
end

;;; action parameters:
to go
  ifelse (count turtles with [color = red] = 100) or (count turtles with [color = blue] = 100)
    [stop]
  [move-citizens
      tick]
end

to move-citizens
  ask citizens [
    if not talking
    [ walk ]
    if not talking
    [ approach ]
    if talking
    [ talk ]
    if talking
    [ leave ]
    if talking
    [ set talk-length talk-length + 1 ]
  ifelse show-social-status
  [ set label precision social-status 2]
  [ ]
  ]
end

to walk ;; this line of code says how the citizens should walk
  forward (0.1 * social-status)
  set heading (heading + random 10)
  set heading (heading - random 10)
  set engagement-score engagement-score - 0.001
  if engagement-score <= 0 [
    set engagement-score 0 ]
  set social-status social-status - 0.01
  if social-status <= 1 [
    set social-status 1 ]
  rescale-vision
  resize-citizens
  highly-engaged?
end

to approach ; this line of code says that citizens should engage with other citizens that are not talking yet.
  ;; highly engaged citizens have an increase vision which gives them the opportunity to reach a peer more far.
  ifelse vision = 2 [
  let potential-target one-of ( turtles-at -2 0) with [ not talking ]
     if potential-target != nobody [
       if potential-target != previous-peer [
        set peer potential-target
        set talking true
        ask peer [ set talking true ]
        ask peer [ set peer myself ]
        move-to patch-here ;; move to center of patch
        ask potential-target [move-to patch-here] ;; partner moves to center of patch
  ] ] ]
  [
  let potential-target one-of ( turtles-at -1 0) with [ not talking ]
   if potential-target != nobody [
     if potential-target != previous-peer [
        set peer potential-target
        set talking true
        ask peer [ set talking true ]
        ask peer [ set peer myself ]
        move-to patch-here ;; move to center of patch
        ask potential-target [move-to patch-here] ;; partner moves to center of patch
  ] ] ]
end

to talk
  if talking [
    forward 0
    set previous-peer peer
    ifelse engagement-score?
    [ gain-engagement ]
    [ ]
    highly-engaged?
    resize-citizens
    rescale-vision
  ]
end

to influence-opinion
  let p-opinion [opinion] of peer
  set opinion opinion + (p-opinion * 0.1)
  if opinion > 1 [
    set opinion 1 ]
  if opinion < -1 [
    set opinion -1 ]
  ask peer [ set p-opinion p-opinion + (opinion * 0.1) ]
    if p-opinion > 1 [
      set p-opinion 1 ]
    if p-opinion < -1 [
      set p-opinion -1 ]
end

to gain-engagement
    set engagement-score engagement-score + 0.005
    if engagement-score >= 1
     [ set engagement-score 1 ]
;    if patch-here = one-of patches with [meeting-place = 1]
;    [set engagement-score engagement-score + (0.1 * catalyst-effect)]
;    if patch-here = one-of patches with [meeting-place = 0]
;    [set engagement-score engagement-score + 0.1]
end

to battle-social-status
  let p-status [social-status] of peer
  if (social-status - p-status) > 0 ;; means social-status is higher. give +1
  [set social-status social-status + 1]
  if (social-status - p-status) < 0  ;; means p-status is higher. give +1
  [set p-status p-status + 1]
  if (social-status - p-status) = 0
  [set p-status p-status + 1
   set social-status social-status + 1 ]
  if social-status > 10
  [ set social-status 10 ]
  if social-status < 1
  [ set social-status 1 ]
end

to leave
  if talking [
    if talk-length = 20 [
      influence-opinion
      recolor-citizens
      ifelse social-status?
        [ battle-social-status ]
        [ ]
      set talking false
      set talk-length 0
      set peer nobody
      set num-talks num-talks + 1
;      ask peer [ set talk-length 0 ]
;      ask peer [ set talking false ]
;      ask peer [ set peer nobody ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
855
656
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
-24
24
-24
24
0
0
1
ticks
30.0

SLIDER
19
209
191
242
num-citizens
num-citizens
0
200
100.0
1
1
NIL
HORIZONTAL

SLIDER
19
249
191
282
initial-highly-engaged-pct
initial-highly-engaged-pct
0
100
8.0
1
1
NIL
HORIZONTAL

BUTTON
19
289
85
322
NIL
setup
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
126
292
189
325
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

MONITOR
868
16
933
61
negative
count turtles with [color = red]
17
1
11

MONITOR
994
16
1065
61
positive
count turtles with [color = blue]
17
1
11

MONITOR
935
16
992
61
neutral
count turtles with [color = grey]
17
1
11

PLOT
866
70
1066
220
Public Opinion
time
distribution
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"negative" 1.0 0 -2674135 true "" "plot count turtles with [color = red]"
"neutral" 1.0 0 -7500403 true "" "plot count turtles with [color = grey]"
"positive" 1.0 0 -13345367 true "" "plot count turtles with [color = blue]"
"overall" 1.0 0 -16777216 true "" "plot sum [opinion] of turtles"

SWITCH
18
411
189
444
show-social-status
show-social-status
1
1
-1000

SWITCH
19
334
189
367
engagement-score?
engagement-score?
1
1
-1000

SWITCH
18
372
188
405
social-status?
social-status?
1
1
-1000

INPUTBOX
19
139
192
199
experiment-seed
5.0
1
0
Number

INPUTBOX
19
13
190
73
input-filename
taipei-engagement-data.txt tallinn-engagement-data.txt telaviv-engagement-data.txt
1
0
String

PLOT
866
232
1066
382
percentage of highly engaged
time
percent
0.0
10.0
0.0
100.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (((count turtles with [size = 2]) * num-citizens) / 100)"

PLOT
1085
394
1285
544
global social status
time
total
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [social-status] of turtles"

CHOOSER
20
83
192
128
city-id
city-id
"taipei" "tel aviv" "tallinn" "manual setup"
3

PLOT
1085
232
1285
382
global engagement score
time
total
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [engagement-score] of turtles"

PLOT
867
398
1067
548
social-status
time
total
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"1" 1.0 0 -16777216 true "" "plot count turtles with [social-status = 1]"
"2" 1.0 0 -7500403 true "" "plot count turtles with [social-status = 2]"
"3" 1.0 0 -955883 true "" "plot count turtles with [social-status = 3]"
"4" 1.0 0 -6459832 true "" "plot count turtles with [social-status = 4]"
"5" 1.0 0 -10899396 true "" "plot count turtles with [social-status = 5]"
"6" 1.0 0 -13840069 true "" "plot count turtles with [social-status = 6]"
"7" 1.0 0 -14835848 true "" "plot count turtles with [social-status = 7]"
"8" 1.0 0 -11221820 true "" "plot count turtles with [social-status = 8]"
"9" 1.0 0 -13791810 true "" "plot count turtles with [social-status = 9]"
"10" 1.0 0 -8630108 true "" "plot count turtles with [social-status = 10]"

PLOT
1084
71
1284
221
total number of talks
time
total
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (sum [num-talks] of turtles / 2)"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment-5_opinion_only" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [color = red]</metric>
    <metric>count turtles with [color = blue]</metric>
    <metric>count turtles with [color = grey]</metric>
    <metric>sum [opinion] of turtles</metric>
    <metric>count turtles with [engagement-score &gt; 0.75]</metric>
    <metric>sum [engagement-score] of turtles</metric>
    <metric>count turtles with [social-status = 1]</metric>
    <metric>count turtles with [social-status = 2]</metric>
    <metric>count turtles with [social-status = 3]</metric>
    <metric>count turtles with [social-status = 4]</metric>
    <metric>count turtles with [social-status = 5]</metric>
    <metric>count turtles with [social-status = 6]</metric>
    <metric>count turtles with [social-status = 7]</metric>
    <metric>count turtles with [social-status = 8]</metric>
    <metric>count turtles with [social-status = 9]</metric>
    <metric>count turtles with [social-status = 10]</metric>
    <metric>sum [social-status] of turtles</metric>
    <metric>(sum [num-talks] of turtles) / 2</metric>
    <enumeratedValueSet variable="city-id">
      <value value="&quot;manual setup&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment-seed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-status">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-citizens">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-score?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-highly-engaged-pct">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-filename">
      <value value="&quot;taipei-engagement-data.txt tallinn-engagement-data.txt telaviv-engagement-data.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-status?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-5_engagement" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [color = red]</metric>
    <metric>count turtles with [color = blue]</metric>
    <metric>count turtles with [color = grey]</metric>
    <metric>sum [opinion] of turtles</metric>
    <metric>count turtles with [engagement-score &gt; 0.75]</metric>
    <metric>sum [engagement-score] of turtles</metric>
    <metric>count turtles with [social-status = 1]</metric>
    <metric>count turtles with [social-status = 2]</metric>
    <metric>count turtles with [social-status = 3]</metric>
    <metric>count turtles with [social-status = 4]</metric>
    <metric>count turtles with [social-status = 5]</metric>
    <metric>count turtles with [social-status = 6]</metric>
    <metric>count turtles with [social-status = 7]</metric>
    <metric>count turtles with [social-status = 8]</metric>
    <metric>count turtles with [social-status = 9]</metric>
    <metric>count turtles with [social-status = 10]</metric>
    <metric>sum [social-status] of turtles</metric>
    <metric>(sum [num-talks] of turtles) / 2</metric>
    <enumeratedValueSet variable="city-id">
      <value value="&quot;manual setup&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment-seed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-status">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-citizens">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-score?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-highly-engaged-pct">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-filename">
      <value value="&quot;taipei-engagement-data.txt tallinn-engagement-data.txt telaviv-engagement-data.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-status?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-5_status" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [color = red]</metric>
    <metric>count turtles with [color = blue]</metric>
    <metric>count turtles with [color = grey]</metric>
    <metric>sum [opinion] of turtles</metric>
    <metric>count turtles with [engagement-score &gt; 0.75]</metric>
    <metric>sum [engagement-score] of turtles</metric>
    <metric>count turtles with [social-status = 1]</metric>
    <metric>count turtles with [social-status = 2]</metric>
    <metric>count turtles with [social-status = 3]</metric>
    <metric>count turtles with [social-status = 4]</metric>
    <metric>count turtles with [social-status = 5]</metric>
    <metric>count turtles with [social-status = 6]</metric>
    <metric>count turtles with [social-status = 7]</metric>
    <metric>count turtles with [social-status = 8]</metric>
    <metric>count turtles with [social-status = 9]</metric>
    <metric>count turtles with [social-status = 10]</metric>
    <metric>sum [social-status] of turtles</metric>
    <metric>(sum [num-talks] of turtles) / 2</metric>
    <enumeratedValueSet variable="city-id">
      <value value="&quot;manual setup&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment-seed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-status">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-citizens">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-score?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-highly-engaged-pct">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-filename">
      <value value="&quot;taipei-engagement-data.txt tallinn-engagement-data.txt telaviv-engagement-data.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-status?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-5_engagement_status" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [color = red]</metric>
    <metric>count turtles with [color = blue]</metric>
    <metric>count turtles with [color = grey]</metric>
    <metric>sum [opinion] of turtles</metric>
    <metric>count turtles with [engagement-score &gt; 0.75]</metric>
    <metric>sum [engagement-score] of turtles</metric>
    <metric>count turtles with [social-status = 1]</metric>
    <metric>count turtles with [social-status = 2]</metric>
    <metric>count turtles with [social-status = 3]</metric>
    <metric>count turtles with [social-status = 4]</metric>
    <metric>count turtles with [social-status = 5]</metric>
    <metric>count turtles with [social-status = 6]</metric>
    <metric>count turtles with [social-status = 7]</metric>
    <metric>count turtles with [social-status = 8]</metric>
    <metric>count turtles with [social-status = 9]</metric>
    <metric>count turtles with [social-status = 10]</metric>
    <metric>sum [social-status] of turtles</metric>
    <metric>(sum [num-talks] of turtles) / 2</metric>
    <enumeratedValueSet variable="city-id">
      <value value="&quot;manual setup&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment-seed">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-status">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-citizens">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-score?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-highly-engaged-pct">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-filename">
      <value value="&quot;taipei-engagement-data.txt tallinn-engagement-data.txt telaviv-engagement-data.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-status?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-6_engagement-4%" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [color = red]</metric>
    <metric>count turtles with [color = blue]</metric>
    <metric>count turtles with [color = grey]</metric>
    <metric>sum [opinion] of turtles</metric>
    <metric>count turtles with [engagement-score &gt; 0.75]</metric>
    <metric>sum [engagement-score] of turtles</metric>
    <metric>count turtles with [social-status = 1]</metric>
    <metric>count turtles with [social-status = 2]</metric>
    <metric>count turtles with [social-status = 3]</metric>
    <metric>count turtles with [social-status = 4]</metric>
    <metric>count turtles with [social-status = 5]</metric>
    <metric>count turtles with [social-status = 6]</metric>
    <metric>count turtles with [social-status = 7]</metric>
    <metric>count turtles with [social-status = 8]</metric>
    <metric>count turtles with [social-status = 9]</metric>
    <metric>count turtles with [social-status = 10]</metric>
    <metric>sum [social-status] of turtles</metric>
    <metric>(sum [num-talks] of turtles) / 2</metric>
    <enumeratedValueSet variable="city-id">
      <value value="&quot;manual setup&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment-seed">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-status">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-citizens">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-score?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-highly-engaged-pct">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-filename">
      <value value="&quot;taipei-engagement-data.txt tallinn-engagement-data.txt telaviv-engagement-data.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-status?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-6_engagement-12%" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [color = red]</metric>
    <metric>count turtles with [color = blue]</metric>
    <metric>count turtles with [color = grey]</metric>
    <metric>sum [opinion] of turtles</metric>
    <metric>count turtles with [engagement-score &gt; 0.75]</metric>
    <metric>sum [engagement-score] of turtles</metric>
    <metric>count turtles with [social-status = 1]</metric>
    <metric>count turtles with [social-status = 2]</metric>
    <metric>count turtles with [social-status = 3]</metric>
    <metric>count turtles with [social-status = 4]</metric>
    <metric>count turtles with [social-status = 5]</metric>
    <metric>count turtles with [social-status = 6]</metric>
    <metric>count turtles with [social-status = 7]</metric>
    <metric>count turtles with [social-status = 8]</metric>
    <metric>count turtles with [social-status = 9]</metric>
    <metric>count turtles with [social-status = 10]</metric>
    <metric>sum [social-status] of turtles</metric>
    <metric>(sum [num-talks] of turtles) / 2</metric>
    <enumeratedValueSet variable="city-id">
      <value value="&quot;manual setup&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment-seed">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-status">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-citizens">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-score?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-highly-engaged-pct">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-filename">
      <value value="&quot;taipei-engagement-data.txt tallinn-engagement-data.txt telaviv-engagement-data.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-status?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-8_engagement-50%" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [color = red]</metric>
    <metric>count turtles with [color = blue]</metric>
    <metric>count turtles with [color = grey]</metric>
    <metric>sum [opinion] of turtles</metric>
    <metric>count turtles with [engagement-score &gt; 0.75]</metric>
    <metric>sum [engagement-score] of turtles</metric>
    <metric>count turtles with [social-status = 1]</metric>
    <metric>count turtles with [social-status = 2]</metric>
    <metric>count turtles with [social-status = 3]</metric>
    <metric>count turtles with [social-status = 4]</metric>
    <metric>count turtles with [social-status = 5]</metric>
    <metric>count turtles with [social-status = 6]</metric>
    <metric>count turtles with [social-status = 7]</metric>
    <metric>count turtles with [social-status = 8]</metric>
    <metric>count turtles with [social-status = 9]</metric>
    <metric>count turtles with [social-status = 10]</metric>
    <metric>sum [social-status] of turtles</metric>
    <metric>(sum [num-talks] of turtles) / 2</metric>
    <enumeratedValueSet variable="city-id">
      <value value="&quot;manual setup&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment-seed">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-social-status">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-citizens">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="engagement-score?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-highly-engaged-pct">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-filename">
      <value value="&quot;taipei-engagement-data.txt tallinn-engagement-data.txt telaviv-engagement-data.txt&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-status?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
