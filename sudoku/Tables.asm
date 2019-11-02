Tables			.local

; Each cell group (row, column, 3x3 box) contains exactly 9 cells. Using this table we can quickly loop over
; each cell in a group without having to do much arithmetic.

CellGroup		.local		; Define cells in each cell group (row,column,box)

; Rows (tested = OK)

				.byte 0,1,2,3,4,5,6,7,8		
				.byte 9,10,11,12,13,14,15,16,17
				.byte 18,19,20,21,22,23,24,25,26
				.byte 27,28,29,30,31,32,33,34,35
				.byte 36,37,38,39,40,41,42,43,44
				.byte 45,46,47,48,49,50,51,52,53
				.byte 54,55,56,57,58,59,60,61,62
				.byte 63,64,65,66,67,68,69,70,71
				.byte 72,73,74,75,76,77,78,79,80
		
; Columns (tested = OK)

				.byte 0,9,18,27,36,45,54,63,72
				.byte 1,10,19,28,37,46,55,64,73
				.byte 2,11,20,29,38,47,56,65,74
				.byte 3,12,21,30,39,48,57,66,75
				.byte 4,13,22,31,40,49,58,67,76
				.byte 5,14,23,32,41,50,59,68,77
				.byte 6,15,24,33,42,51,60,69,78
				.byte 7,16,25,34,43,52,61,70,79
				.byte 8,17,26,35,44,53,62,71,80
		
; Boxes (tested = OK)

				.byte 0,1,2,9,10,11,18,19,20
				.byte 3,4,5,12,13,14,21,22,23
				.byte 6,7,8,15,16,17,24,25,26
				.byte 27,28,29,36,37,38,45,46,47
				.byte 30,31,32,39,40,41,48,49,50
				.byte 33,34,35,42,43,44,51,52,53
				.byte 54,55,56,63,64,65,72,73,74
				.byte 57,58,59,66,67,68,75,76,77
				.byte 60,61,62,69,70,71,78,79,80
			
				.endl
		
; Each cell in the grid intersects with 20 other cells on the grid, made up of 8 in the same row,
; 8 in the same column and 4 in the same 3x3 box. To speed up various calculations, these are 
; stored in a lookup table so that we can quickly work out which 24 cells intersect using a 
; simple loop over the Y register.

; While the order of intersecting cells is not important, they are stored as follows:
; On the same row, 8 bytes
; On the same column, 8 bytes
; In the same 3x3 box, 4 bytes

; In the table below these are broken down into three lines for clarity.
; The coordinates in brackets are (x,y).

CellIntersect	.local		; Defines cells which intersect with each cell

; Cell 0 (0,0) = OK

				.byte 1,2,3,4,5,6,7,8
				.byte 9,18,27,36,45,54,63,72
				.byte 10,11,19,20

; Cell 1 (1,0) = OK

				.byte 0,2,3,4,5,6,7,8
				.byte 10,19,28,37,46,55,64,73
				.byte 9,11,18,20

; Cell 2 (2,0) = OK

				.byte 0,1,3,4,5,6,7,8
				.byte 11,20,29,38,47,56,65,74
				.byte 9,10,18,19

; Cell 3 (3,0) = OK

				.byte 0,1,2,4,5,6,7,8
				.byte 12,21,30,39,48,57,66,75
				.byte 13,14,22,23

; Cell 4 (4,0) = OK

				.byte 0,1,2,3,5,6,7,8
				.byte 13,22,31,40,49,58,67,76
				.byte 12,14,21,23

; Cell 5 (5,0) = OK

				.byte 0,1,2,3,4,6,7,8
				.byte 14,23,32,41,50,59,68,77
				.byte 12,13,21,22

; Cell 6 (6,0) = OK

				.byte 0,1,2,3,4,5,7,8
				.byte 15,24,33,42,51,60,69,78
				.byte 16,17,25,26

