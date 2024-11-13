;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; `ASM.A' -- Source code for 8086 assembler main executable `ASM.COM'.
;
; Copyright (c) 2001 Stephen Duffy <scfduffy@gmail.com>
; Copyright (c) 2020-2021 Robert Riebisch <rr@bttr-software.de>
;
; Usage of the works is permitted under the terms of the GNU GPL v2.
; See `LICENSE' file for details.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BITS 16

global _start


maxexplen	equ 80
maxsymlen	equ 30
symstack	equ 0b000h
buflen		equ 80



;	jmp start	; jump to main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; data starts here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .data                   ;section declaration


; user-interface messages except errors
msg_banner:	db "8086 Assembler for ELKS",13,10
		db "Copyright (c) 2001 Stephen Duffy",13,10
		db "Copyright (c) 2020-2021 Robert Riebisch",13,10
		db "Copyright (c) 2024 Rafael Diniz",13,10
        db "[Under GNU GPL v2]",13,10
		db 13,10,0
msg_pass:	db ">> Pass ",0
msg_started:	db " started",13,10,0
msg_finished:	db "<< Finished successfully",13,10,0
msg_linesproc:	db " lines processed",13,10,0
msg_byteswrit:	db " bytes written",13,10,0
msg_errline:	db "Error at line ",0
msg_colon:	db ": ",0
msg_tab:	db "  ",0
msg_crlf:	db 13,10,0

; error messages regarding source code
;  return code for DOS + ASCIIZ message for user
errmsg_strtoolong:	db   1,"String too long",13,10,0
errmsg_linetoolong:	db   2,"Line too long",13,10,0
errmsg_unknownmne:	db   3,"Unknown mnemonic",13,10,0
errmsg_invparams:	db   4,"Illegal parameters",13,10,0
errmsg_illidir:		db   5,"Illegal expression",13,10,0
errmsg_ptrexp:		db   6,"`PTR' expected",13,10,0
errmsg_ptrtoolarge:	db   7,"Pointer too large",13,10,0
errmsg_inviform:	db   8,"Invalid instruction format",13,10,0
errmsg_badregmix:	db   9,"Invalid register size",13,10,0
errmsg_invnumform:	db  10,"Bad literal",13,10,0
errmsg_littoolarge:	db  11,"Literal too large",13,10,0
errmsg_offtoolarge:	db  12,"Address too far",13,10,0
errmsg_toomanysym:	db  13,"Too many symbols",13,10,0
errmsg_invsymnam:	db  14,"Symbol name too long",13,10,0
errmsg_undefsym:	db  15,"Unknown symbol",13,10,0

; other error messages ("runtime environment")
;  return codes >200 will skip calling printinst() function on error
errmsg_inferr:		db 201,"Input file error",13,10,0
errmsg_ouferr:		db 202,"Output file error",13,10,0

; special error message for DOS 1.x (no return code possible)
errmsg_baddos:		db     "DOS 2.0 or higher required",13,10,0

; temporary data
;  When `ASM.COM' will support uninitialized data, these are candidates to
;  save 880 bytes disk space. Need to call an initialization function on
;  program start then.

; each 80 bytes large
lineStore:
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
labelStore:
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
mnemonicStore:
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
expsetStore:
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
exp1Store:
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
exp2Store:
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; each 160 bytes large
codeStore:
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
tempbuffer:
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; FIXME
; Move `getsbuffer' before `codeStore' and on `ASM.COM ASM.A' you will get:
;  >> Pass 1 started
;  Error at line 50: Bad literal
;    errmsg_littoolarge  db  11,"
; Probably something gets overwritten.

; 80 bytes large
getsbuffer:
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
___getsbuffer:

digitlist:
	db "00112233445566778899aAbBcCdDeEfFgGhHiIjJkK"
	db "lLmMnNoOpPqQrRsStToOpPqQrRsStTuUvVwWxXyYzZ",0
destructivedl:
	db "00112233445566778899aAbBcCdDeEfFgGhHiIjJkK"
	db "lLmMnNoOpPqQrRsStToOpPqQrRsStTuUvVwWxXyYzZ",0
delimiters:
	db "� `�!",'"',"%^&*()-+=[{]};:'~,<.>/?",92,"|",0
