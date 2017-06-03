
    *=$a800
; Clear player data


; Set DLI
    LDA     #<DL
    STA     560
    LDA     #>DL
    STA     561
    LDA     #<DLI
    STA     512
    LDA     #>DLI
    STA     513
    LDA     #192
    STA     54286

MAIN
    JMP MAIN

DL
    .BYTE   112, 240, 112, 112, 112, 112
    .BYTE   65
    .WORD   DL


DLI
    PHA
    TYA 
    PHA 

    LDY     #0
TU1 
    LDA     TAB1, Y
    STA     54282
    STA     53274
    INY 
    CPY     #33
    BNE     TU1
    
    PLA
    TAY
    PLA 
    RTI 

TAB1 
    .BYTE   112, 114, 116, 118, 120, 122, 124, 126
    .BYTE   126, 124, 122, 120, 118, 116, 114, 112
    .BYTE   62, 60, 58, 56, 54, 52, 50, 48, 0
