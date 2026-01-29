;***********************************************************************
; VIC 20: Awesome Boot Cartridge
;   written by Robert Hurst <robert@hurst-ri.us>
;   updated version: 05-Jan-2016
;
	.fileopt author, "Robert Hurst"
	.fileopt comment, "VIC 20: Awesome Boot Cartridge"
	.fileopt compiler, "ca65"
	.setcpu "6502"

	.proc ABC
	.include "abc.h"


;***********************************************************************
; Awesome Boot Cartridge: constants
;
	.segment "CART"

	.word RAM5		; PRG load address off floppy

	; ROM boot signature
RAM5:	.word ABC		; starting address
	.word NMI		; RESTORE key address
A0CBM:	.byte $41, $30, $C3, $C2, $CD

	; floppy disk commands
CMDVIC:	.byte "UI-"		; initialize directive for VIC 20 speed
CMDABC: .byte "$ABC"		; directive for access to directory
CMDRUN: .byte "$AUTORUN",0	; directive for access to directory
CMDPRG: .byte "$*=P"		; directive for access to directory

	; string constants
MSG1:	.byte 13,144,"SCANNING DRIVES ...",13,31,0
MSG2:	.byte 13,144,"-",28,"ABC FLOPPY NOT FOUND",144,"-",0
MSG3:	.byte 13,144," ",18," RESTORE ",146," KEY: RESET",13,0
MSG4:	.byte 13," ",158,18," F1 ",146,31," BASIC ",158,18," F3 ",146,31," +3K",13
	.byte 13," ",158,18," F5 ",146,31," +ANY  ",158,18," F7 ",146,31," SCAN",13,0
MSG5:	.byte 146,"   ",157,157,157,0
MSG6:	.byte 13,144,"BOOTING ",0


;***********************************************************************
; RESTORE key was pressed -- make it an ABC warm reset function key
;
NMI:
	lda #$FF		; acknowledge and clear
	sta $9122		; interrupts
	ldy $9111


;***********************************************************************
; AWESOME BOOT CARTRIDGE: entry point
;
ABC:
	; initialize VIC Kernal
	jsr $FD8D		; ramtas	Initialize System Constants (memory pointers)
	jsr $FD52		; restor	Restore Kernal vectors (at 0314)
	jsr $FDF9		; ioinit	Initialize I/O (timers are enabled)
	jsr $E518		; cint1		Initialize I/O (VIC reset, must follow ramtas)

	; initialize VIC BASIC
	jsr $E45B		; initv		Initialize vectors
	jsr $E3A4		; initcz	Initialize BASIC RAM

	ldy $0282
	cpy #$10
	bcc @welcome		; +3K only detected?
	; look for added presence of a 3K memory expander
@fp:	lda $0323,y
	sta $0fef,y
	cmp $0fef,y
	bne @welcome
	dey
	bne @fp			; reset start of memory to include RAM0, obviously
	sty $2C			; not for BASIC use, but for banner purposes only

	; welcome banner
@welcome:
	lda #1			; just to have some fun:
	sta RVSFLAG		; - character reverse flag
	lda #3			; - set color to CYAN
	sta COLORCODE
	jsr $E404		; initms	Output power-up message


;***********************************************************************
; VIC IEC startup
;
IEC:
	; probe IEC units #11 thru #8 for an ABC program signature
	; useful for that uIEC device typically set higher than #8
	lda #<MSG1
	ldy #>MSG1
	jsr PRINT
	ldx #11
	stx $BA			; current device
@scan:
	lda #1			; LF: logical file
	sta $10			; and set flag to print the floppy label
	ldx $BA			; IN: device
	ldy #15			; SA: secondary address
	jsr SETLFS
	lda #3			; "UI-"
	ldx #<CMDVIC
	ldy #>CMDVIC
	jsr SETNAM
	jsr OPEN
	bcs @notopen
	; print "#n:"
	lda #35
	jsr CHROUT
	ldx $BA
	lda #0
	jsr PRINTUINT
	lda #':'
	jsr CHROUT
	jsr DEVST		; ok, validate device status
	lda #4			; "$ABC", VDrive does not support "$ABC=P"
	ldx #<CMDABC		; SF ticket #587
	ldy #>CMDABC
	jsr DIRPRG
	dec CRSRROW
@notopen:
	lda #1			; cleanup
	jsr CLOSE
	jsr CLRCHN
	lda $AA			; number of PRG entries found
	bne @passed		; found!
	ldx CRSRROW
	ldy #0
	clc
	jsr PLOT
	dec COLORCODE
	dec $BA
	ldx $BA
	cpx #8
	bcs @scan

	; error, ABC wants ABC on its floppy too:
	lda #<MSG2
	ldy #>MSG2
	jsr PRINT
	jmp MENU