; Cell 7 (7,0) = OK

				.byte 0,1,2,3,4,5,6,8
				.byte 16,25,34,43,52,61,70,79
				.byte 15,17,24,26

; Cell 8 (8,0) = OK

				.byte 0,1,2,3,4,5,6,7
				.byte 17,26,35,44,53,62,71,80
				.byte 15,16,24,25

; Cell 9 (0,1) = OK

				.byte 10,11,12,13,14,15,16,17
				.byte 0,18,27,36,45,54,63,72
				.byte 1,2,19,20

; Cell 10 (1,1) = OK

				.byte 9,11,12,13,14,15,16,17
				.byte 1,19,28,37,46,55,64,73
				.byte 0,2,18,20

; Cell 11 (2,1) = OK

				.byte 9,10,12,13,14,15,16,17
				.byte 2,20,29,38,47,56,65,74
				.byte 0,1,18,19

; Cell 12 (3,1) = OK

				.byte 9,10,11,13,14,15,16,17
				.byte 3,21,30,39,48,57,66,75
				.byte 4,5,22,23

; Cell 13 (4,1) = OK

				.byte 9,10,11,12,14,15,16,17
				.byte 4,22,31,40,49,58,67,76
				.byte 3,5,21,23

; Cell 14 (5,1) = OK

				.byte 9,10,11,12,13,15,16,17
				.byte 5,23,32,41,50,59,68,77
				.byte 3,4,21,22

; Cell 15 (6,1) = OK

				.byte 9,10,11,12,13,14,16,17
				.byte 6,24,33,42,51,60,69,78
				.byte 7,8,25,26

; Cell 16 (7,1) = OK

				.byte 9,10,11,12,13,14,15,17
				.byte 7,25,34,43,52,61,70,79
				.byte 6,8,24,26

; Cell 17 (8,1) = OK

				.byte 9,10,11,12,13,14,15,16
				.byte 8,26,35,44,53,62,71,80
				.byte 6,7,24,25

; Cell 18 (0,2) = OK

				.byte 19,20,21,22,23,24,25,26
				.byte 0,9,27,36,45,54,63,72
				.byte 1,2,10,11

; Cell 19 (1,2) = OK

				.byte 18,20,21,22,23,24,25,26
				.byte 1,10,28,37,46,55,64,73
				.byte 0,2,9,11

; Cell 20 (2,2) = OK

				.byte 18,19,21,22,23,24,25,26
				.byte 2,11,29,38,47,56,65,74
				.byte 0,1,9,10

; Cell 21 (3,2) = OK

				.byte 18,19,20,22,23,24,25,26
				.byte 3,12,30,39,48,57,66,75
				.byte 4,5,13,14

; Cell 22 (4,2) = OK

				.byte 18,19,20,21,23,24,25,26
				.byte 4,13,31,40,49,58,67,76
				.byte 3,5,12,14

; Cell 23 (5,2) = OK

				.byte 18,19,20,21,22,24,25,26
				.byte 5,14,32,41,50,59,68,77
				.byte 3,4,12,13

; Cell 24 (6,2) = OK

				.byte 18,19,20,21,22,23,25,26
				.byte 6,15,33,42,51,60,69,78
				.byte 7,8,16,17

; Cell 25 (7,2) = OK

				.byte 18,19,20,21,22,23,24,26
				.byte 7,16,34,43,52,61,70,79
				.byte 6,8,15,17

; Cell 26 (8,2) = OK

				.byte 18,19,20,21,22,23,24,25
				.byte 8,17,35,44,53,62,71,80
				.byte 6,7,15,16

; Cell 27 (0,3) = OK

				.byte 28,29,30,31,32,33,34,35
				.byte 0,9,18,36,45,54,63,72
				.byte 37,38,46,47

; Cell 28 (1,3) = OK

				.byte 27,29,30,31,32,33,34,35
				.byte 1,10,19,37,46,55,64,73
				.byte 36,38,45,47

