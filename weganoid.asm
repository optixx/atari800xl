ADRPM   = $B800
ZSADR   = $5000
MAP     = $5400
MOD     = 6
SOURCE  = $F0
DEST    = $F2

SDMCTL  = $022F
STICK0  = $0278
GPRIOR  = $026F

PCOLR0  = $02C0
STRIG0  = $D010
CHBAS   = $02F4
SDLSTL  = $0230
HPOSP0  = $D000
SIZEP0  = $D008
GRACTL  = $D01D
RANDOM  = $D20A
PMBASE  = $D407
setVBV  = $E45C
XITVBV  = $E462




    *=$A800

    jmp start

dlist
    .byte   $70, $70, $70, (MOD+$40)
    .word   MAP
    .byte   MOD, MOD, MOD, MOD ,MOD
    .byte   MOD, MOD, MOD, MOD ,MOD
    .byte   MOD, MOD, MOD, MOD ,MOD
    .byte   MOD, MOD, MOD, MOD ,MOD
    .byte   MOD, MOD, MOD,$41
    .word   dlist

dltxt
    .byte   $70, $70, $70, $70, $70
    .byte   $70, $70, $70, (MOD+$40)
    .word   ttxt
    .byte   $70, MOD, $70, MOD, $41
    .word   dltxt

ttxt
    .sbyte "------WEGANOID------"
    .sbyte "----ATARI MAGAZIN---"
    .sbyte "---KNOPF DRUECKEN---"


playerx
    .byte 0
px
    .byte 0
py
    .byte 0
vx
    .byte 0
vy
    .byte 0
xmaske
    .byte 0
ymaske
    .byte 0
count
    .byte 0
flag
    .byte 0
point
    .byte 0


start
    lda     #$e0
    sta     CHBAS
    lda     #<dltxt
    ldx     #>dltxt
    sta     SDLSTL
    stx     SDLSTL + 1

; playfield generate
    lda     #<MAP
    sta     DEST
    lda     #>MAP
    sta     DEST + 1
    lda     #0
    sta     count

nxtzeil
    ldx     count
    lda     pfield, x
    asl
    tax
    lda     ztab, x
    sta     SOURCE
    lda     ztab + 1, x
    sta     SOURCE + 1
    ldy     #19
nxtbyt
    lda     (SOURCE), y
    sta     (DEST), y
    dey
    bpl     nxtbyt
    clc
    lda     DEST
    adc     #20
    sta     DEST
    bcc     s1
    inc     DEST+1
s1
    inc     count
    lda     count
    cmp     #24
    bne     nxtzeil

; charset init

    lda     #0
    tax
nxtclr
    sta     ZSADR, x
    sta     ZSADR + 256, x
    inx
    bne     nxtclr
    ldx     #23
nxtzs
    lda     charset, x
    sta     ZSADR, x
    dex
    bpl     nxtzs

wait
    lda     STRIG0
    bne     wait

; game start

    lda     #>ZSADR
    sta     CHBAS
    lda     #<dlist
    ldx     #>dlist
    sta     SDLSTL
    stx     SDLSTL+1

    jsr     initpm

    lda     #151
    sta     py
    lda     RANDOM
    and     #$7f
    clc
    adc     #16
    sta     px
    lda     #1
    sta     vx
    lda     #$fe 
    sta     vy
    lda     #0
    sta     flag
    lda     #40
    sta     point
    ldy     #<vbipgm
    ldx     #>vbipgm
    lda     #7
    jsr     setVBV

forever
    lda     flag
    bmi     end
    lda     point
    bne     forever

end
    ldy     #<XITVBV
    ldx     #>XITVBV
    lda     #7
    jsr     setVBV
    lda     #0
    sta     HPOSP0
    sta     HPOSP0+1
    jmp     start

; vbi

vbipgm
    cld
    ldx     playerx
    lda     STICK0
    and     #4
    bne     v1
    cpx     #8
    beq     v2
    dex
    dex
    jmp     v2
v1
    lda     STICK0
    and     #8
    bne     v2
    cpx     #136
    beq     v2
    inx
    inx
v2
    stx     playerx
    txa
    clc
    adc     #$30
    sta     HPOSP0
    lda     #0
    sta     xmaske
    sta     ymaske

    jsr     colplay
    jsr     colball
    jsr     moveball
    jsr     setball
    jmp     XITVBV


; ball move

moveball
    clc
    lda     px
    adc     vx
    tax
    clc
    lda     py
    adc     vy
    tay
    rts

; ball colision 

colball
    ldx     px
    ldy     py
    lda     vx 
    bpl     right
    dex
    jsr     col 
    ora     xmaske
    sta     xmaske 
    dey
    jsr     col
    ora     xmaske 
    sta     xmaske 
    jmp     ytest