indirectRegs:
	db "bp",0,1
	db "bx",0,2
	db "di",0,4
	db "si",0,8
___indirectRegs:
iregcomb: ;convs dl from "decodeIndirect" to exp type
	db 10,6,9,5,8,4,0,2,1
	db 0,1,2,3,4,5,6,7,6
___iregcomb:
bptr:	db "byte",0
wptr:	db "word",0
dptr:	db "dword",0
qptr:	db "qword",0
aptr:	db "ptr",0
farstring:
	db "far",0
regnames:
	db "ah",0,32,4
	db "al",0,32,0
	db "ax",0,48,0
	db "bh",0,32,7
	db "bl",0,32,3
	db "bp",0,48,5
	db "bx",0,48,3
	db "ch",0,32,5
	db "cl",0,32,1
	db "cs",0,64,1
	db "cx",0,48,1
	db "dh",0,32,6
	db "di",0,48,7
	db "dl",0,32,2
	db "ds",0,64,3
	db "dx",0,48,2
	db "es",0,64,0
	db "si",0,48,6
	db "sp",0,48,4
	db "ss",0,64,2
___regnames:
segregs:
	db "cs",0
	db "ds",0
	db "es",0
	db "ss",0
___segregs:
mnemonics:
	db "aaa",0,0,0,0,    1ah
	db "aad",0,0,0,0,    1dh
	db "aam",0,0,0,0,    1ch
	db "aas",0,0,0,0,    1bh
	db "adc",0,0,0,0,    02h
	db "add",0,0,0,0,    00h
	db "and",0,0,0,0,    04h
	db "call",0,0,0,     3ah
	db "cbw",0,0,0,0,    64h
	db "clc",0,0,0,0,    88h
	db "cld",0,0,0,0,    8ch
	db "cli",0,0,0,0,    8ah
	db "cmc",0,0,0,0,    85h
	db "cmp",0,0,0,0,    07h
	db "cmpsb",0,0,      56h
	db "cmpsw",0,0,      57h
	db "cs:",0,0,0,0,    09h
	db "cwd",0,0,0,0,    65h
	db "daa",0,0,0,0,    18h
	db "das",0,0,0,0,    19h
	db "dec",0,0,0,0,    39h
	db "div",0,0,0,0,    36h
	db "ds:",0,0,0,0,    0bh
	db "es:",0,0,0,0,    08h
	db "hlt",0,0,0,0,    84h
	db "idiv",0,0,0,     37h
	db "imul",0,0,0,     35h
	db "in",0,0,0,0,0,   76h
	db "inc",0,0,0,0,    38h
	db "int",0,0,0,0,    6fh
	db "into",0,0,0,     70h
	db "iret",0,0,0,     71h
	db "ja",0,0,0,0,0,   47h
	db "jae",0,0,0,0,    43h
	db "jb",0,0,0,0,0,   42h
	db "jbe",0,0,0,0,    46h
	db "jc",0,0,0,0,0,   42h
	db "jcxz",0,0,0,     0e3h
	db "je",0,0,0,0,0,   44h
	db "jg",0,0,0,0,0,   4fh
	db "jge",0,0,0,0,    4dh
	db "jl",0,0,0,0,0,   4ch
	db "jle",0,0,0,0,    4eh
	db "jmp",0,0,0,0,    3ch
	db "jna",0,0,0,0,    46h
	db "jnae",0,0,0,     42h
	db "jnb",0,0,0,0,    43h
	db "jnbe",0,0,0,     47h
	db "jnc",0,0,0,0,    43h
	db "jne",0,0,0,0,    45h
	db "jng",0,0,0,0,    4eh
	db "jnge",0,0,0,     4ch
	db "jnl",0,0,0,0,    4dh
	db "jnle",0,0,0,     4fh
	db "jno",0,0,0,0,    41h
	db "jnp",0,0,0,0,    4bh
	db "jns",0,0,0,0,    49h
	db "jnz",0,0,0,0,    45h
	db "jo",0,0,0,0,0,   40h
	db "jp",0,0,0,0,0,   4ah
	db "jpe",0,0,0,0,    4ah
	db "jpo",0,0,0,0,    4bh
	db "js",0,0,0,0,0,   48h
	db "jz",0,0,0,0,0,   44h
	db "lahf",0,0,0,     6ah
	db "lds",0,0,0,0,    6dh
	db "lea",0,0,0,0,    62h
	db "les",0,0,0,0,    6ch
	db "lock",0,0,0,     80h
	db "lodsb",0,0,      5ch
	db "lodsw",0,0,      5dh
	db "loop",0,0,0,     0e2h
	db "loope",0,0,      0e1h
	db "loopne",0,       0e0h
	db "loopnz",0,       0e0h
	db "loopz",0,0,      0e1h
	db "mov",0,0,0,0,    61h
	db "movsb",0,0,      54h
	db "movsw",0,0,      55h
	db "mul",0,0,0,0,    34h
	db "neg",0,0,0,0,    33h
	db "nop",0,0,0,0,    63h
	db "not",0,0,0,0,    32h
	db "or",0,0,0,0,0,   01h
	db "out",0,0,0,0,    77h
	db "pop",0,0,0,0,    3fh
	db "popf",0,0,0,     68h
	db "push",0,0,0,     3eh
	db "pushf",0,0,      67h
	db "rcl",0,0,0,0,    12h
	db "rcr",0,0,0,0,    13h
	db "rep",0,0,0,0,    83h
	db "repe",0,0,0,     83h
	db "repne",0,0,      82h
	db "repnz",0,0,      82h
	db "repz",0,0,0,     83h
	db "ret",0,0,0,0,    6bh
	db "retf",0,0,0,     6eh
	db "rol",0,0,0,0,    10h
	db "ror",0,0,0,0,    11h
	db "sahf",0,0,0,     69h
	db "sar",0,0,0,0,    17h
	db "sbb",0,0,0,0,    03h
	db "scasb",0,0,      5eh
	db "scasw",0,0,      5fh
	db "shl",0,0,0,0,    14h
	db "shr",0,0,0,0,    15h
	db "ss:",0,0,0,0,    0ah
	db "stc",0,0,0,0,    89h
	db "std",0,0,0,0,    8dh
	db "sti",0,0,0,0,    8bh
	db "stosb",0,0,      5ah
	db "stosw",0,0,      5bh
	db "sub",0,0,0,0,    05h
	db "test",0,0,0,     30h
	db "wait",0,0,0,     66h
	db "xchg",0,0,0,     60h
	db "xlat",0,0,0,     72h
	db "xor",0,0,0,0,    06h
