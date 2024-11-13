##
# Project Title
#
# @file
# @version 0.1


AS=nasm
CC=ia16-elf-gcc

all: ASM.A
	$(AS) -f elf -o ASM.o ASM.A
	$(CC) -melks-libc -mcmodel=small -nostdlib ASM.o -o ASM


# end
