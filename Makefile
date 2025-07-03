all: exec

run: exec
	./exec

exec: main.o
	ld -m elf_i386 -o exec main.o 

main.o: main.asm
	nasm -f elf32 -o main.o main.asm

clean:
	rm -f exec main.o

	
