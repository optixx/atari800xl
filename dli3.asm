
    *=$4000
; Clear player data

    LDY     #0
    LDA     #0
TU1 
    STA     176 * 256 + 1024, Y
    INY
    CPY     #0
    BNE     TU1 


; Store player data
    LDY     #0
TU2
    LDA     DATA1, Y
    STA     180 * 256 + 50, Y
    STA     180 * 256 + 140, Y
    LDA     DATA2, Y
    STA     180 * 256 + 90, Y
    STA     180 * 256 + 190, Y
    INY
    CPY     #16
    BNE     TU2

; Set DLI
    LDA     #<DL1
    STA     560
    LDA     #>DL1
    STA     561
    LDA     #<DLI1
    STA     512
    LDA     #>DLI1
    STA     513
    LDA     #192
    STA     54286


; Enable player
    LDY    #204
MAIN
    LDA     #3
    STA     53277       ; GRACTL
    ;INY
    TYA  
    STA     54279       ; PMBASE
    LDA     #62
    STA     559        ; SDMCTL
    LDX     #0
WAIT
    INX
WAIT2
    LDA     54283
    CMP     #155
    BNE     WAIT2
    CPX     #100
    BNE     WAIT
    JMP     MAIN
    RTS


DLI1
    PHA
    LDA     #180
    STA     53248       ; HPOSP0
    LDA     #7 * 16 + 6 
    STA     53266       ; COLPM0

    STA     54282       ; WSYNC
    LDA     #<DLI2
    STA     512
    LDA     #>DLI2
    STA     513
    PLA
    RTI

DLI2
    PHA
    LDA     #140
    STA     53248
    LDA     #3 * 16 + 8
    STA     53266
    LDA     #1
    STA     53256       ; SIZEP0
    STA     54282
    LDA     #<DLI3
    STA     512
    LDA     #>DLI3
    STA     513
    PLA
    RTI



DLI3
    PHA
    LDA     #0
    STA     53256
    LDA     #100
    STA     53248
    LDA     #10 * 16 + 8
    STA     53266
    STA     54282

    LDA     #<DLI4
    STA     512
    LDA     #>DLI4
    STA     513
    PLA
    RTI


DLI4
    PHA
    LDA     #60
    STA     53248
    LDA     #4 * 16 + 6
    STA     53266
    STA     54282

    LDA     #<DLI1
    STA     512
    LDA     #>DLI1
    STA     513
    PLA
    RTI

DL1
    .BYTE   112, 112, 112, 112, 240
    .BYTE   112, 112, 112, 112, 240
    .BYTE   112, 112, 112, 112, 112, 240
    .BYTE   112, 112, 112, 112, 112, 240
    .BYTE   65 
    .WORD   DL1


DATA1
    .BYTE   36, 36, 126, 66, 90, 126, 24, 60, 126, 255, 189, 189, 36, 36, 102, 102
DATA2
    .BYTE   60, 126, 153, 90, 60, 24, 24, 24, 24, 24, 60, 126, 60, 24, 60, 126

