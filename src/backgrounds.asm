.include "constants.inc"

.segment "CODE"

.export draw_starfield
.proc draw_starfield
  ; X register stores high byte of nametable. Makes it easy to swap out the nametable.

  ; big stars first at position $206b
  ; There are 4 nametables. addresses at $2000, $2400, $2800, $2c00
  ; Weirdly, instead of writing directly to those addresses, we send
  ; how many bytes away from the starting address the tile is. This might
  ; be how we avoid colliding with some of our "keyword" addresses in the
  ; low $2000s

  ; Interesting note, the first nametable addressses go from $2000 to $23bf.
  ; Then the first attribute table starts on the very next byte at $23c0 and goes to
  ; $23ff. Which runs into the very next byte of the next nametable at $2400 and
  ; the pattern repeats.

  ; write nametables
  ; big stars first
  LDA PPUSTATUS
  TXA              ; X register is #$20. This defines the nametable $2000
  STA PPUADDR      ; Store from Accumulator to PPUADDR
  LDA #$6b         ; position BG sprite at $6b (low byte) or specific position of nametable
  STA PPUADDR
  LDY #$2f         ; Use BG sprite of tile $2f
  STY PPUDATA

  LDA PPUSTATUS
  TXA
  ADC #$01
  STA PPUADDR
  LDA #$57
  STA PPUADDR
  STY PPUDATA      ; Use BG sprite kept in Y register ($2f)

	LDA PPUSTATUS
	TXA
	ADC #$02
	STA PPUADDR
	LDA #$23
	STA PPUADDR
	STY PPUDATA

	LDA PPUSTATUS
	TXA
	ADC #$03
	STA PPUADDR
	LDA #$52
	STA PPUADDR
	STY PPUDATA

	; next, small star 1
	LDA PPUSTATUS
	TXA
	STA PPUADDR
	LDA #$74
	STA PPUADDR
	LDY #$2d
	STY PPUDATA

	LDA PPUSTATUS
	TXA
	ADC #$01
	STA PPUADDR
	LDA #$43
	STA PPUADDR
	STY PPUDATA

	LDA PPUSTATUS
	TXA
	ADC #$01
	STA PPUADDR
	LDA #$5d
	STA PPUADDR
	STY PPUDATA

	LDA PPUSTATUS
	TXA
	ADC #$01
	STA PPUADDR
	LDA #$73
	STA PPUADDR
	STY PPUDATA

	LDA PPUSTATUS
	TXA
	ADC #$02
	STA PPUADDR
	LDA #$2f
	STA PPUADDR
	STY PPUDATA

	LDA PPUSTATUS
	TXA
	ADC #$02
	STA PPUADDR
	LDA #$f7
	STA PPUADDR
	STY PPUDATA

	; finally, small star 2
	LDA PPUSTATUS
	TXA
	STA PPUADDR
	LDA #$f1
	STA PPUADDR
	LDY #$2e
	STY PPUDATA

	LDA PPUSTATUS
	TXA
	ADC #$01
	STA PPUADDR
	LDA #$a8
	STA PPUADDR
	STY PPUDATA

	LDA PPUSTATUS
	TXA
	ADC #$02
	STA PPUADDR
	LDA #$7a
	STA PPUADDR
	STY PPUDATA

	LDA PPUSTATUS
	TXA
	ADC #$03
	STA PPUADDR
	LDA #$44
	STA PPUADDR
	STY PPUDATA

	LDA PPUSTATUS
	TXA
	ADC #$03
	STA PPUADDR
	LDA #$7c
	STA PPUADDR
	STY PPUDATA

  ; little dude
  LDA PPUSTATUS
  TXA              ; use X register to load the high byte of nametable ($20)
  STA PPUADDR
  LDA #$43         ; place little dude at bg position $43 ($2043)
  STA PPUADDR
  LDY #$30         ; load to Y little dude BG sprite .chr at tile $30
  STY PPUDATA

  LDA PPUSTATUS
  TXA
  ADC #$03
  STA PPUADDR
  LDA #$27
  STA PPUADDR
  STY PPUDATA

	; finally, attribute table
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

  ; little dude attribute
  LDA PPUSTATUS
  LDA #$23          ; attribute table address high byte (#$23)
  STA PPUADDR
  LDA #$f1          ; attribute table address low byte (#$23f1)
  STA PPUADDR
  LDA #%00001000
  STA PPUDATA

	RTS
.endproc

.export draw_objects
.proc draw_objects
  ; Draw objects on top of the starfield,
  ; and update attribute tables

  ; new additions: galaxy and planet
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$90
	STA PPUADDR
	LDX #$30
	STX PPUDATA
	LDX #$31
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$b0
	STA PPUADDR
	LDX #$32
	STX PPUDATA
	LDX #$33
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$42
	STA PPUADDR
	LDX #$38
	STX PPUDATA
	LDX #$39
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$62
	STA PPUADDR
	LDX #$3a
	STX PPUDATA
	LDX #$3b
	STX PPUDATA

	; nametable 2 additions: big galaxy, space station
	LDA PPUSTATUS
	LDA #$28
	STA PPUADDR
	LDA #$c9
	STA PPUADDR
	LDA #$41
	STA PPUDATA
	LDA #$42
	STA PPUDATA
	LDA #$43
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$28
	STA PPUADDR
	LDA #$e8
	STA PPUADDR
	LDA #$50
	STA PPUDATA
	LDA #$51
	STA PPUDATA
	LDA #$52
	STA PPUDATA
	LDA #$53
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$29
	STA PPUADDR
	LDA #$08
	STA PPUADDR
	LDA #$60
	STA PPUDATA
	LDA #$61
	STA PPUDATA
	LDA #$62
	STA PPUDATA
	LDA #$63
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$29
	STA PPUADDR
	LDA #$28
	STA PPUADDR
	LDA #$70
	STA PPUDATA
	LDA #$71
	STA PPUDATA
	LDA #$72
	STA PPUDATA

	; space station
	LDA PPUSTATUS
	LDA #$29
	STA PPUADDR
	LDA #$f2
	STA PPUADDR
	LDA #$44
	STA PPUDATA
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$29
	STA PPUADDR
	LDA #$f6
	STA PPUADDR
	LDA #$44
	STA PPUDATA
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$2a
	STA PPUADDR
	LDA #$12
	STA PPUADDR
	LDA #$54
	STA PPUDATA
	STA PPUDATA
	LDA #$45
	STA PPUDATA
	LDA #$46
	STA PPUDATA
	LDA #$54
	STA PPUDATA
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$2a
	STA PPUADDR
	LDA #$32
	STA PPUADDR
	LDA #$44
	STA PPUDATA
	STA PPUDATA
	LDA #$55
	STA PPUDATA
	LDA #$56
	STA PPUDATA
	LDA #$44
	STA PPUDATA
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$2a
	STA PPUADDR
	LDA #$52
	STA PPUADDR
	LDA #$44
	STA PPUDATA
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$2a
	STA PPUADDR
	LDA #$56
	STA PPUADDR
	LDA #$44
	STA PPUDATA
	STA PPUDATA

	; finally, attribute tables
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$dc
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$2b
	STA PPUADDR
	LDA #$ca
	STA PPUADDR
	LDA #%10100000
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$2b
	STA PPUADDR
	LDA #$d2
	STA PPUADDR
	LDA #%00001010
	STA PPUDATA

	RTS
.endproc