; Cell 29 (2,3) = OK

				.byte 27,28,30,31,32,33,34,35
				.byte 2,11,20,38,47,56,65,74
				.byte 36,37,45,46

; Cell 30 (3,3) = OK

				.byte 27,28,29,31,32,33,34,35
				.byte 3,12,21,39,48,57,66,75
				.byte 40,41,49,50

; Cell 31 (4,3) = OK

				.byte 27,28,29,30,32,33,34,35
				.byte 4,13,22,40,49,58,67,76
				.byte 39,41,48,50

; Cell 32 (5,3) = OK

				.byte 27,28,29,30,31,33,34,35
				.byte 5,14,23,41,50,59,68,77
				.byte 39,40,48,49

; Cell 33 (6,3) = OK

				.byte 27,28,29,30,31,32,34,35
				.byte 6,15,24,42,51,60,69,78
				.byte 43,44,52,53

; Cell 34 (7,3) = OK

				.byte 27,28,29,30,31,32,33,35
				.byte 7,16,25,43,52,61,70,79
				.byte 42,44,51,53

; Cell 35 (8,3) = OK

				.byte 27,28,29,30,31,32,33,34
				.byte 8,17,26,44,53,62,71,80
				.byte 42,43,51,52

; Cell 36 (0,4) = OK

				.byte 37,38,39,40,41,42,43,44
				.byte 0,9,18,27,45,54,63,72
				.byte 28,29,46,47

; Cell 37 (1,4) = OK

				.byte 36,38,39,40,41,42,43,44
				.byte 1,10,19,28,46,55,64,73
				.byte 27,29,45,47

; Cell 38 (2,4) = OK

				.byte 36,37,39,40,41,42,43,44
				.byte 2,11,20,29,47,56,65,74
				.byte 27,28,45,46

; Cell 39 (3,4) = OK

				.byte 36,37,38,40,41,42,43,44
				.byte 3,12,21,30,48,57,66,75
				.byte 31,32,49,50

; Cell 40 (4,4) = OK

				.byte 36,37,38,39,41,42,43,44
				.byte 4,13,22,31,49,58,67,76
				.byte 30,32,48,50

; Cell 41 (5,4) = OK

				.byte 36,37,38,39,40,42,43,44
				.byte 5,14,23,32,50,59,68,77
				.byte 30,31,48,49

; Cell 42 (6,4) = OK

				.byte 36,37,38,39,40,41,43,44
				.byte 6,15,24,33,51,60,69,78
				.byte 34,35,52,53

; Cell 43 (7,4) = OK

				.byte 36,37,38,39,40,41,42,44
				.byte 7,16,25,34,52,61,70,79
				.byte 33,35,51,53

; Cell 44 (8,4) = OK

				.byte 36,37,38,39,40,41,42,43
				.byte 8,17,26,35,53,62,71,80
				.byte 33,34,51,52

; Cell 45 (0,5) = OK

				.byte 46,47,48,49,50,51,52,53
				.byte 0,9,18,27,36,54,63,72
				.byte 28,29,37,38

; Cell 46 (1,5) = OK

				.byte 45,47,48,49,50,51,52,53
				.byte 1,10,19,28,37,55,64,73
				.byte 27,29,36,38

; Cell 47 (2,5) = OK

				.byte 45,46,48,49,50,51,52,53
				.byte 2,11,20,29,38,56,65,74
				.byte 27,28,36,37

; Cell 48 (3,5) = OK

				.byte 45,46,47,49,50,51,52,53
				.byte 3,12,21,30,39,57,66,75
				.byte 31,32,40,41

; Cell 49 (4,5) = OK

				.byte 45,46,47,48,50,51,52,53
				.byte 4,13,22,31,40,58,67,76
				.byte 30,32,39,41

; Cell 50 (5,5) = OK

				.byte 45,46,47,48,49,51,52,53
				.byte 5,14,23,32,41,59,68,77
				.byte 30,31,39,40