@passed:
	dec $10
	lda #8
	ldx #<CMDRUN
	ldy #>CMDRUN
	jsr DIRPRG
	lda $AA
	beq MENU
	ldx #<(CMDRUN+1)
	ldy #>(CMDRUN+1)
	stx $FD
	sty $FE
	lda #0
	jmp BOOT


;***********************************************************************
; USER MENU
;
MENU:
	lda #<MSG3
	ldy #>MSG3
	jsr PRINT
@reload:
	lda #<MSG4
	ldy #>MSG4
	jsr PRINT
	jsr ALLPRG		; refresh up to (in theory) 224 PRG dir entries
	jsr SHOW8
@getin:	jsr GETIN
	beq @getin
@f1:	cmp #133		; f1 key
	bne @f3
	lda #$10		; unexpanded
@1e:	sta $0282
	lda #$1E
	sta $0284
	sta SCRNPAGE
@basic:	jmp $FD32		; resume BASIC startup
@f3:	cmp #134		; f3 key
	bne @f5
	ldy $2C
	cpy #$10		; no 3K expansion detected?
	bcs @getin
	lda #$04		; make 3K expanded
	bne @1e
@f5:	cmp #135		; f5 key
	bne @f7
	lda SCRNPAGE
	cmp #$10		; no 8K expansion detected?
	bne @getin
	beq @basic
@f7:	cmp #136		; f7 key
	bne @digit
	jmp IEC			; app warm reset
@digit:
	cmp #'8'+1
	bcs @8
	cmp #'1'
	bcc @8
	sbc #'1'
	jmp BOOT
@8:	lda $AA
	beq @reload
	lda #13
	jsr CHROUT
	jsr SHOW8		; any key
	jmp @getin


;***********************************************************************
; get device status: INPUT#1,A$,B$ into BASIC input buffer
;
DEVST:
	lda CRSRCOL
	pha
	lda CRSRROW
	pha
	ldy #1
	sty $08			; scan flag
	dey
	sty $0B			; input buffer pointer
	beq @cont
@exit:
	ldy $0B
	ldx #5
	lda #' '
@pad:	sta $0200,Y
	iny
	dex
	bne @pad
	lda #0
	sta $0200,Y
	ldy #2
	jsr PRINT		; print device status
	pla
	sta CRSRROW
	pla
	sta CRSRCOL
        rts
@cont:
	ldx #1			; LF
	jsr CHKIN
@input:	jsr @getbyte
	cmp #','
	bne @save
	dec $08
	bne @exit
@save:	ldy $0B
	sta $0200,Y
	inc $0B
	bne @input
@getbyte:
	jsr READST
	bne @end		; read error or end of file
	jmp CHRIN
@end:	pla
	pla
	jmp @exit


;***********************************************************************
; cache the current directory of PRG files
;
ALLPRG:
	lda #4			; "$*=P"
	ldx #<CMDPRG
	ldy #>CMDPRG
DIRPRG:
	jsr SETNAM
	lda #2			; LF
	ldx $BA
	ldy #0			; secondary address 0 (required for dir)
	jsr SETLFS

	ldy #0
	sty $AA			; number of entries
	jsr OPEN
	bcs @exit
	; reset directory cache
	ldx $0281
	ldy $0282
	stx $FB			; start display of PRGs
	sty $FC
	stx $FD			; heh, $FD can mean floppy disk
	sty $FE

	ldx #2			; LF
	jsr CHKIN

	ldy #4			; or 6 if @shred
@label:	jsr @getbyte
	dey
	bne @label
	; floppy label
@shred:	;JSR @getbyte		; skip disk label
	;BNE @shred
	ldy #1
	sty $08			; scan flag
	lda #157		; cursor left
	jsr CHROUT
	lda #' '		; print a space first
	jsr CHROUT
@char:	ldx $10
	beq @gt
	jsr CHROUT
@gt:	jsr @getbyte
	cmp #34
	bne @char
	dec $08
	beq @gt			; continue until end of line
@eol:	jsr @getbyte
	bne @eol
	;
@next:	ldy #4			; skip 4 bytes on all lines
@eat:	jsr @getbyte		; get a byte from dir and ignore it
	dey
	bne @eat
@cat:	jsr @getbyte
	cmp #34
	bne @cat
	ldy #0
@prg:	jsr @getbyte
	cmp #34
	beq @save
	sta ($FD),Y
	iny
	bne @prg
