;***********************************************************************
; SLIK: a dual-buffer playfield with software sprite management
;	or a bitmapped screen with image copy/cut/paste functions,
;	with an optional top or bottom split-screen character mode
;  written by Robert Hurst <robert@hurst-ri.us>
;  updated version: 27-Dec-2015
;
	.fileopt author, "Robert Hurst"
	.fileopt comment, "SLIK module"
	.fileopt compiler, "ca65"
	.setcpu "6502"
	.autoimport

	.proc SLIK
	.segment "CART"
	.include "abc.h"
	.include "slik.h"


;***********************************************************************
; SLIK INITIALIZATION
;
; MUST BE INVOKED ONCE BEFORE USING ANY OTHER SLIK CALL
; value in COLORCODE is used to fill the color buffer
;
; A:	$80	0 = split off, 1 = split on
;	$40	0 = char-mapped, 1 = bit-mapped
;	$30	screen modes
;	$08	0 = auto flip, 1 = flip on-demand
;	$04	0 = bottom ($0390 or higher), 1 = top ($0200)
;	$03	0 = n/a, 1, 2, or 3 split rows
;
; char-mapped modes (ROWxCOL):
;	00:	506 cells @ 23x22 (default)
;	01:	504 cells @ 21x24 (wide)
;	10:	504 cells @ 24x21 (narrow)
;	11:	506 cells @ 22x23 (exchange)
;
; bit-mapped video matrix size: 220 cells = 3520 ($1200 - $1FBF)
;	00:	220 cells @ 11x20 (tall & narrow)
;	01:	220 cells @ 10x22 (short & wide)
;	10:  not implemented
;	11:  not implemented
; characters 236-255 ($1F60-$1FFF) are free to use
;
; X:	$F0	auxiliary color (0-15)
;	$0F	volume (0-15)
;
; Y:	$F0	screen color (0-15)
;	$08	reverse mode (0:on, 1:off)
;	$07	border color (0-7)
;
;			VIC COLOR PALETTE
;		0: black	8: orange
;		1: white	9: lt. orange
;		2: red		A: pink
;		3: cyan		B: lt. cyan
;		4: magenta	C: lt. magenta
;		5: green	D: lt. green
;		6: blue		E: lt. blue
;		7: yellow	F: lt. yellow
;
INIT:
	sty VIC+15		; screen+border color
	stx VIC+14		; aux+vol
	sta SLIKVMODE

	; kernal init
	lda #1
	sta RVSFLAG	; character reverse flag
	lda #128
	sta SHIFTMODE	; locked
	lda #0
	sta SCROLLFLAG	; disable

	; VIC register init
	lda VIC+2
	and #$7F		; if $80 enabled, +$0200 to base screen address
	sta VIC+2

	lda MACHINE
	cmp #5
	bne PAL

	; NTSC setup
NTSC:	ldx #<@NTSC		; load the timer low-byte latches
	ldy #>@NTSC
	lda #$70		; top of last raster row
	bne IRQSYNC
@NTSC = $4243			; (261 * 65 - 2)

	; PAL setup
PAL:	ldx #<@PAL		; load the timer low-byte latches
	ldy #>@PAL
	lda #$76		; raster line 228/229
@PAL = $5686			; (312 * 71 - 2)

IRQSYNC:
	cmp VIC+4
	bne IRQSYNC
	stx $9126		; load T1 latch low
	sty $9125		; load T1 latch high, and transfer both to T1 counter

	; character height (0=8, 1=16)
	lda VIC+3
	and #$FE
	;bit SLIKMODE
	;bmi @ch	; bit-7 clear
	beq @ch	; bit-6 clear
	ora #1
@ch:	sta VIC+3

	sei			; turn on auto-flip
	ldx #<EXECUTE
	ldy #>EXECUTE
	stx $0314
	sty $0315
	cli

	ldx #0
	stx IRQFIELD
	stx IRQFIELD2
	stx IRQCOLOR
	stx IRQCOLOR2

	ldy SCRNPAGE
	sty IRQFIELD+1
	tya
	iny
	sty IRQFIELD2+1
	ora #$84
	sta IRQCOLOR+1
	tay
	iny
	sty IRQCOLOR2+1

	jsr CLEAR
	rts

; VIC register tables
@vic:	.byte $05, $19, $16
	; screen rows (<<1) with character height
@vic3:	.byte 23*2, 21*2, 24*2, 22*2
@vic3t:	.byte 23, 21


;*********************************************************************
; SLIK CLEAR: erase the video/color matrices
;
; value in COLORCODE will be used to fill the COLOR buffers.
; value in CRSRCHAR with the character code to fill the FIELD buffers.
;
CLEAR:
	lda IRQFLIP
	and #$7F
	sta IRQFLIP

	ldy #0
	sty CRSRCOL		; maintain column offset to row
	sty CRSRROW		; maintain row number

	ldx #1
	lda COLORCODE
