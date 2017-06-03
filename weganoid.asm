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
SETVBV  = $E45C
XITVBV  = $E462




    *=$A800

    JMP START

DLIST
    .BYTE   $70, $70, $70, (MOD+$40)
    .WORD   MAP
    .BYTE   MOD, MOD, MOD, MOD ,MOD
    .BYTE   MOD, MOD, MOD, MOD ,MOD
    .BYTE   MOD, MOD, MOD, MOD ,MOD
    .BYTE   MOD, MOD, MOD, MOD ,MOD
    .BYTE   MOD, MOD, MOD,$41
    .WORD   DLIST

DLTXT
    .BYTE   $70, $70, $70, $70, $70
    .BYTE   $70, $70, $70, (MOD+$40)
    .WORD   TTXT
    .BYTE   $70, MOD, $70, MOD, $41
    .WORD   DLTXT

TTXT
    .SBYTE "------WEGANOID------"
    .SBYTE "----ATARI MAGAZIN---"
    .SBYTE "---KNOPF DRUECKEN---"


PLAYERX
    .BYTE 0
PX
    .BYTE 0
PY
    .BYTE 0
VX
    .BYTE 0
VY
    .BYTE 0
XMASKE
    .BYTE 0
YMASKE
    .BYTE 0
COUNT
    .BYTE 0
FLAG
    .BYTE 0
POINT
    .BYTE 0


START
    LDA     #$E0
    STA     CHBAS
    LDA     #<DLTXT
    LDX     #>DLTXT
    STA     SDLSTL
    STX     SDLSTL + 1

; Playfield generate
    LDA     #<MAP
    STA     DEST
    LDA     #>MAP
    STA     DEST + 1
    LDA     #0
    STA     COUNT

NXTZEIL
    LDX     COUNT
    LDA     PFIELD, X
    ASL
    TAX
    LDA     ZTAB, X
    STA     SOURCE
    LDA     ZTAB + 1, X
    STA     SOURCE + 1
    LDY     #19
NXTBYT
    LDA     (SOURCE), y
    STA     (DEST), y
    DEY
    BPL     NXTBYT
    CLC
    LDA     DEST
    ADC     #20
    STA     DEST
    BCC     S1
    INC     DEST+1
S1
    INC     COUNT
    LDA     COUNT
    CMP     #24
    BNE     NXTZEIL

; Charset init

    LDA     #0
    TAX
NXTCLR
    STA     ZSADR, X
    STA     ZSADR + 256, X
    INX
    BNE     NXTCLR
    LDX     #23
NXTZS
    LDA     CHARSET, X
    STA     ZSADR, X
    DEX
    BPL     NXTZS

WAIT
    LDA     STRIG0
    BNE     WAIT

; Game start

    LDA     #>ZSADR
    STA     CHBAS
    LDA     #<DLIST
    LDX     #>DLIST
    STA     SDLSTL
    STX     SDLSTL+1

    JSR     INITPM

    LDA     #151
    STA     PY
    LDA     RANDOM
    AND     #$7F
    CLC
    ADC     #16
    STA     PX
    LDA     #1
    STA     VX
    LDA     #$FE 
    STA     VY
    LDA     #0
    STA     FLAG
    LDA     #40
    STA     POINT
    LDY     #<VBIPGM
    LDX     #>VBIPGM
    LDA     #7
    JSR     SETVBV

FOREVER
    LDA     FLAG
    BMI     END
    LDA     POINT
    BNE     FOREVER

END
    LDY     #<XITVBV
    LDX     #>XITVBV
    LDA     #7
    JSR     SETVBV
    LDA     #0
    STA     HPOSP0
    STA     HPOSP0+1
    JMP     START

; VBI

VBIPGM
    CLD
    LDX     PLAYERX
    LDA     STICK0
    AND     #4
    BNE     V1
    CPX     #8
    BEQ     V2
    DEX
    DEX
    JMP     V2
V1
    LDA     STICK0
    AND     #8
    BNE     V2
    CPX     #136
    BEQ     V2
    INX
    INX
V2
    STX     PLAYERX
    TXA
    CLC
    ADC     #$30
    STA     HPOSP0
    LDA     #0
    STA     XMASKE
    STA     YMASKE

    JSR     COLPLAY
    JSR     COLBALL
    JSR     MOVEBALL
    JSR     SETBALL
    JMP     XITVBV


; Ball move

MOVEBALL
    CLC
    LDA     PX
    ADC     VX
    TAX
    CLC
    LDA     PY
    ADC     VY
    TAY
    RTS

; Ball colision 

COLBALL
    LDX     PX
    LDY     PY
    LDA     VX 
    BPL     RIGHT
    DEX
    JSR     COL 
    ORA     XMASKE
    STA     XMASKE 
    DEY
    JSR     COL
    ORA     XMASKE 
    STA     XMASKE 
    JMP     YTEST

RIGHT 
    INX 
    INY 
    JSR     COL
    ORA     XMASKE
    STA     XMASKE 
    DEY 
    JSR     COL 
    ORA     XMASKE 
    STA     XMASKE 

