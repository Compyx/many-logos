; vim: set et ts=8 sw=8 sts=8 fdm=marker syntax=64tass:
;
; 2019 CSDb intro compo 4KB entry - four focus logos in four KB
;
; Code & gfx:   Compyx/Focus
;
;        SID_LOAD = $1000
;        SID_PATH = "Old_Level_2.sid"
;        SID_INIT = SID_LOAD + 0
;        SID_PLAY = SID_LOAD + 3


        ; Set to 1 to add rasterbars behind the logos to debug sideborder
        ; opening code
        DEBUG_BORDER = 0


        ; Uses zp $20-$3x
        SID_LOAD = $0ffc
        SID_PATH = "Pling_Plong_2.sid"
        SID_INIT = SID_LOAD
        SID_PLAY = SID_LOAD + 4

        ; Focus logo
        SPRITES_LOAD = $3c00

        SCROLL_SPRITES_0 = $0040        ; $0040-$01bf -> 6 sprites
        SCROLL_SPRITES_1 = $3a00        ; $3a00-$3a7f -> 2 sprites

        ; first set of sprite pointers used for the logo's and scroll
        POINTERS0 = $33f8
        ; second set of sprite pointers used for the logo's and scroll
        POINTERS1 = $37f8

        ; ZP used by the intro
        ZP = $02

        ; starting raster line
        RASTER = $15

        ; offset to RASTER for the first logo's Y position
        LOGO_0_OFFSET = $07
        ; offset to RASTER for the second logo's Y position
        LOGO_1_OFFSET = $39
        ; offset to RASTER for scroll's Y position
        SCROLL_OFFSET = $6a
        ; offset to RASTER for the third logo's Y position
        LOGO_2_OFFSET = $85
        ; offset to RASTER for the fourth logo's Y position
        LOGO_3_OFFSET = $b5

        ; Number of logos
        NUM_LOGOS = 4



.if USE_SYSLINE=1
; BASIC SYS line
        * = $0801
        .word (+), 2019
        .null $9e, format("%d", start)
+       .word 0
.fi

        * = $3000
.dsection start
start
        ;sei
        cld
;       stx $d015
  ;      stx $d01d
        lda #$7f
        sta $dc0d
        sta $dd0d
 
        lda #<irq0
        ldx #>irq0
        sta $fffe
        stx $ffff
        lda #<irq_nope
        ldx #>irq_nope
        sta $fffa
        stx $fffb
        sta $fffc
        stx $fffd

        lda #$35
        sta $01
        ldx #$ff
        txs

        ldy #RASTER
        sty $d012
        lda #$1b
        sta $d011
        jsr swap_sid
        jsr scroll_sprites_clear

        inc $d019
        ldx #0
        stx $3fff
        inx
        stx $d01a

        jsr sprites_setup

        lda #0
        jsr SID_INIT
;        cli
        ; Le barre d'espacement
-       lda $dc01
        and #$10
        bne -
        sei
        lda #$37
        sta $01
        jsr swap_sid
        jmp $fce2

.dsection irq0
irq0
        pha
        txa
        pha
        tya
        pha

        lda #<irq0a
        ldx #>irq0a
        ldy #RASTER + 1

        sty $d012
        sta $fffe
        stx $ffff
        inc $d019
        tsx
        cli
        .fill 11, $ea   ; reduce?
.dsection irq0a
irq0a
        txs
        ldx #8
-       dex
        bne -
        bit $ea
        lda $d012
        cmp $d012
        beq +
