; vim: set et ts=8 sw=8 sts=8 fdm=marker syntax=64tass:
;
; 2019 CSDb intro compo 4KB entry - logo stretcher or so
;
; Code & gfx:   Compyx/Focus
;
;
;        SID_LOAD = $1000
;        SID_PATH = "Old_Level_2.sid"
;        SID_INIT = SID_LOAD + 0
;        SID_PLAY = SID_LOAD + 3

        ; use zp $20-$3x

        SID_LOAD = $0ffc
        SID_PATH = "Pling_Plong_2.sid"
        SID_INIT = SID_LOAD
        SID_PLAY = SID_LOAD + 4

        SPRITES_LOAD = $3c00
        SCROLL_SPRITES = $3a00

        POINTERS0 = $33f8
        POINTERS1 = $37f8

        ZP_TMP = $02
        ZP = $12



        RASTER = $0d

        NUM_LOGOS = 4



.if USE_SYSLINE=1
; BASIC SYS line
        * = $0801
        .word (+), 2019
        .null $9e, format("%d", start)
+       .word 0
.fi

        * = $3000
start
        cld
        sei
        ldx #$ff
        txs

        jsr swap_sid
 ;       stx $d015
  ;      stx $d01d
        lda #$7f
        sta $dc0d
        sta $dd0d
        bit $dc0d
        bit $dd0d
        lda #$35
        sta $01
 
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
        ldy #RASTER
        sty $d012
        lda #$1b
        sta $d011

        ldx #0
        stx $3fff
        inx
        stx $d01a
        inc $d019

        lda #$0c
        ldx #$0b
        sta $d020
        stx $d021

;        lda #$47
;        sta delay + 3

        jsr sprites_setup

;.if SID_ENABLE
        lda #0
        jsr SID_INIT
;.fi
        cli
        jmp *
        ; Le barre d'espacement
-       lda $dc01
        and #$10
        bne -
        sei
        lda #$37
        sta $01
        jsr swap_sid
        jmp $fce2
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
        nop
        inc $d019
        tsx
        cli
        .fill 11, $ea   ; reduce?
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
;        lda #$0b
;        sta $d020
;        sta $d021
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
        nop
        nop

        ; 1* JSR        = 6
        ; 1 * lda #$00  = 2
        ; 21 * CPX #$E0 = 42
        ; 1 * CPX #$24  = 2
        ; 1 * NOP       = 2
        ; 1 * RTS       = 6
        ; -------------------+
        ;               = 62
        ldx #$0c        ; 2
                        ; 2 + 3 for each loop except the last, that's -1
-       dex
        bne -
bit $ea

       ; jsr delay       ; $56
logo0_bg
        lda #$0b
        sta $d020
        sta $d021
        nop
        lda #$14
        jsr sprites_set_ypos
        nop
        ldx #0  ; logo index
        jsr sprites_set_xpos
logo0_mid lda #$0f
logo0_hi  ldx #$01
logo0_lo  ldy #$0c
        jsr sprites_set_colors

        lda #$ff
        sta $d017

        jsr open_border_1
        ldx #$05
-       dex
        bne -
        ;lda #0          ; 2
        stx $d021       ; 4
        stx $d020       ; 4


         nop
logo1_ypos        lda #$46
        jsr sprites_set_ypos
        ldx #9
        jsr sprites_set_xpos
        ldx #$08
-       dex
        bne -
logo1_bg        lda #$02
        sta $d020
        sta $d021
        nop
        bit $ea
 
logo1_mid    lda #$07
logo1_hi ldx #$01
logo1_lo ldy #$0a
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

        ldx #20
-       dex     ; 2
        bne -   ; 3 /2
        nop
;nop
;        bit $ea


        jsr open_border_1
        ldx #$03
-       dex
        bne -
        stx $d020
        stx $d021

        lda #$00
        sta $d017
        sta $d01c
        lda #$ff
        sta $d01d

        lda logo1_ypos + 1
        clc
        adc #$30
        jsr sprites_set_ypos
        lda #$d5
        sta $d018
        ;ldx #(SCROLL_SPRITES /64)
        ldx #$1000/64
.for i = 0, i < 7, i += 1
        stx POINTERS1 + i
        inx
.next
        stx POINTERS1 + 7
scroll_color
        lda #1
.for c = 0, c < 8, c += 1
        sta $d027 + c
.next
        jsr set_scroll_xpos
        lda #6
        sta $d020
        sta $d021

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

        ldx #12
-       dex
        bne -

        jsr open_border_2

        ldx #$03
-       dex
        bne -

        ldx #(SPRITES_LOAD + $0200) / 64
.for i = 0, i < 7, i += 1
        stx POINTERS1 + i
        inx
.next
        stx POINTERS1 + 7

        ldx #0
        stx $d020
        stx $d021

        stx $d01d
        dex
        stx $d017
        stx $d01c
        lda #$c0
        sta $d018

logo2_bg lda #$09
        sta $d020
        sta $d021

        lda #$93
        jsr sprites_set_ypos
        nop
        ldx #9*2  ; logo index
        jsr sprites_set_xpos
logo2_mid       lda #$03
logo2_hi        ldx #$01
logo2_lo        ldy #$05
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

        ldx #27
-       dex
        bne -
        jsr open_border_1
        ldx #03
-       dex
        bne -
        stx $d020
        stx $d021
        lda #$92 + 50
        jsr sprites_set_ypos
 

        ldx #03
-       dex
        bne -
        lda #$06
        sta $d020
        sta $d021
       ldx #3*9  ; logo index
        jsr sprites_set_xpos
        lda #$03
        ldx #$01
        ldy #$0e
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

        ldx #15
-       dex
        bne -

;        jsr delay
        jsr open_border_1
        ldx #$05
-       dex
        bne -
        ;lda #0          ; 2
        stx $d021       ; 4
        stx $d020       ; 4




;        jsr update_delay

;        lda #0
 ;       sta $d020
 ;       sta $d021

;.if SID_ENABLE
        dec $d020
        jsr SID_PLAY
        dec $d020
        lda #0
        sta $d020
;.fi
        lda #<irq1
        ldx #>irq1
        ldy #$f9
        jmp do_irq

irq1
        pha
        txa
        pha
        tya
        pha

        lda #$03
        sta $d011
        lda #0
        sta $d017
        ldx #$30
-       dex
        bne -
        lda #$26
        sta $d018
        lda #$0b
        sta $d011
        dec $d020
        jsr sprites_setup
        jsr do_sinus_logo_0
        jsr do_sinus_logo_1
        jsr do_sinus_logo_2
        jsr do_sinus_logo_3

         dec $d020
        jsr do_logo_0_wipe
        ;jsr do_logo_1_wipe
        sta $d020

        ldy #RASTER
        lda #<irq0
        ldx #>irq0
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
        lda #$00
        sta $d000
        lda #$30
        sta $d002
        lda #$60
        sta $d004
        lda #$90
        sta $d006
        lda #$b0
        sta $d008
        lda #$d0
        sta $d00a
        lda #$00
        sta $d00c
        lda #$30
        sta $d00e

        lda #$c0
        sta $d010
        rts
.pend

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

        .align 256


open_border_1
        ldy #8
        ldx #42
-       lda colors,x    ; 4
        dec $d016       ; 6
        sty $d016       ; 4
        ;sta $d021       ; 4
        nop
        nop
        nop             ; 2 * 10
        nop
        nop
        nop
        nop
;        nop
;        nop
;        nop
;        nop
;        nop
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
        ldx #22
-       lda colors,x    ; 4
        dec $d016       ; 6
        sty $d016       ; 4
        sta $d021       ; 4
        
        nop             ; 2 * 10
        nop
        nop
        nop
        nop
;        nop
;        nop
;        nop
;        nop
;        nop
        ;lda $d018
        ;eor #$10
        ;sta $d018
        nop
        nop
        nop
        nop
        nop
        bit $ea         ; 3
        dex             ;2
        bpl -           ; 3 when brach, 2 when not
                        ;+ ----
                        ; 18 + 20 + 5 + 2 = 

        rts


sinus
        .byte 128 + 127.5 * sin(range(128) * rad(360.0/128))

color_ptrs
        .word logo0_bg + 1, logo0_lo + 1, logo0_mid + 1, logo0_hi + 1
        .word logo1_bg + 1, logo1_lo + 1, logo1_mid + 1, logo1_hi + 1
        .word logo2_bg + 1, logo2_lo + 1, logo2_mid + 1, logo2_hi + 1


