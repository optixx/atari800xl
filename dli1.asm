
    *=$6000

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
LOOP
    JMP     LOOP

DL
    .BYTE   112, 112, 240, 114 
    .WORD   TEXT
    .BYTE   65
    .WORD   DL

DLI 
    PHA
    TYA
    PHA
    LDY     #0
ROW
    LDA     0, Y
    STA     54282
    STA     54276

    STA     53272 
    STA     53273 
    STA     53274 
    INY
    CPY     #254
    BNE     ROW

    PLA
    TAY
    PLA 
    RTI 

TAB1
    .BYTE    1, 1, 1, 0, 0, 0, 0
    
TEXT    
    .SBYTE   "     DLI TEXT DEMO 123"



    
