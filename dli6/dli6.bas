10 REM DLI6.BAS
20 FOR X=1536 TO 1620
30 READ D
40 POKE X, D
50 NEXT X
60 Z = USR(1536)
70 DATA 169,28,141,48,2,169,6,141
80 DATA 49,2,169,37,141,0,2,169
90 DATA 6,141,1,2,169,192,141,14
100 DATA 212,76,25,6,112,240,112,112
110 DATA 112,112,65,28,6,72,152,72
120 DATA 160,0,185,60,6,141,10,212
130 DATA 141,26,208,200,192,33,208,242
140 DATA 104,168,104,64,112,114,116,118
150 DATA 120,122,124,126,126,124,122,120
160 DATA 118,116,114,112,62,60,58,56
170 DATA 54,52,50,48,0