; Cell 51 (6,5) = OK

				.byte 45,46,47,48,49,50,52,53
				.byte 6,15,24,33,42,60,69,78
				.byte 34,35,43,44

; Cell 52 (7,5) = OK

				.byte 45,46,47,48,49,50,51,53
				.byte 7,16,25,34,43,61,70,79
				.byte 33,35,42,44

; Cell 53 (8,5) = OK

				.byte 45,46,47,48,49,50,51,52
				.byte 8,17,26,35,44,62,71,80
				.byte 33,34,42,43

; Cell 54 (0,6) = OK

				.byte 55,56,57,58,59,60,61,62
				.byte 0,9,18,27,36,45,63,72
				.byte 64,65,73,74

; Cell 55 (1,6) = OK

				.byte 54,56,57,58,59,60,61,62
				.byte 1,10,19,28,37,46,64,73
				.byte 63,65,72,74

; Cell 56 (2,6) = OK

				.byte 54,55,57,58,59,60,61,62
				.byte 2,11,20,29,38,47,65,74
				.byte 63,64,72,73

; Cell 57 (3,6) = OK

				.byte 54,55,56,58,59,60,61,62
				.byte 3,12,21,30,39,48,66,75
				.byte 67,68,76,77

; Cell 58 (4,6) = OK

				.byte 54,55,56,57,59,60,61,62
				.byte 4,13,22,31,40,49,67,76
				.byte 66,68,75,77

; Cell 59 (5,6) = OK

				.byte 54,55,56,57,58,60,61,62
				.byte 5,14,23,32,41,50,68,77
				.byte 66,67,75,76

; Cell 60 (6,6) = OK
				
				.byte 54,55,56,57,58,59,61,62
				.byte 6,15,24,33,42,51,69,78
				.byte 70,71,79,80

; Cell 61 (7,6) = OK

				.byte 54,55,56,57,58,59,60,62
				.byte 7,16,25,34,43,52,70,79
				.byte 69,71,78,80

; Cell 62 (8,6) = OK

				.byte 54,55,56,57,58,59,60,61
				.byte 8,17,26,35,44,53,71,80
				.byte 69,70,78,79

; Cell 63 (0,7) = OK

				.byte 64,65,66,67,68,69,70,71
				.byte 0,9,18,27,36,45,54,72
				.byte 55,56,73,74

; Cell 64 (1,7) = OK

				.byte 63,65,66,67,68,69,70,71
				.byte 1,10,19,28,37,46,55,73
				.byte 54,56,72,74

; Cell 65 (2,7) = OK

				.byte 63,64,66,67,68,69,70,71
				.byte 2,11,20,29,38,47,56,74
				.byte 54,55,72,73

; Cell 66 (3,7) = OK

				.byte 63,64,65,67,68,69,70,71
				.byte 3,12,21,30,39,48,57,75
				.byte 58,59,76,77

; Cell 67 (4,7) = OK

				.byte 63,64,65,66,68,69,70,71
				.byte 4,13,22,31,40,49,58,76
				.byte 57,59,75,77

; Cell 68 (5,7) = OK

				.byte 63,64,65,66,67,69,70,71
				.byte 5,14,23,32,41,50,59,77
				.byte 57,58,75,76

; Cell 69 (6,7) = OK

				.byte 63,64,65,66,67,68,70,71
				.byte 6,15,24,33,42,51,60,78
				.byte 61,62,79,80

; Cell 70 (7,7) = OK

				.byte 63,64,65,66,67,68,69,71
				.byte 7,16,25,34,43,52,61,79
				.byte 60,62,78,80

; Cell 71 (8,7) = OK

				.byte 63,64,65,66,67,68,69,70
				.byte 8,17,26,35,44,53,62,80
				.byte 60,61,78,79

; Cell 72 (0,8) = OK

				.byte 73,74,75,76,77,78,79,80
				.byte 0,9,18,27,36,45,54,63
				.byte 55,56,64,65

