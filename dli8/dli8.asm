

    org     $4000
    icl "hardware.asm"
    icl "util.asm"
    icl "util_dli.asm"

    run     init


init
        jsr init_dli_screen_mode4
        ldx #>dli
        ldy #<dli
        jsr init_dli
        jmp forever
dli     pha             ; only using A register, so save old value to the stack
        lda #$7a        ; new background color
        sta COLBK       ; store it in the hardware register
        pla             ; restore the A register
        rti             ; always end DLI with RTI!

