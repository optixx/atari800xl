10 REM *******
20 REM + Zweifarbiges 6R.0
30 REM *
40 REM * Einfaches DLI-Beispiel
50 REM ************** *******※
60 REM
100 REM * DLI-ROUTINE IN PABE 6
110 FOR I=1536 TO 1546:READ A:POKE I, A: NEXT I
115 REM *PLA
120 DATA 72
125 REM •LDA #$C2
130 DATA 169,194
135 REM *STA WSYNC
140 DATA 141,10,212
145 REM * STA COLPF2
150 DATA 141,24,208
155 REM * PLA
160 DATA 104
165 REM + RTI
170 DATA 64
200 REM + DLI-Bit in D.-List setzen
210 DLIST=PEEK (561)*256+PEEK (560)
220 POKE DLIST+16,128+2
300 REM * DLI freigeben
310 VDSLST=512:NMIEN=54286
320 POKE NMIEN, 64:REM + DLI aus
330 POKE VDSLST, 0:REM * Vektor
340 POKE VDSLST+1,6: REM * eintragen
350 POKE NMIEN, 192: REM * DLI ein