; Cell 73 (1,8) = OK

				.byte 72,74,75,76,77,78,79,80
				.byte 1,10,19,28,37,46,55,64
				.byte 54,56,63,65

; Cell 74 (2,8) = OK

				.byte 72,73,75,76,77,78,79,80
				.byte 2,11,20,29,38,47,56,65
				.byte 54,55,63,64

; Cell 75 (3,8) = OK

				.byte 72,73,74,76,77,78,79,80
				.byte 3,12,21,30,39,48,57,66
				.byte 58,59,67,68

; Cell 76 (4,8) = OK

				.byte 72,73,74,75,77,78,79,80
				.byte 4,13,22,31,40,49,58,67
				.byte 57,59,66,68

; Cell 77 (5,8) = OK

				.byte 72,73,74,75,76,78,79,80
				.byte 5,14,23,32,41,50,59,68
				.byte 57,58,66,67

; Cell 78 (6,8) = OK

				.byte 72,73,74,75,76,77,79,80
				.byte 6,15,24,33,42,51,60,69
				.byte 61,62,70,71

; Cell 79 (7,8) = OK

				.byte 72,73,74,75,76,77,78,80
				.byte 7,16,25,34,43,52,61,70
				.byte 60,62,69,71

; Cell 80 (8,8) = OK
	
				.byte 72,73,74,75,76,77,78,79
				.byte 8,17,26,35,44,53,62,71
				.byte 60,61,69,70
	
				.endl

; Masks used to knockout candidate values from cells.

Mask1To8		.local
				.byte %11111110
				.byte %11111101
				.byte %11111011
				.byte %11110111
				.byte %11101111
				.byte %11011111
				.byte %10111111
				.byte %01111111
				.endl

; Masks used to test if candidate bits are set.
; Essentially the inverses of values in Mask1To8.

Bit1To8			.local
				.byte %00000001
				.byte %00000010
				.byte %00000100
				.byte %00001000
				.byte %00010000
				.byte %00100000
				.byte %01000000
				.byte %10000000
				.endl
		
; Table of powers of ten, split into low and high bytes for use in conversion of numbers to decimal strings.
; Low100 is the start point for byte conversion, which needs less data.

Power10			.local
Low				.byte <10000
				.byte <1000
Low100			.byte <100
				.byte <10
High			.byte >10000
				.byte >1000
				.byte >100
				.byte >10			
				.endl

PALTicks		.local
Low				.byte <50000
				.byte <5000
				.byte <500
				.byte <50
				.byte <5
High			.byte >50000
				.byte >5000
				.byte >500
				.byte >50
				.byte >5
				.endl
					
NTSCTicks		.local
Low				.byte <60000
				.byte <6000
				.byte <600
				.byte <60
				.byte <6
High			.byte >60000
				.byte >6000
				.byte >600
				.byte >60
				.byte >6
				.endl
					
; Map cell index to screen row.

CellROWCRS		.local
				:9 .byte Constants.Gridy+1
				:9 .byte Constants.Gridy+3
				:9 .byte Constants.Gridy+5
				:9 .byte Constants.Gridy+7
				:9 .byte Constants.Gridy+9
				:9 .byte Constants.Gridy+11
				:9 .byte Constants.Gridy+13
				:9 .byte Constants.Gridy+15
				:9 .byte Constants.Gridy+17
				.endl
		
; Map cell index to screen column.

CellCOLCRS		.local
				:9 .byte Constants.GridX+1,Constants.GridX+3,Constants.GridX+5,Constants.GridX+7,Constants.GridX+9,Constants.GridX+11,Constants.GridX+13,Constants.GridX+15,Constants.GridX+17	
				.endl
			
