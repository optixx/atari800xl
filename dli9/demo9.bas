1 REM NEUEDL2.BAS
7 ? "Welche Graphikstufe <9...11)";
8 INPUT GR
9 IF GR<9 OR GR>11 THEN 7
10 GRAPHICS GR
11 GOSUB 42
12 POKE 703,4
13 DL=PEEK(560)+PEEK(561)*256
14 S=1536
15 POKE S,128
16 POKE S+1,66
17 POKE S+2,PEEK(660)
18 POKE S+3,PEEK(661)
19 POKE S+4,2:POKE S+5,2
20 POKE S+6,2
21 POKE S+7,65
22 POKE S+8,PEEK(560)
23 POKE S+9,PEEK(561)
25 POKE DL,0:POKE DL+1,0
26 POKE DL+2,64
27 POKE DL+199,1
28 POKE DL+200,0
29 POKE DL+201,6
31 POKE 512,10:POKE 513,6
32 POKE 54286,192
33 ? "Das ist ein Textfenster"
34 FOR X=0 TO 74 STEP 5
35 C=INT(X/5)+1:COLOR C:POKE 765,C
36 PLOT X+4,0:DRAWTO X+4,191
37 DRAWTO X,191:POSITION X,0
38 XIO 18,#6,12,0,"S:"
39 NEXT X
40 STOP
42 FOR X=1546 TO 1559:READ B:POKE X,B:NEXT X
43 DATA 72,173,111,2,141,10,212,41,63,141,27,208,104,64
44 RETURN
