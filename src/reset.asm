.include "constants.inc"

; The .importzp directive must go withing the ZEROPAGE segment,
; even if you're not doing anything else with zeropage in this
; file. I think you have to match segments when .importzp
.segment "ZEROPAGE"
.importzp player_x, player_y

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

	; initialize zero page
	; we define the player's starting X and Y position relative to the sprite
	LDA #$80
	STA player_x
	LDA #$a0
	STA player_y

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
