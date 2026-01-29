;***********************************************************************
; SLIK graphics for Awesome Boot Cartridge
;   written by Robert Hurst <robert@hurst-ri.us>
;   updated version: 08-Dec-2015
;
	.fileopt author, "Robert Hurst"
	.fileopt comment, "SLIK graphics"
	.fileopt compiler, "ca65"
	.setcpu "6502"

	.include "slik.s"

	.proc ABC
	.segment "JUMP"

	.global SLIKINIT

SLIKAPI:	; cartridge api jump table, i.e., JSR SLIKINIT
SLIKINIT:	JMP SLIK::INIT		; initialize SLIK
SLIKNEW:	JMP SLIK::NEW		; create a new sprite
SLIKANIM:	JMP SLIK::ANIM		; update sprite to use an image
SLIKMOVE:	JMP SLIK::MOVE		; absolute sprite update to X/Y position
SLIKDX:		JMP SLIK::DX		; relative sprite update in X position
SLIKDY:		JMP SLIK::DY		; relative sprite update in Y position
SLIKME:		JMP SLIK::ME		; forces this sprite to render
SLIKMCMASK:	JMP SLIK::MCMASK	; function to return multicolor masking
SLIKREFRESH:	JMP SLIK::REFRESH	; forces all active sprites to render
SLIKEXECUTE:	JMP SLIK::EXECUTE	; IRQ handler

	.endproc

