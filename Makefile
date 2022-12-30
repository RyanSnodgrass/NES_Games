helloworld.nes: src/helloworld.o src/reset.o
	ld65 src/reset.o src/helloworld.o -C nes.cfg -o helloworld.nes

src/helloworld.o: src/helloworld.asm
	ca65 src/helloworld.asm -o src/helloworld.o

src/reset.o: src/reset.asm
	ca65 src/reset.asm -o src/reset.o

clean:
	rm -f src/helloworld.o src/reset.o
