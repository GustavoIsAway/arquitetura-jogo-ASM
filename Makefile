all: exec

run: exec
	./exec

exec: main.o
	ld -g -m elf_i386 main.o -o exec

main.o: main.asm
	nasm -f elf32 -g -F dwarf main.asm -o main.o

clean:
	rm -f exec main.o

	