helloworld.nes: src/helloworld.o src/reset.o nes.cfg
	ld65 src/reset.o src/helloworld.o -C nes.cfg -o helloworld.nes

src/helloworld.o: src/helloworld.asm src/constants.inc src/graphics.chr src/header.inc
	ca65 src/helloworld.asm -o src/helloworld.o

src/reset.o: src/reset.asm src/constants.inc
	ca65 src/reset.asm -o src/reset.o

clean:
	rm -f src/helloworld.o src/reset.o
