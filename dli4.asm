
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

    
    LDY     #<VBI
    LDX     #>VBI
    LDA     #6
    JSR     58460

    LDA     #$B0
    STA     54279 
    LDA     #1
    STA     53256
    LDA     #62
    STA     559
    LDa     #3
    STA     53277 

IKL 
    LDX     #0
IKL2
    INC     COLO, X
    INX 
    CPX     #2
    BEQ     IKL
    LDA     #1
    STA     540
GHQ
    LDA     540
    CMP     #0
    BNE     GHQ 
    JMP     IKL2


DL
    .BYTE   112, 112, 112, 240, 112, 122
    .BYTE   112, 112, 112, 65
    .WORD   DL


DLI
    PHA
POS1
    LDA     #100
    STA     53248
PPOO1
    LDA     #0
    STA     53266
    STA     54282 
    PLA 
    RTI 

VBI
    LDY     MERK
    LDA     TAB1, Y
    STA     POS1 + 1
    LDA     COLO, Y
    STA     PPOO1 + 1

    LDA     TAB2, Y
    CLC
    SBC     #31
    ASL
    ASL
    ASL
    TAY
    LDX     #0
QW1
    LDA     225 * 256, Y
    STA     $B0 * 256 + 1024 + 100, X
    INY
    INX 
    CPX     #8
    BNE     QW1
    INC     MERK
    LDA     MERK
    CMP     #4
    BNE     JK1
    LDA     #0
    STA     MERK

JK1
    JMP     58463

TAB1
    .BYTE   80, 100, 120, 140, 180
COLO 
    .BYTE   0, 85, 170, 230, 88 

MERK 
    .BYTE   0

TAB2
    .SBYTE "ATARI"