YTEST 
    LDX     PX
    LDY     PY
    LDA     VY
    BMI     TOP
    INY 
    JSR     COL
    ORA     YMASKE
    STA     YMASKE
    INX 
    JSR     COL
    ORA     YMASKE 
    STA     YMASKE 
    JMP     COLEND

TOP
    DEY
    DEY 
    JSR     COL
    ORA     YMASKE
    STA     YMASKE 
    INX 
    JSR     COL
    ORA     YMASKE 
    STA     YMASKE 

COLEND 
    LDA     XMASKE
    BPL     KB1
    LDA     VX
    EOR     XMASKE
    STA     VX
    INC     VX 

KB1
    LDA     YMASKE 
    BPL     KB2
    LDA     VY
    EOR     YMASKE
    STA     VY
    INC     VY 

KB2 
    RTS 

COLPLAY
    LDA     VY
    BMI     CPEND 
    LDY     PY
    CPY     #193
    BCC     CPS0
    LDA     #$FF
    STA     FLAG
    JMP     CPEND 

CPS0
    CPY     #183
    BCC     CPEND 
    BNE     CPEND 

    SEC 
    LDA     PX
    SBC     PLAYERX 
    CMP     #$FF
    BEQ     HIT

CPS2 
    CMP     #15
    BEQ     HIT 
    BCS     CPEND 
HIT
    LDA     #$FF
    STA     YMASKE
CPEND 
    RTS 


COL 
    LDA     #0
    STA     SOURCE+1
    TXA
    PHA
    TYA
    PHA 
    LSR
    LSR 
    LSR 
    STA     SOURCE 
    ASL
    ASL
    CLC 
    ADC     SOURCE 
    ASL 
    STA     SOURCE 
    ASL     SOURCE 
    ROL     SOURCE+1
    CLC
    LDA     SOURCE 
    ADC     #<MAP
    STA     SOURCE 
    LDA     #>MAP
    ADC     SOURCE+1
    STA     SOURCE+1
    TXA
    LSR
    LSR
    LSR
    TAY
    LDA     (SOURCE), Y
    AND     #$3F
    BEQ     C1
    LDX     #$FF
    CMP     #2
    BNE     C2 
    LDA     #0
    STA     (SOURCE), Y
    DEC     POINT 
    JMP     C2
C1
    LDX     #0
C2
    STX     COUNT 
    PLA     
    TAY 
    PLA 
    TAX
    LDA     COUNT 
    RTS 
    

SETBALL 
    STX     PX
    CLC 
    LDA     PY
    ADC     #$20
    TAX 
    LDA     #0
    STA     ADRPM + $500, X
    STA     ADRPM + $4FF, X
    TYA     
    STA     PY
    CLC
    ADC     #$20
    TAX
    LDA     #$C0
    STA     ADRPM + $500, X
    STA     ADRPM + $4FF, X
    CLC 
    LDA     PX
    ADC     #$30
    STA     HPOSP0 + 1
    RTS 

INITPM 
    LDA     #0
    LDX     #0
DELETE
    STA     ADRPM + $300, X
    STA     ADRPM + $400, X
    STA     ADRPM + $500, X
    STA     ADRPM + $600, X
    STA     ADRPM + $700, X
    DEX 
    BNE     DELETE 

    LDX     #7
    LDA     #$FF 

SHPCOPY 
    STA     ADRPM + $4DB, X
    DEX 
    BPL     SHPCOPY 

    LDA     #>ADRPM
    STA     PMBASE 
    LDA     #$0C
    STA     PCOLR0 
    STA     PCOLR0 + 1
    LDA     #1
    STA     SIZEP0 
    LDA     #1
    STA     GPRIOR 
    LDA     #$3A 
    STA     SDMCTL 
    LDA     #2
    STA     GRACTL 
    LDA     #72
    STA     PLAYERX 
    RTS 

ROW1 
    .BYTE   65, 65, 65, 65, 65
    .BYTE   65, 65, 65, 65, 65
    .BYTE   65, 65, 65, 65, 65
    .BYTE   65, 65, 65, 65, 65
ROW2 
    .BYTE   65, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .BYTE   0, 0, 0, 0, 0, 0, 0, 0, 0, 65
ROW3 
    .BYTE   65, 0, 66, 0, 66, 0, 66, 0, 66, 0
    .BYTE   66, 0, 66 ,0, 66, 0, 66, 0, 0, 65
ROW4 
    .BYTE   65, 0 , 0, 66, 0, 66 ,0 , 66 , 0 ,66
    .BYTE   0, 66, 0, 66, 0, 66, 0, 66, 0, 65

ZTAB 
    .WORD   ROW1, ROW2, ROW3, ROW4  

PFIELD 
    .BYTE   0, 1, 1, 2, 1, 3, 1, 2, 1, 3, 1, 2
    .BYTE   1, 1, 1, 1, 1, 1 ,1, 1, 1, 1, 1, 1

CHARSET 
    .BYTE   $82, $44, $34, $0B 
    .BYTE   $34, $62, $42, $81
    .BYTE   $FF, $FF, $FF, $FF
    .BYTE   $FF, $FF, $FF, $FF
    .BYTE   $FF, $FF, $FF, $FF
    .BYTE   $FF, $FF, $C3, $C3 
    .BYTE   $C3, $C3, $FF, $FF






