# 8086 Assembler for DOS

## About

"8086 Assembler for DOS" (or `ASM.COM` for short) is a small 16-bit DOS-based
two-pass self-hosting assembler for the x86 assembly language. -- It was
created by Stephen Duffy in 2001. In December 2020 Robert Riebisch started maintaining this fork.

## Highlights

* Supports the Intel i8086 instruction set.
* Supports the `EQU` pseudo-op to define constants.
* Directly generates `.COM` files. (No separate linker required.)
* 10 KiB small. (6 KiB after [UPX](https://upx.github.io/)-ing.)
* Free and open-source software.

## Limitations

* No support for `.EXE` or `.OBJ` files.
* No support for FPU instructions.
* No support for i80186 (or higher) instructions.
* No support for declaring uninitialized data.
* No support for macros.
* No support for including other source files.
* No support for listings.
* Very limited support for expressions, i.e., only something like
  `mov al,[bx+di]` and `mov ax,word ptr[codestore+2]` works.
* Supports only DOS line endings (CRLF) in source file.
* Maximum line length in source file is 78 characters.
* ...

## Known Bugs

1. `dec r/m8`, `dec r/m16`, and `inc r/m8` instructions are encoded
   incorrectly. This also applies to the `byte ptr` or `word ptr` variants of
   `div`, `idiv`, `imul`, `mul`, `neg`, `not`, and `push`.
2. Better avoid whitespace around the comma between instruction operands.
3. `lds` and `les` instructions always (?) give errors. -- Reported by Japheth.
4. Neither duplicate symbols nor non-existant symbols are recognized. --
   Reported by Japheth.

## System Requirements

* Intel i8086/88 microprocessor (or compatibles)
* ~256 KiB total RAM
* ~20 KiB disk space
* Microsoft MS-DOS 2.0 (or compatibles)

## Usage

Type at the command prompt:

    asm.com infile.a

This will generate `infile.com`.

## Language

### Syntax

    label:    instruction operands        ; comment

See `ASM.A` file for real-world examples until this paragraph has been
written.

### Register Names

Register names in alphabetical order, grouped by first letter.

* **A** `ah`, `al`, `ax`
* **B** `bh`, `bl`, `bp`, `bx`
* **C** `ch`, `cl`, `cs`, `cx`
* **D** `dh`, `di`, `dl`, `ds`, `dx`
* **E** `es`
* **S** `si`, `sp`, `ss`

### Conventional Instructions

Conventional instructions in alphabetical order, grouped by first letter.

* **A** `aaa`, `aad`, `aam`, `aas`, `adc`, `add`, `and`
* **C** `call`, `cbw`, `clc`, `cld`, `cli`, `cmc`, `cmp`, `cmpsb`, `cmpsw`,
  `cs:`, `cwd`
* **D** `daa`, `das`, `dec`, `div`, `ds:`
* **E** `es:`
* **H** `hlt`
* **I** `idiv`, `imul`, `in`, `inc`, `int`, `into`, `iret`
* **J** `ja`, `jae`, `jb`, `jbe`, `jc`, `jcxz`, `je`, `jg`, `jge`, `jl`, `jle`,
  `jmp`, `jna`, `jnae`, `jnb`, `jnbe`, `jnc`, `jne`, `jng`, `jnge`, `jnl`,
  `jnle`, `jno`, `jnp`, `jns`, `jnz`, `jo`, `jp`, `jpe`, `jpo`, `js`, `jz`
* **L** `lahf`, `lds`, `lea`, `les`, `lock`, `lodsb`, `lodsw`, `loop`, `loope`,
  `loopne`, `loopnz`, `loopz`
* **M** `mov`, `movsb`, `movsw`, `mul`
* **N** `neg`, `nop`, `not`
* **O**: `or`, `out`
* **P**: `pop`, `popf`, `push`, `pushf`
* **R** `rcl`, `rcr`, `rep`, `repe`, `repne`, `repnz`, `repz`, `ret`, `retf`,
  `rol`, `ror`
* **S** `sahf`, `sar`, `sbb`, `scasb`, `scasw`, `shl`, `shr`, `ss:`, `stc`,
  `std`, `sti`, `stosb`, `stosw`, `sub`
* **T** `test`
* **W** `wait`
* **X** `xchg`, `xlat`, `xor`

Notes:

1. Prefix instructions `lock` and `repCC` have to be on its own line.
2. You can use `int 3` to emit the special `int3` instruction.

For a detailed description of each instruction, see, e.g.,
[Complete 8086 instruction set](http://amb.osdn.io/phpamb.php?fname=lib/8086set.amb),
[NASM 2.05 based x86 Instruction Reference](http://amb.osdn.io/phpamb.php?fname=lib/insref.amb), or [NASM 2.05 based x86 Instruction Reference](https://ulukai.org/ecm/insref.htm) (different layout).

### Special Instructions (Pseudo-ops)

* `byte` Use with `ptr` to specify a variable as a byte (8 bits).
* `db` Declare initialized byte (8 bits).
* `dw` Declare initialized word (2 bytes).
* `dword` Use with `ptr` to specify a variable as a doubleword (4 bytes).
* `equ` (or `=`) Define constant.
* `ptr` Use with `byte`, `dword`, `qword`, or `word` to specify the data type
  of a variable.
* `qword` Use with `ptr` to specify a variable as a quadword (8 bytes).
* `word` Use with `ptr` to specify a variable as a word (2 bytes).

`ASM.COM` always sets a program's origin address to 100h. The pseudo-op `org`,
known from other assemblers, e.g., [NASM](https://www.nasm.us/), is *not* supported.

## Example (Short)

File `hello.a`:

```
; print message to stdout
        mov ah,9
        mov dx,msg
        int 21h

; return to DOS
        ret

; message string
msg:
        db 'hello, world',13,10,'$'
```

Type to build:

    asm hello.a

Running generated `HELLO.COM` will then produce:

```
hello, world

```

## License

Copyright (c) 2001 Stephen Duffy <scfduffy@gmail.com>  
Copyright (c) 2020 Robert Riebisch <rr@bttr-software.de>

Usage of the works is permitted under the terms of the GNU GPL v2.  
See `LICENSE` file for details.