@color:
	sta (IRQCOLOR),y
	sta (IRQCOLOR2),y
	iny
	bne @color
	inc IRQCOLOR+1
	inc IRQCOLOR2+1
	dex
	bpl @color

	lda CRSRCHAR
@field:
	sta (IRQFIELD),y
	sta (IRQFIELD2),y
	iny
	bne @field
	inc IRQFIELD+1
	inc IRQFIELD2+1
	inx
	beq @field

	dec IRQCOLOR+1
	dec IRQCOLOR2+1
	dec IRQFIELD+1
	dec IRQFIELD2+1
	lda IRQFLIP
	ora #$80
	sta IRQFLIP

	rts


;***********************************************************************
; SLIK CREATE A NEW IMAGE
;
; A:	enable:	0=invisible; 1=visible
;	player:	0=ignore; 1=detect
;	ghost:	0=merge image, 1=invert image
;	repeat:	0=independent, 1=reuse previous
;	floatY:	0=fixed cell, 1=vertical float
;	floatX:	0=fixed cell, 1=horizontal float
; Y/X:	height/width
; SP+2:	pointer to bitmap
;
NEW:
	sta TEMPA
	stx TEMPX
	sty TEMPY

	jsr ANIM
	rts


;***********************************************************************
; SLIK IMAGE REPLACE EXISTING WITH NEW BITMAP POINTER
;
ANIM:
	pla
	sta $0400
	pla
	sta $0401
	jsr ME
	rts


;***********************************************************************
; SLIK IMAGE ABSOLUTE X/Y COORDINATE MOVE
;
MOVE:
	stx $0400
	sty $0401
	rts


DX:
	rts


DY:
	rts


ME:
	rts

REFRESH:
	rts

SYNC:
	rts


;***********************************************************************
; SLIK FUNCTION: return masking bits for a multicolored raster
;
; A:	pass multicolored raster by reference
;
MCMASK:
	pha
	and #%11000000
	sta $00
	pla
	pha
	and #%00110000
	ora $00
	sta $00
	pla
	pha
	and #%00001100
	ora $00
	sta $00
	pla
	and #%00000011
	ora $00
	sta $00
	rts


;***********************************************************************
; SLIK WRITE: put a tile on the playing field stack
;
; pass A=character, Y=row, X=column
;
WRITE:
	sta TEMPA
	stx TEMPX
	sty TEMPY

	lda COLS
	and #3
	tax
	lda @colhi-1,x
	cmp TEMPX

	ldx TEMPX
	ldy TEMPY
	lda TEMPA
	rts

@cols:
	.word	@r24c21,@r23c22,@r22c23
@colhi:
	.byte	13,12,12
@r24c21:
	.byte	$15,$2A,$3F,$54,$69,$7E,$93,$A8,$BD,$D2,$E7,$FC
	.byte	$11,$26,$3B,$50,$65,$7A,$8F,$A4,$B9,$CE,$E3,$F8
@r23c22:
	.byte	$16,$2C,$42,$58,$6E,$84,$9A,$B0,$C6,$DC,$F2
	.byte	$08,$1E,$34,$4A,$60,$76,$8C,$A2,$B8,$CE,$E4,$FA
@r22c23:
	.byte	$17,$2E,$45,$5C,$73,$8A,$9D,$B8,$CF,$E6,$FD
	.byte	$14,$2B,$42,$59,$70,$87,$9E,$B5,$CC,$E3,$FA


;***********************************************************************
; SLIK RENDER: sprite image processing
;
RENDER:
	rts


;***********************************************************************
; SLIK EXECUTE: interrupt request handler
; - if enabled, manage screen split mode
; - if auto, swap VIC video buffers
; - empty SLIK command queue: ANIM, MOVE, DX, DY, etc.
;
EXECUTE:
	bit IRQFLIP
	bpl @1
	jmp $EABF


	; 1 - process lists to restore current video,
	; adding to lists any double-writes
@1:
	ldx SLIKLP
	beq @2
	ldy SLIKINDEXLIST,x
	lda SLIKCOLORLIST,x
	asl
	bcs @vhi
@vlo:	lsr
	sta (IRQCOLOR),y
	lda SLIKFIELDLIST,x
	sta (IRQFIELD),y
@vhi:	lsr
	sta (IRQCOLOR2),y
	lda SLIKFIELDLIST,x
	sta (IRQFIELD2),y


	; 2 - swap video making pending = current
@2:
	lda IRQFIELD+1
	eor #2
	sta IRQFIELD+1
	tya
	iny
	sty IRQFIELD2+1
	lda IRQCOLOR+1
	eor #2
	sta IRQCOLOR+1
	tya
	iny
	sty IRQCOLOR2+1

	lda VIC+2
	eor #$80
	sta VIC+2		; re-direct VIC to other screen buffer


	; 3 - process lists to update current video


	; 4 - write sprites, swapping flagged UDC tiles, 
	; and saving background to lists


	; 5 - JMP user handler
	jmp $EABF

	.endproc