Errors			.local
Low				.byte <.adr(Error0)
				.byte <.adr(Error128)
				.byte <.adr(Error129)
				.byte <.adr(Error130)
				.byte <.adr(Error131)
				.byte <.adr(Error132)
				.byte <.adr(Error133)
				.byte <.adr(Error134)
				.byte <.adr(Error135)
				.byte <.adr(Error136)
				.byte <.adr(Error137)
				.byte <.adr(Error138)
				.byte <.adr(Error139)
				.byte <.adr(Error140)
				.byte <.adr(Error141)
				.byte <.adr(Error142)
				.byte <.adr(Error143)
				.byte <.adr(Error144)
				.byte <.adr(Error145)
				.byte <.adr(Error146)
				.byte <.adr(Error147)
				.byte <.adr(Error160)
				.byte <.adr(Error161)
				.byte <.adr(Error162)
				.byte <.adr(Error163)
				.byte <.adr(Error164)
				.byte <.adr(Error165)
				.byte <.adr(Error166)
				.byte <.adr(Error167)
				.byte <.adr(Error168)
				.byte <.adr(Error169)
				.byte <.adr(Error170)
				.byte <.adr(Error171)
				.byte <.adr(Error172)
				.byte <.adr(Error173)
High			.byte >.adr(Error0)
				.byte >.adr(Error128)
				.byte >.adr(Error129)
				.byte >.adr(Error130)
				.byte >.adr(Error131)
				.byte >.adr(Error132)
				.byte >.adr(Error133)
				.byte >.adr(Error134)
				.byte >.adr(Error135)
				.byte >.adr(Error136)
				.byte >.adr(Error137)
				.byte >.adr(Error138)
				.byte >.adr(Error139)
				.byte >.adr(Error140)
				.byte >.adr(Error141)
				.byte >.adr(Error142)
				.byte >.adr(Error143)
				.byte >.adr(Error144)
				.byte >.adr(Error145)
				.byte >.adr(Error146)
				.byte >.adr(Error147)
				.byte >.adr(Error160)
				.byte >.adr(Error161)
				.byte >.adr(Error162)
				.byte >.adr(Error163)
				.byte >.adr(Error164)
				.byte >.adr(Error165)
				.byte >.adr(Error166)
				.byte >.adr(Error167)
				.byte >.adr(Error168)
				.byte >.adr(Error169)
				.byte >.adr(Error170)
				.byte >.adr(Error171)
				.byte >.adr(Error172)
				.byte >.adr(Error173)
Length			.byte .len(Error0)
				.byte .len(Error128)
				.byte .len(Error129)
				.byte .len(Error130)
				.byte .len(Error131)
				.byte .len(Error132)
				.byte .len(Error133)
				.byte .len(Error134)
				.byte .len(Error135)
				.byte .len(Error136)
				.byte .len(Error137)
				.byte .len(Error138)
				.byte .len(Error139)
				.byte .len(Error140)
				.byte .len(Error141)
				.byte .len(Error142)
				.byte .len(Error143)
				.byte .len(Error144)
				.byte .len(Error145)
				.byte .len(Error146)
				.byte .len(Error147)
				.byte .len(Error160)
				.byte .len(Error161)
				.byte .len(Error162)
				.byte .len(Error163)
				.byte .len(Error164)
				.byte .len(Error165)
				.byte .len(Error166)
				.byte .len(Error167)
				.byte .len(Error168)
				.byte .len(Error169)
				.byte .len(Error170)
				.byte .len(Error171)
				.byte .len(Error172)
				.byte .len(Error173)
Number			.byte 0,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,160,161,162,163,164,165,166,167,168,169,170,171,172,173
				.endl
				
; New for v0.4, additional tables of cell offsets to support additional algorithm.
; These tables generated by a quick and dirty C# program to save time.

