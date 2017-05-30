
ADRPM   = $B800
ZSADR   = $5000
MAP     = $5400
MOD     = 6
QUELLE  = $F0
ZIEL    = $F2

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




    *=$9800

JMP START

DLIST
    .BYTE   $70, $70, $70, (MOD+$40)
    .WORD   MAP
    .BYTE   MOD, MOD, MOD, MOD ,MOD
    .BYTE   MOD, MOD, MOD, MOD ,MOD
    .BYTE   MOD, MOD, MOD, MOD ,MOD
    .BYTE   MOD, MOD, MOD, MOD ,MOD
    .BYTE   MOD, MOD, MOD, MOD ,$41

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


SCHLAGX
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
ZAEHL
    .BYTE 0
FLAG
    .BYTE 0
ANZAHL
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
    STA     ZIEl
    LDA     #>MAP
    STA     ZIEl + 1
    LDA     #0
    STA     ZAEHL

NXTZEIL
    LDA     ZAEHL
    LDA     SPFELD, X
    ASL
    TAX
    LDA     ZTAB, X
    STA     QUELLE
    LDA     ZTAB + 1, X
    STA     QUELLE + 1
    LDY     #19
NXTBYT
    LDA     (QUELLE), y
    STA     (ZIEL), y
    DEY
    BPL     NXTBYT
    CLC
    LDA     ZIEL
    ADC     #20
    STA     ZIEL
    BCC     S1
    INC     ZIEL+1
    INC     ZAEHL
    LDA     ZAEHL
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
    LDA     ZSATZ, X
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
    STA     VY
    LDA     #0
    STA     FLAG
    LDA     #40
    STA     ANZAHL
    LDY     #<VBIPGM
    LDA     #>VBIPGM
    LDA     #7
    JSR     SETVBV

FOREVER
    LDA     FLAG
    BMI     END
    LDA     ANZAHL
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
    LDX     SCHLAGX
    LDA     STRIG0
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
    STX     SCHLAGX
    TXA
    CLC
    ADC     #$30
    STA     HPOSP0
    LDA     #0
    STA     XMASKE
    STA     YMASKE

    JSR     KOLSCHL
    JSR     COLBALL
    JSR     MOVEBALL
    FSR     SETBALL
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
    JSR     KOL
    ORA     XMASKE
    STA     XMASKE 
    DEY 
    JSR     KOL 
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




