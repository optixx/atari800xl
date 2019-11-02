; Use and redistribution of this source code is governed by the Creative Commons license Attribution-NonCommercial-ShareAlike 4.0 International
; 1K ATASCII Shooter - Frederik Holst 2014/2016

			run start

			RTCLOK = $14
			ATRACT = $4d

			VDSLST = $200
			SDMCTL = $22f
			SDLSTL = $230
			GPRIOR = $26f
			
			STICK0 = $278
			STRIG0 = $284
			PCOLR0 = $2c0
			PCOLR1 = $2c1
			PCOLR2 = $2c2
			CHBAS = $02f4

			HPOSP0 = $d000
			M2PF = $d002
			HPOSP1 = $d001
			HPOSM2 = $d006
			P0PF = $d004
			P1PF = $d005
			SIZEM = $d00c
			COLPM0 = $d012
			COLBK = $d01a
			COLPF0 = $d016
			GRACTL = $d01d
			HITCLR = $d01e
			AUDF1 = $d200
			AUDC1 = $d201
			AUDF2 = $d202
			AUDC2 = $d203
			AUDF3 = $d204
			AUDC3 = $d205
			AUDCTL = $d208
			RANDOM = $d20a
			HSCROL = $d404
			PMBASE = $d407
			NMIEN = $d40e
			WSYNC = $d40a

			PMBASEADR = NEWADR+$400	; Player/missile data locations
			PMDATA = PMBASEADR+$200
			PMDATA2 = PMBASEADR+$280
			MDATA = PMBASEADR+$180
			PMSHAPESIZE = PMSHAPE2-PMSHAPE+1
			STARTPOSH = 60			; Horizontal starting position of players
			STARTPOSV = 56			; Vertical starting position of players
			
			NEWADR = $3000			; Address for player/missile data etc.
			ANTICMODE = $57+$80		; Standard ANTIC mode 
			WIDTH = 32				; Width of (virtual) screen 
			BGCOL = 12				; Number of background lines to be coloured in DLI
			LINES = 8				; Number of scrolling lines
			CLOCKS = 8				; Fine scrolling clocks

			P0POS = $80				; Vertical position of player 1
			P0POSH = $81			; Horizontal position of player 1
			M2POS = $82				; Vertical position of missile
			M2POSH = $83			; Horizontal position of missile, initialized with horizontal position of player 1 plus 6
			MVSRCE = $84			; Source pointer for moveing subroutine
			MVDEST = $86			; Destination pointer for moveing subroutine
			LENPTR = $88			; Length of block move, normally .word, in this case .byte is enough
			BGCOUNTER = $89			; Counter for background colors, initialized with number of lines
			CHRADR = $8a			; Pointer to charset
			LMSV = $8c				; Pointer to screen memory (Load Memory Scan)
			DELPOSH = $8e			; Horizontal location of character to be removed
			DELPOSV = $8f			; Vertical location of character to be removed
			SPEED = $90				; Scrolling speed
			TIMER = $91				; Timer variable
			SHOTSPEED = $92			; Speed of Missile
			TEMP = $93				; Temporary variable


			org $94
VBIFLAG		.byte 0					; VBI execute flag
SHOTFIRED	.byte 0					; Shot fired flag
LMSC		.byte <line2+WIDTH		; Counter until one screen has scrolled completely (low byte of screen memory + width of screen)
SCROLLPOS	.byte 0					; Fine scrolling position
SCROLLCOUNT	.byte 0					; Coarse scrolling position