___mnemonics:
mneTranslate:
	db 01ah,037h,01dh,0d5h,01ch,0d4h,01bh,03fh,064h,098h,088h,0f8h,08ch,0fch
	db 08ah,0fah,085h,0f5h,056h,0a6h,057h,0a7h,009h,02eh,065h,099h,018h,027h
	db 019h,02eh,00bh,03eh,008h,026h,084h,0f4h,070h,0ceh,071h,0cfh,06ah,09fh
	db 080h,0f0h,05ch,0ach,05dh,0adh,054h,0a4h,055h,0a5h,063h,090h,068h,09dh
	db 067h,09ch,082h,0f2h,083h,0f3h,06bh,0c3h,06eh,0cbh,069h,09eh,05eh,0aeh
	db 05fh,0afh,00ah,036h,089h,0f9h,08dh,0fdh,08bh,0fbh,05ah,0aah,05bh,0abh
	db 066h,09bh,072h,0d7h
equalityText:
	db "equ",0
PseudoOps:
	db "db",0,0,0,0,0,0,0
	db "dw",0,0,0,0,0,0,1
	db "equ",0,0,0,0,0,2
	db "=",0,0,0,0,0,0,0,2
___PseudoOps:

assumedbase:	dw 10
nextSymbol:	dw symstack
symbolLoad:	dw 0
curip:		dw 0
codebase:	dw 100h
codelen:	dw 0
line:		dw 0
curpass:	db 1
addrspec:	dw 0
containslabel:	dw 0
inf:		dw 0
ouf:		dw 0
nextpos:	dw 0
bufend:		dw 0
eof:		dw 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code starts here (no more data)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .text                   ;section declaration

