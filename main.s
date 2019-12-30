; vim: set et ts=8 sw=8 sts=8 fdm=marker syntax=64tass:
;
; 2019 CSDb intro compo 4KB entry - logo stretcher or so
;
; Code & gfx:   Compyx/Focus
;
;
        SID_LOAD = $1000
        SID_PATH = "Old_Level_2.sid"
        SID_INIT = SID_LOAD + 0
        SID_PLAY = SID_LOAD + 3

        SPRITES_LOAD = $3c00
        ZP = $02

        RASTER = $0e

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

        lda #$1d
        sta delay + 3

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
        lda #0
        sta $d021
        sta $d021
        nop
        
        ; lda #0        ; 2
        ; beq $xxxx     ; 3
        ; ($1b21):
        ; 
        jsr delay

        lda #$14
        jsr sprites_set_ypos
        nop
        ldx #0  ; logo index
        jsr sprites_set_xpos
        lda #$0f
        ldx #$01
        ldy #$0c
        jsr sprites_set_colors

        lda #$ff
        sta $d017

        jsr open_border_1



        ldx #$10
-       dex
        bne -
        dec $d020
        lda #78
        jsr sprites_set_ypos
        lda #$0a
        ldx #$07
        ldy #$02
        jsr sprites_set_colors

        jsr delay

        jsr open_border_1

        jsr update_delay

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
        lda #$27
        sta $d018
        lda #$0b
        sta $d011
        dec $d020
        jsr do_sinus_logo_0
        inc $d020

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

        ldx #(SPRITES_LOAD / 64) & $3fff
        stx $0bf8
        inx
        stx $0bf9
        inx
        stx $0bfa
        inx
        stx $0bfb
        inx
        stx $0bfc
        inx
        stx $0bfd
        inx
        stx $0bfe
        inx
        stx $0bff
        ; refactor!
        inx
        stx $0ff8
        inx
        stx $0ff9
        inx
        stx $0ffa
        inx
        stx $0ffb
        inx
        stx $0ffc
        inx
        stx $0ffd
        inx
        stx $0ffe
        inx
        stx $0fff
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

.align 256
open_border_1
        ldy #8
        ldx #42
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
        lda $d018
        eor #$10
        sta $d018

        bit $ea         ; 3
        dex             ;2
        bpl -           ; 3 when brach, 2 when not
                        ;+ ----
                        ; 18 + 20 + 5 + 2 = 

        rts


sinus
        .byte 128 + 127.5 * sin(range(256) * rad(360.0/256))


do_sinus_logo_0
        ldy #0
        lda sinus,y
        ldx #0
        jsr calc_sprites_xpos
.if 0
.fi
        inc do_sinus_logo_0 + 1
        rts

; $00 = $00,$18,$30,$48,$60,$78,$90,$a8
; $20 = $80
; $38 = $c0
; $50 = $e0
; $68 = $f0
; return: Y = $d010


;
spr_xpos_table  .fill NUM_LOGOS * $09, 0



spr_xpos_add    .byte $00, $18, $30, $48, $60, $78, $90,$a8
spr_xpos_msbbit .byte $01, $02, $04, $08, $10, $20, $40, $80


        * = SID_LOAD
.binary  format("%s", SID_PATH), $7e


.align 256
colors
    ;.byte 6, 0, 4, 0, 14, 0, 15, 0, 7, 0, 1, 0, 7, 0, 15, 0, 14, 0, 4, 0, 6, 0
    ;    .byte 9, 0, 8, 0, 10, 0, 15, 0, 7, 0, 1, 0, 7, 0, 15, 0, 10, 0, 8, 0, 9, 0

        .fill 48, 11

update_delay
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

.align 256

delay
        lda #0
        beq +
+       .fill 128, $e0
        bit $ea
        rts

; Input: A
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
.for si = 0, si < 8, si += 1
        lda spr_xpos_table + si,x
        sta $d000 + si * 2
.next
        lda spr_xpos_table + 8,x
        sta $d010
        rts
        .pend

; FOCUS logo
        * = SPRITES_LOAD        ; $3c00-$3fff
.binary "sprites-stretched.bin"


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
        sta spr_xpos_table,x
        bcc +
        lda spr_xpos_msbbit,y
        ora xmsb
        sta xmsb
+
        inx
        iny
        cpy #8
        bne -
        lda xmsb
        sta spr_xpos_table,x
        rts
.pend