@save:	inc $AA
	lda #0
	sta ($FD),Y		; null-terminate
	iny
	tya
	clc
	adc $FD
	bcc @lo
	inc $FE
	sta $FD
	lda #'.'		; mark every page as consumed
	jsr CHROUT
	bne @eol
@lo:	sta $FD
@eol2:	jsr @getbyte
	bne @eol2
	jmp @next

@exit:
	lda #2			; LF
	jsr CLOSE
	jsr CLRCHN
	lda #13
	jsr CHROUT
	rts

@getbyte:
	jsr READST
	bne @err		; read error or end of file
	jmp CHRIN
@err:
	pla			; don't return to dir reading loop
	pla
	jmp @exit


;***********************************************************************
; display next 8 cached PRG files 
;
SHOW8:
	LDX $FB
	LDY $FC
	STX $FD			; save top of displayed items
	STY $FE			; for potential user selection later
	LDX #0
	STX TEMPX
	STX TEMPY
@loop:
	LDY TEMPY
	CPY $AA			; number of entries
	BCS @exit
	LDA #18
	JSR CHROUT
	LDA COLORCODE
	EOR #2
	STA COLORCODE
	LDA TEMPX
	CLC
	ADC #'1'
	JSR CHROUT
	LDA #146
	JSR CHROUT
	LDA #' '
	JSR CHROUT
	LDA $FB
	LDY $FC
	JSR PRINT
	LDX CRSRCOL
	DEX
	TXA
	CLC
	ADC $FB
	BCC @lo
	INC $FC
@lo:	STA $FB
	LDA #13
	JSR CHROUT
	INC TEMPY
	INC TEMPX
	LDX TEMPX
	CPX #8
	BNE @loop
@exit:
	LDX #0
	LDA $AA
	CMP #8
	BCC @nomore
	SBC #8
	TAX
@nomore:
	STX $AA
	RTS


;***********************************************************************
; boot the selected file using intellisense for VIC 20 memory config
;
BOOT:
	LDY #0
	TAX
	BEQ @gotit
@next:	INY			; assume at least 1-character filename
	LDA ($FD),Y
	BNE @next
	DEX
	BNE @next
	INY			; offset into directory cache
@gotit:
	TYA
	CLC
	ADC $FD
	BCC @lo
	INC $FE
@lo:	STA $FD
	LDY #0
@len:	INY			; assume at least 1-character filename
	LDA ($FD),Y
	BNE @len
	STY $B7			; filename length
@entry:
	lda #<MSG6
	ldy #>MSG6
	jsr PRINT		; booting ...
	lda $FD
	ldy $FE
	jsr PRINT
	lda #1			; LF
	ldx $BA			; last device
	ldy #0			; SA: 0=ignore, 1=use header address
	jsr SETLFS
	lda $B7
	ldx $FD
	ldy $FE
	jsr SETNAM

	; PRG intellisense (ha!)
	jsr OPEN
	bcc @use
	jmp MENU
@use:	ldx #1			; LF
	jsr CHKIN

	jsr @getbyte
	sta $AE
	cmp #2			; load address low
	bcc @hi
	jmp RESET
@hi:	jsr @getbyte
	sta $AF
	lda $AE
	bne @exit
	jsr @getbyte
	cmp #0
	beq @exit
	jmp RESET

@exit:
	lda #1			; LF
	jsr CLOSE
	;JSR CLRCHN
	lda $AF
	cmp #4			; +3k
	beq @VIC
	cmp #$10
	bne @BASIC		; powered up in 8K+ mode already

@VIC:
	sta $0282
	lda #$1E
	sta $0284
	sta SCRNPAGE

@BASIC:	; initialize for BASIC
	jsr $E518		; cint1		Initialize I/O (VIC reset, must follow ramtas)
	jsr $E45B		; initv		Initialize vectors
	jsr $E3A4		; initcz	Initialize BASIC RAM
	jsr $E404		; initms	Output power-up message

	; LOAD program selection
	;JSR $C644		; forced NEW
	lda #$80		; turn on kernal messages
	jsr SETMSG
	lda #0			; 0=LOAD, 1=VERIFY
	ldx $2B			; get start of memory low byte
	ldy $2C			; get start of memory high byte
	jsr LOAD
	stx $2D			; set start of variables low byte
	sty $2E			; set start of variables high byte

	; RUN
	;JSR $C660		; CLR
	jsr $C659		; reset execution to start, clear variables and flush stack
	jmp $C7AE		; goto BASIC

@getbyte:
	jsr READST
	bne @err		; read error or end of file
	jmp CHRIN
@err:
	pla			; don't return to dir reading loop
	pla
	jmp @exit

	.endproc
