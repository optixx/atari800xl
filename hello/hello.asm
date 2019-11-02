
    run start 
    org $2000

start
    lda #0
    sta $d40e
    sta $d400

    lda #<vbl_irq
    sta $222
    lda #>vbl_irq
    sta $223

    lda #<disp_list
    sta $d402
    lda #>disp_list
    sta $d403

    lda #<screen_mem
    sta $b0
    lda #>screen_mem
    sta $b1
    lda #10
    jsr copy_1bit_gfx

    lda #<(screen_mem+10*7)
    sta $b0
    lda #>(screen_mem+10*7)
    sta $b1
    lda #20
    jsr copy_1bit_gfx


    lda #<(screen_mem+10*7 + 20*7)
    sta $b0
    lda #>(screen_mem+10*7 + 20*7)
    sta $b1
    lda #40
    jsr copy_1bit_gfx

    lda #$0e
    sta $d016
    sta $d017
 
    lda #$0
    sta $d018
    sta $d01a

    lda #$c0
    sta $d40e
    lda #32+2
    sta $d400

loop
    jmp loop

vbl_irq
    pla
    tay
    pla
    tax
    pla
    
    lda $b5 
    add #1
    sta $b5

    lda #<(screen_mem+10*7 + 20*7)
    sta $b0
    lda #>(screen_mem+10*7 + 20*7)
    adc $b5
    sta $b1
    lda #40
    jsr copy_1bit_gfx

    rti

copy_1bit_gfx
    sta $b4
    lda #<hello_world_1col
    sta $b2
    lda #>hello_world_1col
    sta $b3
    ldx #6
row_loop
    ldy #5
byte_loop
    lda ($b2),y
    sta ($b0),y
    dey
    bpl byte_loop
    dex
    beq copy_done

    lda $b4
    clc
    adc $b0
    sta $b0
    lda #0
    adc $b1
    sta $b1

    lda #6
    clc 
    adc $b2
    sta $b2
    lda #0
    adc $b3
    sta $b3
    jmp row_loop
copy_done
    rts

disp_list
    .db $70,$70,$70,$70,$70,$70
    .db $49
    .dw screen_mem
    .db $9, $9, $9, $9, $9, $9
    .db $b, $b, $b, $b, $b, $b, $b
    .db $f, $f, $f, $f, $f, $f, $f
    .db $41
    .dw disp_list

hello_world_1col
    ;.db    %01000100,%00000101,%00000001,%00010000,%00000001,%00001010
    .db    %01000100,%00000101,%00000001,%00010000,%00000001,%00001010
    .db    %01000100,%11100101,%00110001,%00010011,%00011001,%00111010
    .db    %01000101,%00010101,%01001001,%00010100,%10100101,%01001010
    .db    %01111101,%11110101,%01001001,%01010100,%10100001,%01001010
    .db    %01000101,%00000101,%01001001,%01010100,%10100001,%01001000
    .db    %01000100,%11110101,%00110000,%10100011,%00100001,%00111010

screen_mem