Slices			.local
In1				.byte 0,27,54,1,28,55,2,29,56,3,30,57,4,31,58,5,32,59,6,33,60,7,34,61,8,35,62,0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63,66,69,72,75,78
In2				.byte 9,36,63,10,37,64,11,38,65,12,39,66,13,40,67,14,41,68,15,42,69,16,43,70,17,44,71,1,4,7,10,13,16,19,22,25,28,31,34,37,40,43,46,49,52,55,58,61,64,67,70,73,76,79
In3				.byte 18,45,72,19,46,73,20,47,74,21,48,75,22,49,76,23,50,77,24,51,78,25,52,79,26,53,80,2,5,8,11,14,17,20,23,26,29,32,35,38,41,44,47,50,53,56,59,62,65,68,71,74,77,80
NotIn1			.byte 1,28,55,0,27,54,0,27,54,4,31,58,3,30,57,3,30,57,7,34,61,6,33,60,6,33,60,9,12,15,0,3,6,0,3,6,36,39,42,27,30,33,27,30,33,63,66,69,54,57,60,54,57,60
NotIn2			.byte 10,37,64,9,36,63,9,36,63,13,40,67,12,39,66,12,39,66,16,43,70,15,42,69,15,42,69,10,13,16,1,4,7,1,4,7,37,40,43,28,31,34,28,31,34,64,67,70,55,58,61,55,58,61
NotIn3			.byte 19,46,73,18,45,72,18,45,72,22,49,76,21,48,75,21,48,75,25,52,79,24,51,78,24,51,78,11,14,17,2,5,8,2,5,8,38,41,44,29,32,35,29,32,35,65,68,71,56,59,62,56,59,62
NotIn4			.byte 2,29,56,2,29,56,1,28,55,5,32,59,5,32,59,4,31,58,8,35,62,8,35,62,7,34,61,18,21,24,18,21,24,9,12,15,45,48,51,45,48,51,36,39,42,72,75,78,72,75,78,63,66,69
NotIn5			.byte 11,38,65,11,38,65,10,37,64,14,41,68,14,41,68,13,40,67,17,44,71,17,44,71,16,43,70,19,22,25,19,22,25,10,13,16,46,49,52,46,49,52,37,40,43,73,76,79,73,76,79,64,67,70
NotIn6			.byte 20,47,74,20,47,74,19,46,73,23,50,77,23,50,77,22,49,76,26,53,80,26,53,80,25,52,79,20,23,26,20,23,26,11,14,17,47,50,53,47,50,53,38,41,44,74,77,80,74,77,80,65,68,71
Knockout1		.byte 27,0,0,28,1,1,29,2,2,30,3,3,31,4,4,32,5,5,33,6,6,34,7,7,35,8,8,3,0,0,12,9,9,21,18,18,30,27,27,39,36,36,48,45,45,57,54,54,66,63,63,75,72,72
Knockout2		.byte 36,9,9,37,10,10,38,11,11,39,12,12,40,13,13,41,14,14,42,15,15,43,16,16,44,17,17,4,1,1,13,10,10,22,19,19,31,28,28,40,37,37,49,46,46,58,55,55,67,64,64,76,73,73
Knockout3		.byte 45,18,18,46,19,19,47,20,20,48,21,21,49,22,22,50,23,23,51,24,24,52,25,25,53,26,26,5,2,2,14,11,11,23,20,20,32,29,29,41,38,38,50,47,47,59,56,56,68,65,65,77,74,74
Knockout4		.byte 54,54,27,55,55,28,56,56,29,57,57,30,58,58,31,59,59,32,60,60,33,61,61,34,62,62,35,6,6,3,15,15,12,24,24,21,33,33,30,42,42,39,51,51,48,60,60,57,69,69,66,78,78,75
Knockout5		.byte 63,63,36,64,64,37,65,65,38,66,66,39,67,67,40,68,68,41,69,69,42,70,70,43,71,71,44,7,7,4,16,16,13,25,25,22,34,34,31,43,43,40,52,52,49,61,61,58,70,70,67,79,79,76
Knockout6		.byte 72,72,45,73,73,46,74,74,47,75,75,48,76,76,49,77,77,50,78,78,51,79,79,52,80,80,53,8,8,5,17,17,14,26,26,23,35,35,32,44,44,41,53,53,50,62,62,59,71,71,68,80,80,77
				.endl
				.endl