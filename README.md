# Learn Assembly by making NES games

I'm trying to learn assembly which is a notriosly difficult
language to use and learn. To give myself motivation, I'm
making NES games following https://famicom.party/book/

Extensions to use for VS Code:
- Beeb VSC

## To recompile:
```
ca65 src/helloworld.asm -o src/helloworld.o
ca65 src/reset.asm -o src/reset.o
ca65 src/backgrounds.asm -o src/backgrounds.o
ca65 src/controllers.asm -o src/controllers.o
ld65 src/backgrounds.o src/reset.o src/controllers.o src/helloworld.o -C nes.cfg -o helloworld.nes
```

or

```
make
```

## To Run:
```
java -jar ~/Downloads/Nintaco_bin_2020-05-01/Nintaco.jar "helloworld.nes"
```