+
        lda #$c0
        sta $d018
        lda #$00
        sta $d01d

        ; --- delay ---
        ; lda `#0        ; 2
        ; beq $xxxx     ; 3
        ; ($1b21):
        ; 

        ; jsr           ; 6
        ; lda #0        ; 2
        ; beq *+xx      ; 3
        ; $59 in the branch:
        ; 20 * CPX #$e0/24      ; 20 * 2 = 40
        ; nop           ; 2
        ; rts           ; 6
        ;               ; ----
        ;               ; 59

        ldx #$09
-       dex
        bne -
        bit $ea
        lda line_color         ; 4
        sta $d020       ; 4
        sta $d021       ; 4 == 10

        ; 1* JSR        = 6
        ; 1 * lda #$00  = 2
        ; 21 * CPX #$E0 = 42
        ; 1 * CPX #$24  = 2
        ; 1 * NOP       = 2
        ; 1 * RTS       = 6
        ; -------------------+
        ;               = 62
        ldx #$0a        ; 2
                        ; 2 + 3 for each loop except the last, that's -1
-       dex
        bne -
        bit $ea

       ; jsr delay       ; $56
logo0_bg
        lda #$00
        sta $d020
        sta $d021
        nop
        nop

        lda #RASTER + $07
        jsr sprites_set_ypos
        ldx #0  ; logo index
        jsr sprites_set_xpos

logo0_mid lda #$00
logo0_hi  ldx #$00
logo0_lo  ldy #$00
        jsr sprites_set_colors

        lda #$ff
        sta $d017

.dsection logo_0
        jsr open_border_1
        ldx #$0a
-       dex
        bne -
        bit $ea
        lda line_color         ; 4
        sta $d021       ; 4
        sta $d020       ; 4
        ldx #$0a
-       dex
        bne -
        stx $d020
        stx $d021

        lda #RASTER + $39
        jsr sprites_set_ypos
        ldx #9
        jsr sprites_set_xpos
        ldx #$06
-       dex
        bne -
        bit $ea

        lda line_color
        sta $d020
        sta $d021
        ldx #$08
-       dex
        bpl -
        nop
        bit $ea

logo1_bg
        lda #$00
        sta $d020
        sta $d021
        nop
        bit $ea

logo1_mid lda #$00
logo1_hi ldx #$00
logo1_lo ldy #$00
        jsr sprites_set_colors

;        lda #$33        ; 2
;        sta delay + 3   ; 4
;        jsr delay       ; -

        ; JSr = 6               ;  6
        ; lda #0 = 2            ;  2
        ; beq * + ??            ;  3
        ; CPX #$E0 = (32+5) * 2 ; 74
        ; CPX #$24              ;  2
        ; NOP                   ;  2
        ; RTS                   ;  6
        ;
        ; total                 ; 95

        ldx #17
-       dex     ; 2
        bne -   ; 3 /2
        bit $ea
;nop
;        bit $ea

        lda #$c0        ; 2
        sta $d018       ; 4

.dsection logo_1
        jsr open_border_1
        ldx #$09
-       dex
        bne -
        cmp ($c1,x)
        lda line_color
        sta $d020
        sta $d021
        ldx #$0c
-       dex
        bne -
        stx $d020
        stx $d021
        stx $d017
        stx $d01c
        dex
        stx $d01d

        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        lda #RASTER + $6a
        jsr sprites_set_ypos
        lda #$d0
        sta $d018

        ldx #(SCROLL_SPRITES_0 / 64)
        stx POINTERS1 + 0
        inx
        stx POINTERS1 + 1
        inx
        stx POINTERS1 + 2
        inx
        stx POINTERS1 + 3
        inx
        stx POINTERS1 + 4
        inx
        stx POINTERS1 + 5
        ldx #(SCROLL_SPRITES_1 / 64)
        stx POINTERS1 + 6
        inx
        stx POINTERS1 + 7

;        lda #7
        lda #0
.for c = 0, c < 8, c += 1
        sta $d027 + c
.next
        jsr set_scroll_xpos
        ;jsr delay

        ; JSR            6
        ; lda #xx        2
        ; beq +          3
        ; cpx #$E0 *20  40
        ; cpx #$24       2
        ; nop            2
        ; rts            6
        ; ----------------- +
        ;               61

;        ldx #2
;-       dex
;        bne -
;        lda #00        ;2
;        sta $d020      ;4
;        sta $d021      ;4
;        ldx #$0b       ;2
;-       dex
;        bne -
;        stx $d020      ;4
;        stx $d021      ;4 += 20

        ldx #$11
-       dex
        bne -


.dsection rol_scroll
        ldx #3
-       dex
        bpl -

        jsr open_border_2
        nop
        nop
        lda line_color
        sta $d020
        sta $d021

        ldx #$0b
-       dex
        bne -
        stx $d020
        stx $d021
logo2_bg lda #$00
        sta $d020
        sta $d021
 
        ldx #0
        stx $d01d
        dex
        stx $d017
        stx $d01c
        lda #$c0
        sta $d018 + 1,x

       ldx #(SPRITES_LOAD + $0200) / 64
.for i = 0, i < 7, i += 1
        stx POINTERS1 + i
        inx
.next
        stx POINTERS1 + 7


        lda #RASTER + $85
        jsr sprites_set_ypos
        ldx #9*2  ; logo index
        jsr sprites_set_xpos
logo2_mid       lda #$00
logo2_hi        ldx #$00
logo2_lo        ldy #$00
        jsr sprites_set_colors

        ; JSR =                          6
        ; lda #0 ;                       2
        ; beq ; 3                        3
        ; $70 -> $38  => * 2 = 56 *2 = 112
        ; 5 * $e0 ->                    10
        ; bit $ea ; 3                    3
        ; rts  =6                        6
        ; +
        ;                               142
        ;jsr delay

        ; 2
        ; x * 5
        ; 4

.dsection logo_2
        jsr open_border_1
        ldx #$09
-       dex
        bne -
        bit $ea
        lda line_color
        sta $d020
        sta $d021
        lda #RASTER + $b5
        jsr sprites_set_ypos

        ldx #01
-       dex
        bne -
        lda #$00
        sta $d020
        sta $d021
        ldx #3*9  ; logo index
        jsr sprites_set_xpos

        nop
logo3_mid       lda #$00
logo3_hi        ldx #$00
logo3_lo        ldy #$00
        jsr sprites_set_colors

        lda #$ff
        sta $d017

        ; jsr                   6
        ; 24 * cpx #$e0         48
        ; 4 * cpx #$e0          8
        ; cpx #$24              2
        ; nop                   2
        ; rts                   6
        ;
        ; +                     74

        lda #$c0
        sta $d018

        cmp ($c1,x)
        nop
        lda line_color
        sta $d020
        sta $d021
nop
nop
        nop
        ldx #10
-       dex
        bne -
logo3_bg  lda #$00
        sta $d020
        sta $d021

;        jsr delay
.dsection logo_3
        ldx #$04
-       dex
        bne -
        bit $ea
        bit $ea
        jsr open_border_1
        ; open one more line for some reason
        ; rts   = 6
        ; ldy # = 2
        ; ldx # = 2
        ; lda colors,x = 4
        ;
        ; DEC $d016

        ldx #$09
-       dex
        bne -
        bit $ea
        lda line_color
        sta $d021       ; 4
        sta $d020       ; 4
        ldx #$0c
-       dex
        bne -
        stx $d020
        stx $d021

;        jsr update_delay

;        lda #0
 ;       sta $d020
 ;       sta $d021

        lda #<irq1
        ldx #>irq1
        ldy #$f9
        jmp do_irq

.dsection irq1
irq1
        pha
        txa
        pha
        tya
        pha

        lda #$03
        sta $d011
;        sta $d020
        lda #0
        sta $d017
        ldx #$30
-       dex
        bne -
        lda #$26
        sta $d018
        lda #$0b
        sta $d011
        ;inc $d020
        jsr SID_PLAY
        ;inc $d020
        jsr line_color_update
        ;inc $d020
        jsr sprites_setup
        jsr do_sinus_logo_0
        jsr do_sinus_logo_1
        jsr do_sinus_logo_2
        jsr do_sinus_logo_3

        ;inc $d020
        jsr scroller_rol
        ;inc $d020
        jsr scroller_update
        ;inc $d020
        jsr do_logo_0_wipe
        lda #0
        sta $d020

        ldy #RASTER
        lda #<irq0
        ldx #>irq0
.dsection do_irq
do_irq
        sty $d012
        sta $fffe
        stx $ffff
        inc $d019
        pla
        tay
        pla
        tax
        pla
irq_nope rti


.dsection sprites_setup
sprites_setup

        lda #$ff
        sta $d015
        sta $d01c

        ldx #(SPRITES_LOAD / 64)
.for i = 0, i < 7, i +=1
        stx POINTERS0 + i
        inx
.next
        stx POINTERS0 + 7
        ; refactor!
        inx

.for i = 0, i < 7, i += 1
        stx POINTERS1 + i
        inx
.next
        stx POINTERS1 + 7
        rts

sprites_set_colors .proc
        sta $d025
        stx $d026
        sty $d027
        sty $d028
        sty $d029
        sty $d02a
        sty $d02b
        sty $d02c
        sty $d02d
        sty $d02e
        rts
        .pend

set_scroll_xpos .proc
        lda #$f0
        sta $d000
        lda #$28
        sta $d002
        lda #$58
        sta $d004
        lda #$88
        sta $d006
        lda #$b8
        sta $d008
        lda #$e8
        sta $d00a
        lda #$18
        sta $d00c
        lda #$48
        sta $d00e

        lda #$c1
        sta $d010
        rts
.pend

        ; move to zp (probably not possible anymore)
spr_xpos_table  .fill NUM_LOGOS * $09, 0

spr_xpos_add    .byte $00, $18, $30, $48, $60, $78, $90, $a8, $c0

spr_xpos_msbbit .byte $01, $02, $04, $08, $10, $20, $40, $80, $00

wipe_index      .byte 0
                .byte (wipes_1 - wipes) / 2
                .byte (wipes_2 - wipes) / 2
                .byte (wipes_3 - wipes) / 2

; color of the raster lines surrounding the logos
line_color      .byte 0



; Make sure the code/data doesn't overlap the sprite pointers at $37f8+
.cerror * > POINTERS0, "Overlapping sprite pointers"



        * = $3400

open_border_1
        ldy #8
        ldx #40
-       lda colors,x    ; 4
        dec $d016       ; 6
        sty $d016       ; 4
.if DEBUG_BORDER
        sta $d021
        nop
.else
        sta $d03f
        nop
.endif
        cmp ($c1,x)     ; 6
        nop
        lda $d018
        eor #$10
        sta $d018

        bit $ea         ; 3
        dex             ;2
        bpl -           ; 3 when brach, 2 when not
                        ;+ ----
                        ; 18 + 20 + 5 + 2 = 
        rts

open_border_2
        ldy #8
        ldx #0
-       lda scroll_colors,x    ; 4
        dec $d016       ; 6
        sta $d021       ; 4
        sty $d016       ; 4

        cmp ($c1,x)
        cmp ($c1,x)
        cmp ($c1,x)
        bit $ea         ; 3
        inx
        cpx #21        ;2
        bne -           ; 3 when brach, 2 when not
                        ;+ ----
                        ; 18 + 20 + 5 + 2 = 

        rts

        ; Sinus 'width' of the logo swing
        SIN_WIDTH = 28 * 8

sinus
        .byte SIN_WIDTH / 2 + (SIN_WIDTH / 2.0 - 0.5) * sin(range(128) * rad(360.0/128))
color_ptrs
        .word logo0_bg + 1, logo0_lo + 1, logo0_mid + 1, logo0_hi + 1
        .word logo1_bg + 1, logo1_lo + 1, logo1_mid + 1, logo1_hi + 1
        .word logo2_bg + 1, logo2_lo + 1, logo2_mid + 1, logo2_hi + 1
        .word logo3_bg + 1, logo3_lo + 1, logo3_mid + 1, logo3_hi + 1

do_sinus_logo_0
        lda #0
        and #$7f
        tay

        lda sinus,y
        ldx #0
        jsr calc_sprites_xpos
        inc do_sinus_logo_0 + 1
        rts

do_sinus_logo_1
        lda #$20
        and #$7f
        tay
        lda sinus,y
        ldx #9
        jsr calc_sprites_xpos
        inc do_sinus_logo_1 + 1
        rts

do_sinus_logo_2
        lda #$40
        and #$7f
        tay
        lda sinus,y
        ldx #18
        jsr calc_sprites_xpos
        inc do_sinus_logo_2 + 1
        rts

do_sinus_logo_3
        lda #$60
        and #$7f
        tay
        lda sinus,y
        ldx #27
        jsr calc_sprites_xpos
        inc do_sinus_logo_3 + 1
        rts


do_logo_0_wipe .proc
        ldy #$00


        logo_index = ZP
        code_ptrs = ZP + 1 ; 2 bytes
        col_index = ZP + 4

delay   lda #$ff
        beq +
        dec delay + 1
        rts
+
        lda #3
        sta delay + 1

loop
        sty logo_index
        tya
        clc
        asl
        asl
        asl
        tay
-
        lda color_ptrs + 0,y
        sta code_ptrs + 0
        lda color_ptrs + 1,y
        sta code_ptrs + 1
        lda color_ptrs + 2,y
        sta code_ptrs + 2
        lda color_ptrs + 3,y
        sta code_ptrs + 3
        lda color_ptrs + 4,y
        sta code_ptrs + 4
        lda color_ptrs + 5,y
        sta code_ptrs + 5
        lda color_ptrs + 6,y
        sta code_ptrs + 6
        lda color_ptrs + 7,y
        sta code_ptrs + 7

        ldx logo_index
        lda wipe_index,x
        asl
        tay

        ldx #2
        lda wipes,y
        pha
        sta (code_ptrs,x)
        pla
        lsr
        lsr
        lsr
        lsr
        ldx #0
        sta (code_ptrs,x)
        lda wipes + 1,y
        pha
        ldx #6
        sta (code_ptrs,x)
        pla
        lsr
        lsr
        lsr
        lsr
        ldx #4
        sta (code_ptrs,x)

next
        ldy logo_index
        lda wipe_index,y
        clc
        adc #1
        cmp #(wipes_end - wipes) /2
        bcc +
        lda #0
+
        sta wipe_index,y

        iny
        cpy #4
        bne loop
        rts
.pend


line_color_update .proc
delay   lda #$80
        beq +
        dec delay +1 
        rts
+
        lda #$02
        sta delay + 1
index   ldx #0
        lda line_fadein,x
        bmi +
        sta line_color
        inc index + 1
+       rts
.pend

line_fadein
        .byte 0, 6, 0, 6, 4, 6, 0, 6, 4, 14, 4, 6, 0, 6, 4, 14, 15, 14, 4, 6
        .byte 0 ,6, 4, 14, 15, 7, 15, 14, 4, 6, 0, 6, 4, 14, 15, 7, 1, $ff


; Set sprite YPOS quickly
;
; @input A      ypos
sprites_set_ypos .proc
        sta $d001
        sta $d003
        sta $d005
        sta $d007
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f
        rts
.pend


; Input X
sprites_set_xpos .proc
        ldy #0
.for si = 0, si < 8, si += 1
        lda spr_xpos_table + si,x
        sta $d000 + si * 2,y
.next
        lda spr_xpos_table + 8,x
        sta $d010
        rts
        .pend


; X = sprite xpos + msb table index (ie $00, $11, $22, $33)
calc_sprites_xpos .proc
        xpos = ZP
        xmsb = ZP + 1

        sta xpos
        ldy #0
        sty xmsb
-
        lda xpos
        clc
        adc spr_xpos_add,y
        sta spr_xpos_table + 1,x
        bcc +
        lda spr_xpos_msbbit+ 1,y
        ora xmsb
        sta xmsb
+
        inx
        iny
        cpy #8
        bne -

        lda xmsb
        sta spr_xpos_table + 8 - 8,x

        lda xpos
        cmp #$18
        bcc +
        sbc #$18
        sta spr_xpos_table + 0  -8,x
        rts
+
        adc #$e0
        sta spr_xpos_table + 0- 8,x
        lda xmsb
        ora #1
        sta spr_xpos_table + 8 - 8,x
        rts
.pend

;masks   .byte $80, $40, $20, $10, $08, $04, $02, $01
masks   .byte $01, $02, $04, $08, $10, $20, $40, $80


scroller_rol .proc

        ldx #12
-
        clc
        rol SCROLL_SPRITES_1 + $42,x
        rol SCROLL_SPRITES_1 + $41,x
        rol SCROLL_SPRITES_1 + $40,x

        rol SCROLL_SPRITES_1 + $02,x
        rol SCROLL_SPRITES_1 + $01,x
        rol SCROLL_SPRITES_1 + $00,x

        rol SCROLL_SPRITES_0 + $142,x
        rol SCROLL_SPRITES_0 + $141,x
        rol SCROLL_SPRITES_0 + $140,x

        rol SCROLL_SPRITES_0 + $102,x
        rol SCROLL_SPRITES_0 + $101,x
        rol SCROLL_SPRITES_0 + $100,x

        rol SCROLL_SPRITES_0 + $c2,x
        rol SCROLL_SPRITES_0 + $c1,x
        rol SCROLL_SPRITES_0 + $c0,x

        rol SCROLL_SPRITES_0 + $82,x
        rol SCROLL_SPRITES_0 + $81,x
        rol SCROLL_SPRITES_0 + $80,x

        rol SCROLL_SPRITES_0 + $42,x
        rol SCROLL_SPRITES_0 + $41,x
        rol SCROLL_SPRITES_0 + $40,x

        rol SCROLL_SPRITES_0 + $02,x
        rol SCROLL_SPRITES_0 + $01,x
        rol SCROLL_SPRITES_0 + $00,x

        inx
        inx
        inx
        cpx #8*3 + 12
        bne -
        rts
.pend
scroller_update .proc

xpos    ldx #7
        dex
        bpl +
        ldx #7
        inc index + 1
+
        stx xpos + 1

index   ldy #0
        lda scroll_text,y
        bpl +
        ldy #scroll_repeat - scroll_text
        sty index + 1
        lda scroll_text,y
+
        asl
        asl
        asl
        sta font + 1
        lda scroll_text,y
        lsr
        lsr
        lsr
        lsr
        lsr
        clc
        adc #$d8
        sta font + 2
        lda #$33
        sta $01

        ldx #0
        stx ZP + 0
        ldy #0
-
        ldx ZP + 0
font    lda $fce2,x
        ldx xpos + 1
        and masks,x
        beq +
        lda #$01
+
        eor #1
        ora SCROLL_SPRITES_1 + $42 + 12,y
        sta SCROLL_SPRITES_1 + $42 + 12,y
        iny
        iny
        iny
        inc ZP + 0
        cpy #24
        bne -

        lda #$35
        sta $01

        rts
.pend

scroll_sprites_clear .proc
        ldx #0
        lda #$ff
-       sta @wSCROLL_SPRITES_0,x
        inx
        bne -
-       sta @wSCROLL_SPRITES_0 + $0100,x
        sta @wSCROLL_SPRITES_1,x
        inx
        bpl-
        rts
.pend

.dsection wipes_start
wipes
        .byte $00, $00
        ; grey
        .byte $00, $0b
        .byte $00, $bc
        .byte $0b, $cf
        .byte $bc, $f1
        .byte $bc, $f1
        .byte $bc, $f1
        .byte $bc, $f1
        .byte $bc, $f1
        .byte $bc, $f1
        .byte $bc, $f1
        .byte $bc, $f1
        .byte $bc, $f1
        .byte $bc, $f1
        .byte $bc, $f1
        .byte $0b, $cf
        .byte $00, $bc
        .byte $00, $0b
wipes_1
        .byte $00, $00


        ; red
        .byte $00, $02
        .byte $00, $2a
        .byte $02, $a7
        .byte $2a, $71
        .byte $2a, $71
        .byte $2a, $71
        .byte $2a, $71
        .byte $2a, $71
        .byte $2a, $71
        .byte $2a, $71
        .byte $2a, $71
        .byte $2a, $71
        .byte $2a, $71
        .byte $2a, $71
        .byte $2a, $71
        .byte $02, $a7
        .byte $00, $2a
        .byte $00, $02
        .byte $00, $00
wipes_2

        ; green
        .byte $00, $09
        .byte $00, $98
        .byte $09, $85
        .byte $98, $5d
        .byte $95, $d1
        .byte $95, $d1
        .byte $95, $d1
        .byte $95, $d1
        .byte $95, $d1
        .byte $95, $d1
        .byte $95, $d1
        .byte $95, $d1
        .byte $95, $d1
        .byte $95, $d1
        .byte $95, $d1
        .byte $98, $5d
        .byte $09, $85
        .byte $00, $98
        .byte $00, $09
        .byte $00, $00
wipes_3
        ; blue
        .byte $00, $06
        .byte $00, $64
        .byte $06, $4e
        .byte $64, $e3
        .byte $4e, $31
        .byte $6e, $31
        .byte $6e, $31
        .byte $6e, $31
        .byte $6e, $31
        .byte $6e, $31
        .byte $6e, $31
        .byte $6e, $31
        .byte $6e, $31
        .byte $6e, $31
        .byte $06, $e3
        .byte $00, $6e
        .byte $00, $06
        .byte $00, $00
wipes_end
.dsection wipes_end





.cerror * > POINTERS1, "Overlapping sprite pointers!"


; SID at temp place
;               * = SID_LOAD

        * = $3800
        SID_TEMP = *

.binary  format("%s", SID_PATH), $7e

       SID_TEMP_END = *


; Swap SID from between its temporary location and its proper location
;
; Called when starting this intro and called when exiting to adhere to the
; Intro Creation Compo 2019, 4KB category.
;
swap_sid .proc
        ldx #0
-
        ldy SID_TEMP,x
        lda SID_LOAD,x
        sta SID_TEMP,x
        tya
        sta SID_LOAD,x
        inx
        bne -
-
        ldy SID_TEMP + 256,x
        lda SID_LOAD + 256,x
        sta SID_TEMP + 256,x
        tya
        sta SID_LOAD + 256,x

        ; don't copy too much, otherwise this routine moves itself, leading to
        ; some interesting bugs.
        inx
        cpx #(SID_TEMP_END - SID_TEMP) & $0ff
        bne -
        rts
.pend

        * = $3a80



colors
        .byte $00, $06, $00, $06, $04, $00, $06, $04
        .byte $0e, $00, $06, $04, $0e, $03, $00, $06
        .byte $04, $0e, $03, $01, $00, $06, $04, $0e
        .byte $03, $01, $07, $0f, $0a, $08, $09, $00
        .byte $01, $07, $0f, $0a, $08, $09, $00, $07
        .byte $0f, $0a, $08, $09, $00, $0a, $08, $09
        .byte $00, $08, $09, $00, $00, $09, $00, $00


scroll_colors
        .byte 0, 0, 6, $06, $04, $0e, $0f, $07, $0d, 1, $01, $07, $0f
        .fill 12, 0

        * = $3b00
.dsection scroll_text
scroll_text
        .enc "screen"
        .text "     Rasters!         FOCUS!!!"
scroll_repeat
        .fill 20, $20
        .text "This is my second and way too late 4KB entry for the 'ICC2019' "
        .text "compo.  Logo and code by the Amazing Compyx, "
        .text "Short but sweet tune by GRG.  Might as well press 'Space' "
        .text "I suppose :)   PROOST!       "
        .byte $ff
.dsection scroll_text_end


; FOCUS logo
        * = SPRITES_LOAD        ; $3c00-$3fff
.binary "sprites-stretched.bin"


