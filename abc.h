;***********************************************************************
; VIC 20: Awesome Boot Cartridge
;   written by Robert Hurst <robert@hurst-ri.us>
;   updated version: 21-Oct-2015
;
; relevant VIC 20 symbols for your program's use or reference
;
RNDSEED		= $8B		; -$8F: BASIC RND seed value
JIFFYH		= $A0		; jiffy clock high
JIFFYM		= $A1		; jiffy clock med
JIFFYL		= $A2		; jiffy clock low
DATANEXT	= $A6		; DATASETTE pointer (0-191)
KEYCHARS	= $C6		; number of characters in KEYBUF (0-10)
RVSFLAG		= $C7		; character reverse flag
ROWS		= $C8		; current screen row length (16-24)
CURSOR		= $CC		; cursor enable (0=flash)
CRSRCHAR	= $CE		; character under cursor
SCRNLINE	= $D1		; pointer to cursor's screen line
CRSRCOL		= $D3		; position of cursor on screen line
CRSR		= $D4		; programmed cursor (0=direct)
COLS		= $D5		; current screen line length (16-24)
CRSRROW		= $D6		; screen row where cursor is
INSERTS		= $D8		; # of INSERTs outstanding
LINKLINE	= $D9		; -$F0: screen line link table (24-bytes)
SCRTEMP1	= $F1		; dummy screen link
SCRTEMP2	= $F2		; screen row marker
COLORLINE	= $F3		; pointer to cursor's color line
KEYBOARD	= $F5		; keyboard pointer
RECEIVE		= $F7		; serial receive pointer
TRANSMIT	= $F9		; serial transmit pointer
BASICTMP	= $FF		; BASIC storage
INPUT		= $0200		; -$0258: 89-character BASIC INPUT buffer
KEYBUF		= $0277		; -$0280: 10-character keyboard buffer
COLORCODE	= $0286		; current cursor color
CRSRCOLOR	= $0287		; color under cursor
SCRNPAGE	= $0288		; active screen memory page (unexpanded = $1E)
SHIFTMODE	= $0291		; 0=allow, 128=locked
SCROLLFLAG	= $0292		; auto scrolldown flag
TEMPA		= $030C		; temp storage for A register
TEMPX		= $030D		; temp storage for X register
TEMPY		= $030E		; temp storage for Y register
TEMPP		= $030F		; temp storage for P register
VECTORS		= $0310		; -$033B: VIC ROM jump vectors
DATASETTE	= $033C		; -$03FB: 192-byte tape input buffer
RAM0		= $0400		; -$0FFF: 3K expansion
RAM		= $1000		; -$1FFF: internal memory
RAM1		= $2000		; -$3FFF: 8K expansion
RAM2		= $4000		; -$5FFF: 8K expansion
RAM3		= $6000		; -$7FFF: 8K expansion
PET		= $8000		; -$8FFF: 4k character rom
MASK		= $8270		; ROM character $4D: Shift-N (/)
VIC		= $9000		; start of Video Interface Chip registers
CART		= $A000		; -$BFFF: 8K expansion
; ****	VIC BASIC & KERNAL ROM	****
PRINT		= $CB1E		; print null-terminated string
PRINTUINT	= $DDCD		; print XA as unsigned integer
BASSFT		= $E467		; BASIC warm start
MACHINE		= $EDE4		; NTSC=$05, PAL=$0C
STOPKEY		= $F770		; check for STOP key pressed
RESET		= $FD22		; warm startup
VECTOR		= $FF8D		; read/set vectored I/O
RESTOR		= $FF8A		; restore default I/O vectors
SETMSG		= $FF90		; control KERNAL messages
SECOND		= $FF93		; send secondary address after LISTEN
TKSA		= $FF96		; send secondary address after TALK
MEMTOP		= $FF99		; read/set the top of memory
MEMBOT		= $FF9C		; read/set the bottom of memory
SCNKEY		= $FF9F		; scan keyboard
SETTMO		= $FFA2		; set timeout on serial bus
ACPTR		= $FFA5		; input byte from serial port
CIOUT		= $FFA8		; output byte to serial port
UNTLK		= $FFAB		; command serial bus device to UNTALK
UNLSN		= $FFAE		; command serial bus device to UNLISTEN
LISTEN		= $FFB1		; send LISTEN command
TALK		= $FFB4		; send TALK command
READST		= $FFB7		; read I/O status word
SETLFS		= $FFBA		; set logical, first and second addresses
SETNAM		= $FFBD		; set filename
OPEN		= $FFC0		; open a logical file
CLOSE		= $FFC3		; close a logical file
CHKIN		= $FFC6		; open channel for input
CHKOUT		= $FFC9		; open channel for output
CLRCHN		= $FFCC		; close input and out channels
CHRIN		= $FFCF		; input character from channel
CHROUT		= $FFD2		; output character to channel
LOAD		= $FFD5		; load RAM from a device
SAVE		= $FFD8		; save RAM to device
SETTIM		= $FFDB		; set real time clock
RDTIM		= $FFDE		; read real time clock
STOP		= $FFE1		; scan STOP key
GETIN		= $FFE4		; get a character from keyboard queue
CLALL		= $FFE7		; close all channels and files
UDTIM		= $FFEA		; increment real time clock
SCREEN		= $FFED		; return X,Y organization of screen
PLOT		= $FFF0		; read/set X,Y cursor position
IOBASE		= $FFF3		; returns base address of I/O devices

