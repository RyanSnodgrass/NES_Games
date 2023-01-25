.include "constants.inc"

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
  SEI
  CLD
  LDX #$00
	STX PPUCTRL
	STX PPUMASK
vblankwait:
	BIT PPUSTATUS
	BPL vblankwait
	JMP main
.endproc

LDX #$00 ; load immediate value $00 into X register
LDA #$ff ; load immediate value $ff into accumulator
clear_oam:
	STA $0200,X ; set sprite y-position offscreen
	INX ; skip tile number of sprite - now at 0201
	INX ; skip attributes of sprite  - now at 0202
	INX ; skip x-position of sprite  - now at 0203
	INX ; now at 0204
	; keep going until incrementor INX goes through all 256 values
	; and sets special flag on reset
	BNE clear_oam
