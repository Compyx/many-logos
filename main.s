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


        RASTER = $0f


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

        lda #$63
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

        ldx #$20
-       dex
        bne -

        jsr delay
        jsr open_border_1

        jsr update_delay

;        lda #0
 ;       sta $d020
 ;       sta $d021

;.if SID_ENABLE
        dec $d020
        jsr SID_PLAY
        inc $d020
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
        ldx #$30
-       dex
        bne -

        lda #$0b
        sta $d011


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
        lda #$00
        sta $d000
        lda #$18
        sta $d002
        lda #$30
        sta $d004
        lda #$48
        sta $d006
        lda #$60
        sta $d008
        lda #$78
        sta $d00a
        lda #$90
        sta $d00c
        lda #$a8
        sta $d00e
        lda #0
        sta $d010

        lda #$14
        sta $d001
        sta $d003
        sta $d005
        sta $d007
        sta $d009
        sta $d00b
        sta $d00d
        sta $d00f

        lda #$ff
        sta $d015
        sta $d01c

        ldx #(SPRITES_LOAD / 64) & $3fff
        stx $07f8
        inx
        stx $07f9
        inx
        stx $07fa
        inx
        stx $07fb
        inx
        stx $07fc
        inx
        stx $07fd
        inx
        stx $07fe
        inx
        stx $07ff

        lda #$0f
        ldx #$01
        ldy #$0c
sprites_set_colors
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

open_border_1
        ldy #8
        ldx #24
-       lda colors,x
        dec $d016
        sty $d016
        sta $d021
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        bit $ea
        dex
        bpl -

        rts





        * = SID_LOAD
.binary  format("%s", SID_PATH), $7e


.align 256
colors
        .byte 6, 0, 4, 0, 14, 0, 15, 0, 7, 0, 1, 0, 7, 0, 15, 0, 14, 0, 4, 0, 6, 0
        .byte 9, 0, 8, 0, 10, 0, 15, 0, 7, 0, 1, 0, 7, 0, 15, 0, 10, 0, 8, 0, 9, 0


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





; FOCUS logo
        * = SPRITES_LOAD        ; $3c00-$3fff
.binary "sprites-horizontal.bin"