strlen:
	push di
	push cx
	mov al,0
	mov cx,-1
	cmp cx,cx
	cld
	repnz
	scasb
	neg cx
	dec cx
	dec cx
	xchg ax,cx
	pop cx
	pop di
	ret

strrev:
	push si
	push di
	push ax
	mov si,di
	call strlen
	dec ax
	add si,ax
___strrev:
	mov al,[di]
	mov ah,[si]
	mov [si],al
	mov [di],ah
	inc di
	dec si
	cmp di,si
	jl ___strrev
	pop ax
	pop di
	pop si
	ret


ntos: ;(ax=num,bx=base,di=string)
	push ax
	push bx
	push cx
	push dx
	push di
___ntos:
	xor dx,dx
	div bx
	xchg ax,cx
	mov al,dl
	cmp al,9
	jle ___notalpha
	add al,7
___notalpha:
	add al,48
	mov [di],al
	inc di
	xchg cx,ax
	cmp ax,0
	jne ___ntos
	mov word [di],0
	pop di
	call strrev
	pop dx
	pop cx
	pop bx
	pop ax
	ret

printnum:
	push di
	push bx
	mov di,tempbuffer
	mov bx,10
	call ntos
	call prints
	pop bx
	pop di
	ret

prints:
	push ax
	push bx
	push cx
	push dx
	call strlen
    mov cx,di
    mov dx,ax
    mov bx,1
    mov ax,4
    int 0x80
	pop dx
	pop cx
	pop bx
	pop ax
	ret


_start:
	mov di,msg_banner
	call prints
; run two passes on the source code
___nextpass:
	mov di,msg_pass
	call prints
	mov al,[curpass]
	cbw
	call printnum
	mov di,msg_started
	call prints
	cmp byte [curpass],2
	je ___pass2
	; call openfiles	; on pass 1 only
	or cx,cx	; CX=0?
	jz ___error
	xor cx,cx	; CX:=0
	jz ___anypass
___pass2:
	;call rewind
	;call sortsym
	mov cx,1
___anypass:
	;call pass
	or cx,cx	; CX=0?
	jz ___error
	mov ax,[line]	; start printing pass statistics
	call printnum
	mov di,msg_linesproc
	call prints
	cmp byte [curpass],2
	jne ___notpass2
	mov ax,[codelen]	; print on pass 2 only
	call printnum
	mov di,msg_byteswrit
	call prints
___notpass2:
	mov di,msg_finished
	call prints
	mov al,[curpass]
	cmp al,1
	jne ___notpass1
	mov di,msg_crlf	; print on pass 1 only
	call prints
___notpass1:
	inc al
	mov [curpass],al
	cmp al,2
	jbe ___nextpass
	xor al,al	; AL:=0 return code
	jz ___start	; no more passes
; print error message (and top of stores)
___error:
	mov si,di
	mov di,msg_errline
	call prints
	mov ax,[line]
	call printnum
	mov di,msg_colon
	call prints
	cld
	lodsb	; load return code from error message
	mov di,si
	call prints	; print error message
	cmp al,200	; return code >200?
	ja ___start
	;call printinst
___start:
	;call closefiles
; return to ELKS
    mov     bx,0                ;1st syscall arg: exit code
    mov     ax,1                ;system call number (sys_exit)
    int     0x80                ;call kernel
___endofcode: