.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  ; I believe this defines where our sprite buffer starts. The "high" or left
  ; byte ($02) defines the macro level address. While the "low" byte or right
  ; byte ($00) defines exactly where we start. In this case we're telling it
  ; to start at address $0200. Because we can only define 256 attributes (64
  ; sprites), this neatly fits into a single byte for the micro level address.
  ; Writing to OAMDMA ($4014) will initiate transfer sprite buffer page.
  LDA #$00         ; load immediate value $00 into accumulator
  STA OAMADDR      ; store value from accumulator ($00) into address at OAMADDR ($2003)
  LDA #$02         ; load immediate value $02 into accumulator
  STA OAMDMA       ; store value from accumulator ($02) into address at OAMDMA ($4014)

  ; set scrolling of backround tiles to $00 at startup
  LDA #$00         ; Load immediate value $00 into accumulator
  STA $2005        ; store value from accumulator ($00) into address $2005 (high byte)
  STA $2005        ; store value from accumulator ($00) into address $2005 (low byte)
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write a palette
  ; PPUSTATUS is a read-only MMIO address. It is set by the PPU and gives info about it.
  ; It also resets the "address latch" for PPUADDR. It takes 2 writes to PPUADDR to fully
  ; specify a memory address.
  LDX PPUSTATUS    ; load into register X value of PPUSTATUS ($2002)
  LDX #$3f         ; load into register X immediate value of $3f
  STX PPUADDR      ; store into PPUADDR ($2006) value from register X ($3f)
  LDX #$00         ; load into register X immediate value of $00
  STX PPUADDR      ; store from register X ($00) into memory location PPUADDR ($2006)
  ; This has now loaded 2 bytes of data to PPUADDR ($2006):
  ; First the "high" or left byte ($3f)
  ; Followed by the "low" or right byte ($00)
  ; In other words, it sets the address for any following writes to PPU memory to $3f00

load_palettes:
  ; Now that we have the PPUADDR set to $3f00, we start writing our block of sprite buffer
  ; Since we don't have direct access to the PPU, we instead write to PPUDATA ($2007),
  ; which then copies to our selected address from before - $3f00. I dont think i should manually
  ; set data to $3f00 because then it won't be picked up by the PPU.
  ; Any subsequent writes to PPUDATA will increment the address by one.
  ; For example:
  ; LDA #$29      ; load into accumulator immediate value of $29
  ; STA PPUDATA   ; store into PPUDATA ($2007) value from accumulator ($29)
  ; This would then write $29 to address $3f01 even through we didn't do anything to PPUADDR

	; LDA #$05       ; load into accumulator immediate value of $29 (dark red)
  ; STA PPUDATA    ; store into PPUDATA value from accumulator ($29). PPUDATA sets this at $3f01
  ; LDA #$15       ; load into accumulator immediate value of $19 (magenta)
  ; STA PPUDATA    ; store into PPUDATA value from accumulator ($19). PPUDATA sets this at $3f02
  ; LDA #$05       ; load into accumulator immediate value of $09 (dark green)
  ; STA PPUDATA    ; store into PPUDATA value from accumulator ($09). PPUDATA sets this at $3f03
  ; LDA #$0f       ; load into accumulator immediate value of $0f (black)
  ; STA PPUDATA    ; store into PPUDATA value from accumulator ($0f). PPUDATA sets this at $3f04
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes

  ; write sprite data
  LDX #$00         ; Load into X immediate value of $00
                   ; In other words zero out the X register
  ; LDA #$70
  ; STA $0200 ; Y-coord of first sprite
  ; LDA #$05
  ; STA $0201 ; tile number of first sprite
  ; LDA #$00
  ; STA $0202 ; attributes of first sprite
  ; LDA #$80
  ; STA $0203 ; X-coord of first sprite
load_ship_sprites:
  LDA ship_NW,X
  STA $0200,X
  LDA ship_NE,X
  STA $0204,X
  LDA ship_SW,X
  STA $0208,X
  LDA ship_SE,X
  STA $020c,X
  INX
  CPX #$04
  BNE load_ship_sprites

  ; write a nametable
  ; big stars first at position $206b
  ; There are 4 nametables. addresses at $2000, $2400, $2800, $2c00
  ; Weirdly, instead of writing directly to those addresses, we send
  ; how many bytes away from the starting address the tile is. This might
  ; be how we avoid colliding with some of our "keyword" addresses in the
  ; low $2000s
  LDA PPUSTATUS
  LDA #$20       ; position BG sprite at $20 (high byte)
  STA PPUADDR
  LDA #$6b       ; position BG sprite at $6b (low byte)
  STA PPUADDR
  LDX #$2f       ; use BG sprite at position 2f
  STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$57
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$23
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$52
	STA PPUADDR
	STX PPUDATA

	; next, small star 1
	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$74
	STA PPUADDR
	LDX #$2d
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$43
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$5d
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$73
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2f
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$f7
	STA PPUADDR
	STX PPUDATA

	; finally, small star 2
	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$f1
	STA PPUADDR
	LDX #$2e
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$a8
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$7a
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$44
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$7c
	STA PPUADDR
	STX PPUDATA

  ; little dude
  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$18
  STA PPUADDR
  LDX #$30
  STX PPUDATA

  ; finally an attribute
  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$c2
  STA PPUADDR
  LDA #%01000000
  STA PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$e0
  STA PPUADDR
  LDA #%00001100
  STA PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$d6
  STA PPUADDR
  LDA #%00000001
  STA PPUDATA

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK
forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
  ; backgrounds
  .byte $0f, $12, $23, $27
  .byte $0f, $2b, $3c, $39
  .byte $0f, $0c, $07, $13
  .byte $0f, $19, $09, $29

  ; sprites
  .byte $0f, $2d, $10, $15
  .byte $0f, $19, $09, $29
  .byte $0f, $19, $09, $29
  .byte $0f, $19, $09, $29

;     Y    tile attr X
ship_NW:
.byte $70, $05, $00, $80
ship_NE:
.byte $70, $06, $00, $88
ship_SW:
.byte $78, $07, $00, $80
ship_SE:
.byte $78, $08, $00, $88

.segment "CHR"
.incbin "graphics.chr"
