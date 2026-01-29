;***********************************************************************
; SLIK module header
;  written by Robert Hurst <robert@hurst-ri.us>
;  updated version: 02-Jan-2016
;
; runtime SLIK memory map
;
USRJ		= $00		; indirect index
VECTOR0		= $01		; indirect register
SLIKVTMP	= $C7
IRQZP		= $D9		; +0 thru +23
IRQFIELD	= $D9		; current
IRQFIELD2	= $DB
IRQCOLOR	= $DD		; current
IRQCOLOR2	= $DF
IRQFLIP		= $F0		; cmd register
SLIKLP		= $F1		; list pointer
SLIKLP2		= $F2		; list pointer
VECTOR1		= $F7		; indirect register
VECTOR2		= $F9		; indirect register
VECTOR3		= $FB		; indirect register
VECTOR4		= $FD		; indirect register

;SLIK use of zero page
; dirty buffer copying: FROM, TO, ATTR
; sprite rendering: FORE, BACK, TO

				; VECTORS - VECTORS+3
SLIKSCLIPX	= $0334		; pixels to right border: 8 * (PLAYCOLS + 2)
SLIKSCLIPY	= $0335		; pixels to bottom border: 8 * (PLAYROWS + 2)
SLIKXYZ		= $0336		; 
SLIKVMODE	= $0337		; video graphics mode
SLIKVBACK	= $0338		; video page rendering before swap
SLIKVFORE	= $0339		; video page active after swap
SLIKVCOLOR	= $033A		; video page playing color, with each cell:
				; b7: dirty bit for video page 1 only
				; b6: dirty bit for video page 2 only
				; b5: dirty bit for pending page
				; b4: static cell bit, sprites go behind
				; b3: multicolor mode
				; b0-2: cell coloring
SLIKVFIELD	= $033B		; video page playing field

; Ultimem's IO2&3 memory
SLIKINDEXLIST = $9800
SLIKCOLORLIST = $9900
SLIKFIELDLIST = $9A00
SLIKFIELD1 = $9C00
SLIKFIELD2 = $9E00


;*********************************************************************
; useful ca65 .asciiz translations to CBM codes for print string
;
.charmap '@', $80
.charmap 'A', $81
.charmap 'B', $82
.charmap 'C', $83
.charmap 'D', $84
.charmap 'E', $85
.charmap 'F', $86
.charmap 'G', $87
.charmap 'H', $88
.charmap 'I', $89
.charmap 'J', $8A
.charmap 'K', $8B
.charmap 'L', $8C
.charmap 'M', $8D
.charmap 'N', $8E
.charmap 'O', $8F
.charmap 'P', $90
.charmap 'Q', $91
.charmap 'R', $92
.charmap 'S', $93
.charmap 'T', $94
.charmap 'U', $95
.charmap 'V', $96
.charmap 'W', $97
.charmap 'X', $98
.charmap 'Y', $99
.charmap 'Z', $9A
.charmap '{', $9B
.charmap '|', $9C	; British pound symbol
.charmap '}', $9D
.charmap '^', $9E	; uparrow symbol
.charmap '`', $9F	; left arrow symbol
.charmap ' ', $A0
.charmap '!', $A1
.charmap '"', $A2
.charmap '#', $A3
.charmap '$', $A4
.charmap '%', $A5
.charmap '&', $A6
.charmap ''', $A7
.charmap '(', $A8
.charmap ')', $A9
.charmap '*', $AA
.charmap '+', $AB
.charmap ',', $AC
.charmap '-', $AD
.charmap '.', $AE
.charmap '/', $AF
.charmap '0', $B0
.charmap '1', $B1
.charmap '2', $B2
.charmap '3', $B3
.charmap '4', $B4
.charmap '5', $B5
.charmap '6', $B6
.charmap '7', $B7
.charmap '8', $B8
.charmap '9', $B9
.charmap ':', $BA
.charmap ';', $BB
.charmap '<', $BC
.charmap '=', $BD
.charmap '>', $BE
.charmap '?', $BF
.charmap '~', $DE	; PI symbol

