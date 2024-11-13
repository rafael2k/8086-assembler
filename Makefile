##
# Project Title
#
# @file
# @version 0.1


AS=nasm
CC=ia16-elf-gcc

all:
	$(AS) -f elf -o easm.o easm.s
	$(CC) -melks-libc -mcmodel=small -nostdlib easm.o -o easm

clean:
	rm -f *.o easm
# end