right 
    inx 
    iny 
    jsr     col
    ora     xmaske
    sta     xmaske 
    dey 
    jsr     col 
    ora     xmaske 
    sta     xmaske 

ytest 
    ldx     px
    ldy     py
    lda     vy
    bmi     top
    iny 
    jsr     col
    ora     ymaske
    sta     ymaske
    inx 
    jsr     col
    ora     ymaske 
    sta     ymaske 
    jmp     colend

top
    dey
    dey 
    jsr     col
    ora     ymaske
    sta     ymaske 
    inx 
    jsr     col
    ora     ymaske 
    sta     ymaske 

colend 
    lda     xmaske
    bpl     kb1
    lda     vx
    eor     xmaske
    sta     vx
    inc     vx 

kb1
    lda     ymaske 
    bpl     kb2
    lda     vy
    eor     ymaske
    sta     vy
    inc     vy 

kb2 
    rts 

colplay
    lda     vy
    bmi     cpend 
    ldy     py
    cpy     #193
    bcc     cps0
    lda     #$ff
    sta     flag
    jmp     cpend 

cps0
    cpy     #183
    bcc     cpend 
    bne     cpend 

    sec 
    lda     px
    sbc     playerx 
    cmp     #$ff
    beq     hit

cps2 
    cmp     #15
    beq     hit 
    bcs     cpend 
hit
    lda     #$ff
    sta     ymaske
cpend 
    rts 


col 
    lda     #0
    sta     SOURCE+1
    txa
    pha
    tya
    pha 
    lsr
    lsr 
    lsr 
    sta     SOURCE 
    asl
    asl
    clc 
    adc     SOURCE 
    asl 
    sta     SOURCE 
    asl     SOURCE 
    rol     SOURCE+1
    clc
    lda     SOURCE 
    adc     #<MAP
    sta     SOURCE 
    lda     #>MAP
    adc     SOURCE+1
    sta     SOURCE+1
    txa
    lsr
    lsr
    lsr
    tay
    lda     (SOURCE), y
    and     #$3f
    beq     c1
    ldx     #$ff
    cmp     #2
    bne     c2 
    lda     #0
    sta     (SOURCE), y
    dec     point 
    jmp     c2
c1
    ldx     #0
c2
    stx     count 
    pla     
    tay 
    pla 
    tax
    lda     count 
    rts 
    

setball 
    stx     px
    clc 
    lda     py
    adc     #$20
    tax 
    lda     #0
    sta     ADRPM + $500, x
    sta     ADRPM + $4ff, x
    tya     
    sta     py
    clc
    adc     #$20
    tax
    lda     #$c0
    sta     ADRPM + $500, x
    sta     ADRPM + $4ff, x
    clc 
    lda     px
    adc     #$30
    sta     HPOSP0 + 1
    rts 

initpm 
    lda     #0
    ldx     #0
delete
    sta     ADRPM + $300, x
    sta     ADRPM + $400, x
    sta     ADRPM + $500, x
    sta     ADRPM + $600, x
    sta     ADRPM + $700, x
    dex 
    bne     delete 

    ldx     #7
    lda     #$ff 

shpcopy 
    sta     ADRPM + $4db, x
    dex 
    bpl     shpcopy 

    lda     #>ADRPM
    sta     PMBASE 
    lda     #$0c
    sta     PCOLR0 
    sta     PCOLR0 + 1
    lda     #1
    sta     SIZEP0 
    lda     #1
    sta     GPRIOR 
    lda     #$3a 
    sta     SDMCTL 
    lda     #2
    sta     GRACTL 
    lda     #72
    sta     playerx 
    rts 

row1 
    .byte   65, 65, 65, 65, 65
    .byte   65, 65, 65, 65, 65
    .byte   65, 65, 65, 65, 65
    .byte   65, 65, 65, 65, 65
row2 
    .byte   65, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 65
row3 
    .byte   65, 0, 66, 0, 66, 0, 66, 0, 66, 0
    .byte   66, 0, 66 ,0, 66, 0, 66, 0, 0, 65
row4 
    .byte   65, 0 , 0, 66, 0, 66 ,0 , 66 , 0 ,66
    .byte   0, 66, 0, 66, 0, 66, 0, 66, 0, 65

ztab 
    .word   row1, row2, row3, row4  

pfield 
    .byte   0, 1, 1, 2, 1, 3, 1, 2, 1, 3, 1, 2
    .byte   1, 1, 1, 1, 1, 1 ,1, 1, 1, 1, 1, 1

charset 
    .byte   $82, $44, $34, $0b 
    .byte   $34, $62, $42, $81
    .byte   $ff, $ff, $ff, $ff
    .byte   $ff, $ff, $ff, $ff
    .byte   $ff, $ff, $ff, $ff
    .byte   $ff, $ff, $c3, $c3 
    .byte   $c3, $c3, $ff, $ff






