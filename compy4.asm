VDSLST  = $200
SDLSTL  = $230
DL      = $D0
COLOR   = $D018
COLOR2  = $D01A
WSYNC   = $D40A
VCOUNT  = $D40B
UHR     = $14

        *=$6000



S       LDY #0
        LDA SDLSTL
        STA DL
        LDA SDLSTL+1
        STA DL+1
        LDA (DL),Y
        ORA #$80
        STA (DL),Y
        LDA #0
        STA $D40E
        LDA #<DLI
        STA VDSLST
        LDA #>DLI
        STA VDSLST+1
        LDA #$C0
        STA $D40E
        LDA #$E
        STA $2C5
WAIT
        JMP WAIT

DLI     PHA
        TXA
        PHA
        TYA
        PHA

        LDA #$50
        STA WSYNC
        STA COLOR2
        LDA #0
        STA COLOR
L1      LDA VCOUNT
        CMP #$30
        BCC L1
        LDA #$30
        STA COLOR
L2      LDA VCOUNT
        CMP #$50
        BCC L2
        LDA #$19
        STA COLOR

L3      PLA
        TAY
        PLA
        TAX
        PLA
        RTI
