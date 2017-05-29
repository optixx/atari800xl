
    *=$8000

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

    LDA     #$B0
    STA     756

    LDY     #0
RU1
    LDA     ZS1, Y
    STA     $B0 * 256 + 8, Y
    INY
    CPY     #24
    BNE     RU1

    LDY     #0
RU2
    LDA     TEXT, Y
    STA     TEXT + 40, Y
    STA     TEXT + 80, Y
    STA     TEXT + 120, Y
    STA     TEXT + 160, Y
    INY
    CPY     #40
    BNE     RU2


LOOP
    JMP LOOP

DL
    .BYTE   112, 112, 240, 196
    .WORD   TEXT
    .BYTE   132, 132, 132, 132, 65
    .WORD   DL

DLI
    PHA
    TYA
    PHA

    LDY     #0
RU3
    LDA     TAB1, Y
    STA     53270
    LDA     TAB2, Y
    STA     53271
    LDA     TAB3, Y
    STA     53272
    LDA     TAB4, Y
    STA     53273

    STA     54282
    INY
    CPY     #8
    BNE     RU3

    PLA
    TAY
    PLA
    RTI

TAB1
    .BYTE   48, 50, 52, 54, 56, 58, 60, 62
TAB2
    .BYTE   192, 194, 196, 198, 200, 202, 204, 206
TAB3
    .BYTE   112, 114, 116, 118, 120, 122, 124, 126
TAB4
    .BYTE   240, 242, 244, 246, 248, 250, 252, 254

ZS1
    .BYTE   85, 85, 85, 85, 85, 85, 85, 85
    .BYTE   170, 170, 170, 170, 170, 170, 170, 170
    .BYTE   255, 255, 255, 255, 255, 255, 255, 255

TEXT
    .SBYTE  "!!!!!!!!########!!!!!!!!########"