do_logo_0_wipe .proc
        ldy #$00
next
        sty ZP_TMP

        ldx wipe_index,y
        jsr do_wipes
        txa
        sta wipe_index,y

        tya
        clc
        asl
        asl
        asl
        tay

        ldx #0
-
        lda color_ptrs + 0,y
        sta ZP_TMP + 1,x
        lda color_ptrs + 1,y
        sta ZP_TMP + 2,x

        iny
        iny
        inx
        inx
        cpx #8
        bne -

        ldy #0
        ldx #0
-
        lda wipe_colors,y
        sta (ZP_TMP + 1,x)
        inx
        inx
        iny
        cpy #4
        bne -

        ldy ZP_TMP + 0
        iny
        cpy #3
        bne next

        rts
.pend



do_wipes .proc
        lda wipe_delay,y
        beq +
        lda wipe_delay,y
        sec
        sbc #1
        sta wipe_delay,y
        rts
+       lda #3
        sta wipe_delay,y

        lda wipes,x
        cmp #$ff
        beq reset
        cmp #$80
        bne more

        ;set delay
        lda wipes + 1,x
        sta wipe_delay,y
        inx
        inx
        rts

reset
        lda #3
        sta wipe_delay,y
        ldx #$00
        rts
more
        pha
        and #$0f
        sta wipe_colors + 1
        pla
        lsr
        lsr
        lsr
        lsr
        sta wipe_colors + 0

        lda wipes + 1,x
        pha
        and #$0f
        sta wipe_colors + 3
        pla
        lsr
        lsr
        lsr
        lsr
        sta wipe_colors + 2
        inx
        inx
        rts
.pend




; $00 = $00,$18,$30,$48,$60,$78,$90,$a8
; $20 = $80
; $38 = $c0
; $50 = $e0
; $68 = $f0
; return: Y = $d010



wipe_colors     .byte 0, 0, 0, 0


; move to zp
spr_xpos_table  .fill NUM_LOGOS * $09, 0


spr_xpos_add    .byte $00, $18, $30, $48, $60, $78, $90, $a8, $c0
spr_xpos_msbbit .byte $01, $02, $04, $08, $10, $20, $40, $80, $00
wipe_index      .byte 0, wipes_1 - wipes, wipes_2 - wipes, wipes_3 - wipes
wipe_delay      .byte 0, 0, 0, 0

.align 256
colors
        .byte 6, 0, 4, 0, 14, 0, 15, 0, 7, 0, 1, 0, 7, 0, 15, 0, 14, 0, 4, 0, 6, 0
        .byte 9, 0, 8, 0, 10, 0, 15, 0, 7, 0, 1, 0, 7, 0, 15, 0, 10, 0, 8, 0, 9, 0


wipes
        .byte $00, $00
        ; grey
        .byte $00, $0b
        .byte $00, $bc
        .byte $0b, $cf
        .byte $bc, $f1
        .byte $80, $40
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
        .byte $80, $40
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
        .byte $85, $d1
        .byte $80, $40
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
        .byte $80, $40
        .byte $06, $e3
        .byte $00, $6e
        .byte $00, $06
        .byte $00, $00


        .byte $ff, $00


.if 0
update_delay .proc
        lda #7
        beq +
        dec update_delay + 1
        rts
+
        lda #$07
        sta update_delay + 1
        lda $dc01
        and #$02
        beq +
        rts
+
        lda delay + 3
        sec
        sbc #1
        and #$7f
        sta delay + 3
        rts
.pend

;.align 256

delay
        lda #0
        beq +
+       .fill 128, $e0
        bit $ea
        rts
.fi


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


; SID at temp place
;               * = SID_LOAD

        * = $3800
        SID_TEMP = *

.binary  format("%s", SID_PATH), $7e

       SID_TEMP_END = *

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


; FOCUS logo
        * = SPRITES_LOAD        ; $3c00-$3fff
.binary "sprites-stretched.bin"




.align 256

scroller_clear .proc
        ldx #0
        txa
-       sta SCROLL_SPRITES,x
        sta SCROLL_SPRITES + 1,x
        inx
        bne -
        rts
.pend


scroller_render .proc
        ldx #0

        lda SCROLL_SPRITES
.pend


