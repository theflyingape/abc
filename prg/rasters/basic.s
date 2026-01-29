;*********************************************************************
; COMMODORE VIC 20 ABC PROGRAM STARTUP USING BASIC 2.0
; written by Robert Hurst <robert@hurst-ri.us>
; updated version: 20-Aug-2015
;
	.fileopt author,	"Robert Hurst"
        .fileopt comment,	"ABC-SLIK startup"
        .fileopt compiler,	"6502 assembler (ca65)"

	.include "abc.h"

;*********************************************************************
; Commodore BASIC 2.0 program
;
; LOAD "PROGRAM",8
; RUN
;
	.segment "CODE"

	.word	RUN		; load address
RUN:	.word	@end		; next line link
	.word	2015		; line number
	.byte	$9E		; BASIC token: SYS
	.byte	<(MAIN / 1000 .mod 10) + $30
	.byte	<(MAIN / 100 .mod 10) + $30
	.byte	<(MAIN / 10 .mod 10) + $30
	.byte	<(MAIN / 1 .mod 10) + $30
	.byte	0		; end of line
@end:	.word	0		; end of program


;*********************************************************************
; Starting entry point for this program
;
MAIN:
	ldx $FFFC
	ldy $FFFD
	stx $0318
	sty $0319		; enable RESTORE key as RESET
	lda MACHINE
	cmp #5
	beq NTSC
	cmp #12
	beq PAL
READY:	jmp RESET		; not a VIC?
	;
	; NTSC setup
NTSC:	ldx #<@NTSC		; load the timer low-byte latches
	stx $9126
	ldx #>@NTSC
	lda #117 - 24		; raster line 234/235 ($75)
	bne IRQSYNC
@NTSC = (261 * 65 - 2)		; $4243
	;
	; PAL setup
PAL:	ldx #<@PAL		; load the timer low-byte latches
	stx $9126
	ldx #>@PAL
	lda #130 - 24		; raster line 260/261 ($82)
	bne IRQSYNC
@PAL = (312 * 71 - 2)		; $5686
	;
IRQSYNC:
	cmp VIC + 4
	bne IRQSYNC
	stx $9125		; load T1 latch high
				; and transfer both bytes to T1 counter

	; setup my background processing
	.global MYIRQ
	SEI
	LDX #<MYIRQ
	LDY #>MYIRQ
	STX $0314
	STY $0315
	CLI


;*********************************************************************
; Now that all the VIC startup initialization stuff is completed,
; you can append one-time startup code/data here, i.e., like a splash
; title screen.  Then, you must jump to your CODE segment, linked
; outside of VIC's internal RAM address space ...
;
RUNONCE:
@loop:
	lda $028D
	and #2			; got C= key?
	bne @go
	ldy #0
	sty $9113
	lda #$FF
	sta $9122
	lda $9111
	and #$20		; got joystick FIRE ?
	bne @loop
@go:
	rts


MYIRQ:
	lda #0
	ldx #8
	stx VIC + $0f
	ldy VIC + 4
	iny
	iny
@ns:	cpy VIC + 4
	bne @ns
	sta VIC + $0f

@cycle:
	inc VIC + $0f
	bne @cycle

	stx VIC + $0f
	lda VIC + 4
	clc
	adc #4
@vs:	cmp VIC + 4
	bne @vs

	lda #27
	sta VIC + $0f		; white screen / cyan border
	jmp $eabf


;*********************************************************************
; VIC user-definable characters
;
; If < 64 will be used for the software sprite stack, the remaining
; unused characters can be used for other custom graphics, beginning
; at $1C00 where "@", "A", "B", ... characters can be redefined.
;
; Do not use this as an initialized segment if you plan on linking
; this source as a future game cartridge later.  You must COPY any
; read-only data into this address space.
;
; If your data was saved from some tool in binary format, you can
; include that binary file here as:
;		.incbin "udc.bin"
;
; else, just enter each 8x8 values here, such as:
;	.byte	$FF,$81,$81,$81,$81,$81,$81,$FF
; or:
;	.byte	%11111111	; square
;	.byte	%10000001
;	.byte	%10000001
;	.byte	%10000001
;	.byte	%10000001
;	.byte	%10000001
;	.byte	%10000001
;	.byte	%11111111
;
;	.segment "UDC"

