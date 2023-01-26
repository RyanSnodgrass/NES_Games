# Sprites

It takes 4 bytes of data to describe a sprite. The NES only has 256 bytes available for sprites hence 4 * 64 = 256.

These 4 bytes do the following:
1. Y position of the TOP LEFT corner of the sprite (0-255)
2. Tile number from the sprite pattern table (0-255)
    - This means each sprite takes up one of the 256 tiles. no duh.
3. Special attribute flags (horizontal/vertial flip and PALLETE)
4. X position of the TOP LEFT corner of the sprite (0-255)

ok cool. where do i store this data for the PPU to send to the graphics processor? hypothesis: there is a special flag i set `OAMADDR` to define where the sprite data starts. Then from there it's 256 bytes later.

Another question: can I only define 4 color palletes per game? or is it per sprite? Hypothesis: 4 palletes per game

## Sprite Attribute flag

The 3rd byte defines special attributes of the sprite in question. Remember a byte is a series of 8 bits of 0s and 1s. The 6502 uses those bits to tell it what to do with the sprite.
Remember, the bits that make up a byte are numbered 0-7, with bit 0 all the way on the right, and bit 7 all the way on the left.

| Bit # | Purpose                                    |
| ----- | ------------------------------------------ |
| 0     | Pallete for sprite                         |
| 1     | Pallete for sprite                         |
| 2     | Not Used                                   |
| 3     | Not Used                                   |
| 4     | Not Used                                   |
| 5     | Sprite priority (behind background if "1") |
| 6     | Flip sprite Horizontally if "1"            |
| 7     | Flip sprite Vertically if "1"              |

Question: what's up with the 2 bits for palletes? I suppose 2 bits provides 4 possible combinations for pallete identification. `00`, `01`, `10`, `11`. Ok cool. Where do I define where each pallete gets defined? My guess is NES Lightbox does that for me in the .chr file.

## Object Attribute Memory (OAM)
To make the NES fast it assigns a contiguous block of 256 bytes where we define
each individual sprite quad data. This block is otherwise known as a "page" or
"sprite buffer." We can start this buffer anywhere but convention has it start
at `$0200` and end at `$02ff`.

## How to load sprites
Each sprite has 4 bytes:
Y coordinate
Tile Number
Attributes
X coordinate

Starting at address `$0200` store the Y coordinate of the sprite. We previously defined the sprite buffer to start at `$0200`
in the NMI handler using `OAMADDR` and `OAMDMA`.
```
LDA #$70
STA $0200 ; Y-coord of first sprite
LDA #$05
STA $0201 ; tile number of first sprite
LDA #$00
STA $0202 ; attributes of first sprite
LDA #$80
STA $0203 ; X-coord of first sprite
```

## Index Mode
Combines a fixed absolute address with the values of an index register
All this does is move the memory address (operand) to the added value of
the X (or Y) register.

* Memory Addresses *
```
STX #$ff
LDA $8000,X
```
This loads into the Accumulator the value stored at address $80ff

* .byte Read Only Data *
You can also do this with data in the RODATA segment like palletes and sprites
```
  palettes:
    .byte $29, $19, $09, $0f
  load_palettes:
	LDA palettes,X
	STA PPUDATA
	INX
	CPX #$04
	BNE load_palettes
```

Full working example:
```
  LDX #$00         ; Load into X immediate value of $00
                   ; In other words zero out the X register
load_ship_sprites:
  ; Index through the .bytes of the pallete with the value of X register. Load
  ; that .byte value into the Accumulator
  LDA player_ship,X
  ; Change the operand (in this case mem address $0200) to value of the
  ; operand + the X register ($0200 + $ff = $02ff). Store the value of the
  ; Accumulator into that new mem address ($02ff).
  STA $0200,X
  INX
  CPX #$10
  BNE load_ship_sprites
```