; BGCOUNTER	.byte BGCOL				; Counter for background colors, initialized with number of lines
; P0POS		.byte 0					; Vertical position of player 1
; P0POSH		.byte STARTPOSH			; Horizontal position of player 1
; M2POS		.byte 0					; Vertical position of missile
; M2POSH		.byte STARTPOSH+6		; Horizontal position of missile, initialized with horizontal position of player 1 plus 6
; MVSRCE		.word 0					; Source pointer for moveing subroutine
; MVDEST		.word 0					; Destination pointer for moveing subroutine
; LENPTR		.byte 0					; Length of block move, normally .word, in this case .byte is enough
; CHRADR		.word 0					; Pointer to charset
; LMSV		.word 0					; Pointer to screen memory (Load Memory Scan) 
; DELPOSH		.byte 0					; Horizontal location of character to be removed
; DELPOSV		.byte 0					; Vertical location of character to be removed
; SPEED		.byte 0					; Scrolling speed
; TIMER		.byte 1					; Timer variable
; TEMP		.byte 0					; Temporary variable
; SHOTSPEED	.byte 3					; Speed of Missile

DLIST		.byte $70,$70,$70,$70+80,ANTICMODE-$10
			.word line1
			.byte $70+$80
			.byte ANTICMODE
LMS1		.word line2
			.byte ANTICMODE
			.word line3
			.byte ANTICMODE
			.word line4
			.byte ANTICMODE
			.word line5
			.byte ANTICMODE
			.word line6
			.byte ANTICMODE
			.word line7
			.byte ANTICMODE
			.word line8
			.byte ANTICMODE
			.word line9
			.byte $70+$80
			.byte ANTICMODE-$10
			.word line10
			.byte $41
		    .word DLIST

GAMEOVERTXT	.byte "GAME OVER"

PMSHAPE		.byte %00000000
			.byte %11100000
			.byte %11000000
			.byte %01110000
			.byte %00101100
			.byte %00111110
			.byte %00000001
			.byte %00111110
			.byte %00101100
			.byte %01110000
			.byte %11000000
			.byte %11100000
;			.byte %00000000		; Byte can be saved as PMSHAPESIZE has been increased by one, so first zero of PMSHAPE2 can be reused :)...
			
PMSHAPE2	.byte %00000000
			.byte %00110000
			.byte %00000000
			.byte %00000000
			.byte %00110000
ANTRIEB		.byte %10111100
			.byte %01111111
			.byte %10111100
			.byte %00110000
			.byte %00000000
MSHAPE		.byte %00000000		; same as above, this time stealing from PMSHAPE2 and TABLE :)
			.byte %00110000

;MSHAPE		.byte %00000000
;			.byte %00110000
;			.byte %00000000		; same as above, this time stealing from TABLE :)

TABLE		.byte 0,160,162,144,146,148,150,152,154,156,158,162,160

;SOUND		.byte $79,$d9,$66,$b6,$51,$99
;SOUND		.byte $f3,$d9,$c1,$b6,$a2,$90
;SOUND		.byte $79,$d9,$60,$b6,$51,$90

;			org SCORETXT+20
HIGHTXT		.byte "HIGH"
SCORETXT	.byte "SCORE:0000"	; tricky, because SCORETXT reaches into stack area >$100 when you use SOUND above - but works :)...

			org $2000
start				
			lda #43
			sta SDMCTL

			lda #<DLIST			; set up display list
			sta SDLSTL
;##ASSERT a = $99
;##TRACE "a = %d" db(SDLSTL)
			lda #>DLIST
			sta SDLSTL+1

			lda #<DLI			; set up DLI
			sta VDSLST
			lda #>DLI
			sta VDSLST+1
			lda #192
			sta NMIEN
			
setVBI		ldy #<VBI			; set up VBI
			ldx #>VBI
			lda #6
			sta RTCLOK
			jsr $e45c

/*
			lda LMS1			; set counter flag for end of (virtual) screen
			clc
			adc #WIDTH
			sta LMSC
*/

restart		
/*
			lda RTCLOK
			cmp #25
			bne checktrig
nextvoice	lda #$a8
			sta AUDC1
			sta AUDC2
;			sta AUDC3
			lda RANDOM
			and #%00000011
			tax
			lda SOUND,x
;			lsr
			sta AUDF1
;			lsr
;			sta AUDF3
			lda SOUND+2,x
			sta AUDF2
			lda #0
			sta RTCLOK
*/

checktrig	lda STRIG0			; wait for trigger before game starts
			bne restart
			sta ATRACT			; use 0 to disable ATTRACT mode
;			sta AUDC2
;			sta AUDC3
			tax					; save 0 for later
waitrelease	lda STRIG0
			beq waitrelease		; button released?
			sta SPEED			; use 1 to set to lower speed (=1)

			lda #3				; set player configurations 35 / 232
			sta PCOLR1
			sta GRACTL
			sta SHOTSPEED
			lda #8
			sta PCOLR0
			asl					; 16
			sta SIZEM
			asl					; 32
			sta GPRIOR
			lda #>PMDATA
			sta PMBASE
			
			lda LENPTR			; If LENPTR has not been used yet (i.e. first time the game starts), then do not clear playfield
			beq playerinit

			txa					; get back 0 from above
wipe		sta line2,x
			sta line2+256,x
;			sta line2+512,x
			sta PMDATA,x
			dex
			bne wipe
			
playerinit	sta HITCLR
			lda #STARTPOSV
			sta P0POS
			lda #STARTPOSH
			sta P0POSH
			sta VBIFLAG

			ldy #9				; display score
resetscore	lda SCORETXT,y
			sta line10+2,y
			dey
			bpl resetscore

main		
			lda P0PF			; Collision between player and playfield?
			beq highscore		; if not, then continue game
gameover						; otherwise: game over
			lda #0
			sta AUDC2			; stop missile sound
			lda #214			; move missile out of screen
			sta HPOSM2
			sta M2POSH
			lda #$8f
			sta AUDC1
			sta RTCLOK
waitsound	lda RTCLOK			; play crash sound for 255-143 frames (i.e. aprrox. 2 second)
			sta AUDF1
			sta PCOLR0			; and flash player accordingly
			bne waitsound		; until RTCLOK = 0
			sta AUDC1			; then turn crash sound off

overtext	ldy #9
textend		lda GAMEOVERTXT,y	; output GAME OVER text
			sta line10+2,y
			dey
			bpl textend

			jmp restart
				
highscore	tay					; Y = 0 after playfield collision check
checkhigh	lda line10+7,y
			cmp line10+17,y
			bcc prepmove
			bne sethigh
			iny
			cpy #4
			bne checkhigh
sethigh		ldy #4
copyscore	lda line10+7,y
			sta line10+17,y
			dey
			bpl copyscore
			ldy #3
hightext	lda HIGHTXT,y
			sta line10+13,y
			dey
			bpl hightext

prepmove	lda #<PMSHAPE		; prepare move of player 1
			sta MVSRCE
;			lda #>PMSHAPE
;			sta MVSRCE+1
			
			lda P0POSH
			sta HPOSP0
			sta HPOSP1

movepm1		lda #<PMDATA		; move player 1
			clc
			adc P0POS
			sta MVDEST
			lda #>PMDATA
			sta MVDEST+1
			lda #<PMSHAPESIZE
			sta LENPTR
;			lda #>PMSHAPESIZE
;			sta LENPTR+1
			jsr move

			lda #<PMSHAPE2		; prepare move of player 2
			sta MVSRCE
;			lda #>PMSHAPE2
;			sta MVSRCE+1

movepm2		lda #<PMDATA2		; move player 2
			clc
			adc P0POS
			sta MVDEST
;			lda #>PMDATA2		; as PMDATA2 is in the same page as PMDATA, we can save a few bytes here...
;			sta MVDEST+1
			lda #<PMSHAPESIZE
			sta LENPTR
;			lda #>PMSHAPESIZE
;			sta LENPTR+1
			jsr move
			
			lda #<MSHAPE		; prepare move of missile
			sta MVSRCE
;			lda #>MSHAPE
;			sta MVSRCE+1

movem		lda SHOTFIRED		; has missile been fired?
			beq noshot
			lda #<MDATA			; then move missile
			clc
			adc M2POS
			sta MVDEST
			lda #>MDATA
			sta MVDEST+1
			lda #3
			sta LENPTR
;			lda #0
;			sta LENPTR+1
			lda M2POSH
			sbc P0POSH			; use horizontal missile position
			sta AUDF2			; to generate missile flying sound
			lda #$6a
			sta AUDC2
			jsr move
noshot
			lda TIMER			; read timer variable (1/50 seconds)
wait		cmp TIMER			; has it changed?
			beq wait			; if not then wait

			lda STRIG0			; fire button pressed?
			bne checkmove
			jsr shot			; yes? then initiate shot

checkmove	lda STICK0
			tay
			and #%00000001
			bne down
			ldx P0POS
			cpx #31
			bcc left
			dec P0POS
down		tya
			and #%00000010
			bne left
			ldx P0POS
			cpx #82
			bcs left
			inc P0POS
left		tya
			and #%00000100
			bne right
			ldx P0POSH
			cpx #45
			bcc endmove
			dec P0POSH
right		tya
			and #%00001000
			bne endmove
			ldx P0POSH
			cpx #200
			bcs endmove
			inc P0POSH
endmove		

			lda SCROLLCOUNT
			cmp #8
			bne noise

			lda #0
			sta SCROLLCOUNT
			lda CHBAS
			clc
			adc #2
			sta CHRADR+1
			lda RANDOM
			asl
			asl
			asl
			sta CHRADR
						
			lda LMS1		; store LMS in zeropage
			clc
			adc #24
			sta LMSV
			lda LMS1+1
			adc #0
			sta LMSV+1
			ldy #0
			lda #8
			sta TEMP
nextbyte	clc
			ldx #8
			lda (CHRADR),y
nextbit		asl
			pha
			bcc setblank
			lda #"O"
			bcs checkbit	
setblank	lda #" "
checkbit	sta (LMSV),y
			lda LMSV
			clc
			adc #1
			bcc singlebyte2
			inc LMSV+1
singlebyte2	sta LMSV
			pla
			dex
			bne nextbit
			
			lda LMSV
			clc
			adc #WIDTH*2+1-9
			bcc singlebyte
			inc LMSV+1
singlebyte	sta LMSV

			iny
			dec TEMP
			lda TEMP
			bne nextbyte

noise
			lda P0POS
			sta AUDF1
			lda #$83
			sta AUDC1

			lda SHOTFIRED
			bne delchar
			jmp noshot2
delchar			
			lda M2PF
			beq nocoll

			lda M2POSH
			sec
			sbc #$1e
			sbc SCROLLPOS
			lsr
			lsr
			lsr
			sta DELPOSH
			tay					; Y = DELPOSH

			lda M2POS
			sec
			sbc #$1d
			lsr
			lsr
			lsr
			sta DELPOSV
			tax					; X = DELPOSV
			
;			line2+(width*2+1)*DELPOSV

			lda LMS1
			sta LMSV
			lda LMS1+1
			sta LMSV+1
			cpx #0
			beq clearchar
nextline	lda LMSV
			clc
			adc #WIDTH*2+1
			bcc onebyte
			inc LMSV+1
onebyte		sta LMSV
			dex
			bne nextline
			
clearchar	lda #" "
			sta (LMSV),y

			ldy #2				; increase score if stone is hit
scoreloop	lda line10+8,y
			clc
			adc #$01
			cmp #":"
			bne writescore
			lda #"0"
			sta line10+8,y
			dey
			bpl scoreloop
writescore	sta line10+8,y
			cpy #0				; If score >= 100 then double scrolling speed
			bne resmissile
			cmp #"1"
			bne resmissile
			stx SPEED			; x is still zero from above
			inc SHOTSPEED		; increase shooting speed	

resmissile	lda #211
			sta M2POSH
			sta HITCLR
nocoll			
			lda M2POSH
;			clc
			adc SHOTSPEED
			sta M2POSH
			sta HPOSM2
			sta PCOLR2
			cmp #212
			bcc noshot2
			lda #0
			sta AUDC2
			tax
			ldy #$80
clearm		sta MDATA,y			; clear missile
			dey
			bne clearm
			jsr contshot
			stx SHOTFIRED
noshot2
			jmp main

shot		lda SHOTFIRED
			cmp #1
			bne contshot
			rts
contshot	inc SHOTFIRED		; SHOTFIRED = 1
			lda P0POS
			clc
			adc #5
			sta M2POS
			lda P0POSH
			sta M2POSH
			rts

move		ldy #0
/*								; Move blocks are less than 256 bytes in this program, so this part can be skipped
			ldx LENPTR+1
			beq mvpart
mvpage		lda (MVSRCE),y
			sta (MVDEST),y
			iny
			bne mvpage
			inc MVSRCE+1
			inc MVDEST+1
			dex
			bne mvpage
*/
			sty MVSRCE+1
mvpart		ldx LENPTR
;			beq mvexit
mvlast		lda (MVSRCE),y
			sta (MVDEST),y
			iny
			dex
			bne mvlast
mvexit		rts

VBI			lda #BGCOL				; reset color counter for DLI each new frame
			sta BGCOUNTER
			lda TIMER				; Timer alternates between 1 and 2, every 1/50th second
			eor #%00000011
			sta TIMER

			ldx #2
animate		lda ANTRIEB,x
			eor #%11000000
			sta ANTRIEB,x
			dex
			bpl animate

			lda P0PF
			bne exitvbi
			lda VBIFLAG
			beq exitvbi
			lda SCROLLPOS
			sta HSCROL
			lda TIMER
			and SPEED
			bne exitvbi
			dec SCROLLPOS
			bpl exitvbi

setmove		lda LMS1
			cmp LMSC
			bne coarsescroll

			ldx #(LINES-1)*3		; rollover playfield
rollover	lda LMS1+1,x
			sta LMSV+1
			lda LMS1,x
			sta LMSV
			sec
			sbc #WIDTH
			bcs byteonly
			dec LMS1+1,x
byteonly	sta LMS1,x

			sta MVDEST
			lda LMS1+1,x
			sta MVDEST+1
			ldy #WIDTH
mirror		lda (LMSV),y
			sta (MVDEST),y
			dey
			bpl mirror		
			dex
			dex
			dex
			bpl rollover

coarsescroll					; coarse scroll
			inc SCROLLCOUNT
			ldx #(LINES-1)*3
nextcs		inc LMS1,x
			bne done
			inc LMS1+1,x
done		dex
			dex
			dex
			bpl nextcs
			lda #CLOCKS
			sta SCROLLPOS
			sta HSCROL	
			dec SCROLLPOS

exitvbi		jmp $e45f

DLI			pha
			txa
			pha
;			tya
;			pha
			ldx BGCOUNTER
			lda TABLE,x
			sta WSYNC
			sta COLBK
			ldx #7
pfloop		lda TABLE+3,x
			sbc #125
			sta WSYNC
			sta COLPF0			
			dex
			bne pfloop
			dec BGCOUNTER
exitdli		pla
;			tay
;			pla
			tax
			pla
			rti
			
line1		.byte "   1K ATASCII BLASTER"
			line2 = line1+WIDTH*2+1
			line3 = line2+WIDTH*2+1
			org line2+3
			.byte "F.HOLST+U.PETERSEN"
			line4 = line3+WIDTH*2+1
			org line4+8
			.byte "(P) 2014"
			line5 = line4+WIDTH*2+1
			line6 = line5+WIDTH*2+1
			line7 = line6+WIDTH*2+1
			line8 = line7+WIDTH*2+1
			line9 = line8+WIDTH*2+1
			org line9+6
			.byte "ABBUC SWC '16"			
			line10 = line9+WIDTH*2+1

