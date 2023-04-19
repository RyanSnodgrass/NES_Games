# Learn Assembly by making NES games

I'm trying to learn assembly which is a notriosly difficult
language to use and learn. To give myself motivation, I'm
making NES games following https://famicom.party/book/

Extensions to use for VS Code:
- Beeb VSC

## To recompile:
```
ca65 src/helloworld.asm
ca65 src/reset.asm
ld65 src/reset.o src/helloworld.o -C nes.cfg -o helloworld.nes
```

## To Run:
```
java -jar ~/Downloads/Nintaco_bin_2020-05-01/Nintaco.jar "helloworld.nes"
```


## Notes:
