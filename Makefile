helloworld.nes: src/helloworld.o src/backgrounds.o src/reset.o src/controllers.o nes.cfg
	ld65 src/backgrounds.o src/reset.o src/controllers.o src/helloworld.o -C nes.cfg -o helloworld.nes

# target: src/helloworld.asm
# prerequisites: src/constants.inc src/scrolling.chr src/header.inc
# output: src/helloworld.o
src/helloworld.o: src/helloworld.asm src/constants.inc src/scrolling.chr src/header.inc
	ca65 src/helloworld.asm -o src/helloworld.o

# target: src/reset.asm
# prerequisites: src/constants.inc
# output: src/reset.o
src/reset.o: src/reset.asm src/constants.inc
	ca65 src/reset.asm -o src/reset.o

# target: src/backgrounds.asm
# prerequisites: src/constants.inc
# output: src/backgrounds.o
src/backgrounds.o: src/backgrounds.asm src/constants.inc
	ca65 src/backgrounds.asm -o src/backgrounds.o

src/controllers.o: src/controllers.asm src/constants.inc
	ca65 src/controllers.asm -o src/controllers.o

clean:
	rm -f src/helloworld.o src/reset.o src/backgrounds.o src/controllers.o
