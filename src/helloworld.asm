.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  ; I believe this defines where our sprite buffer starts. The "high" or left
  ; byte ($02) defines a the macro level address. A "page" or contiguous block
  ; of 256 bytes of memory. The "high" byte defines which page and the low byte
  ; byte ($00) defines exactly where we start. In this case we're telling it
  ; to start at address $0200. Because we can only define 256 attributes (64
  ; sprites), this neatly fits into a single byte for the micro level address.
  ; Writing to OAMDMA ($4014) will initiate transfer sprite buffer page.
  LDA #$00         ; load immediate value $00 into accumulator
  STA OAMADDR      ; store value from accumulator ($00) into address at OAMADDR ($2003)
  LDA #$02         ; load immediate value $02 into accumulator
  STA OAMDMA       ; store value from accumulator ($02) into address at OAMDMA ($4014)
  LDA #$00         ; load immediate value $00 into accumulator

  ; update tiles *after* DMA transfer
  JSR update_player
  JSR draw_player

  LDA scroll
  CMP #$00 ; did we scroll to the end of a nametable?
  BNE set_scroll_positions
  ; if yes,
  ; update base nametable
  LDA ppuctrl_settings
  EOR #%00000010 ; flip bit #1 to its opposite
  STA ppuctrl_settings
  STA PPUCTRL
  LDA #240
  STA scroll

set_scroll_positions:
  LDA #$00 ; X scroll first
  STA PPUSCROLL
  DEC scroll
  LDA scroll ; then Y scroll
  STA PPUSCROLL
  RTI
.endproc

.import reset_handler
.import draw_starfield
.import draw_objects

.export main
.proc main
  LDA #239   ; Y is only 240 lines tall!
  STA scroll

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

  ; write a nametable
  LDX #$20                   ; Load first nametable address high byte ($2000)
  JSR draw_starfield

  LDX #$28                   ; Load second nametable for vertical scrolling ($2800)
  JSR draw_starfield
  JSR draw_objects

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  ; set PPUCTRL after drawing all of our nametables. We'll need to store the
  ; value that we send to PPUCTRL so that we can modify and re-use it later:
  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA ppuctrl_settings
  STA PPUCTRL

  LDA #%00011110  ; turn on screen
  STA PPUMASK
forever:
  JMP forever
.endproc

.proc draw_player
  ; save registers
  PHP              ; push the processor status register ("P") onto the stack
  PHA              ; push the Accumulator ("A") value onto the stack
  ; There are no opcodes to push values from the X or Y registers onto the stack
  ; You have to transfer them to the Accumulator first, then to the stack.
  TXA              ; Transfer value of X registor to Accumulator
  PHA              ; push the Accumulator (formerly "X") value onto the stack
  TYA              ; Transfer value of Y register to Accumulator
  PHA              ; push the Accumulator (formerly "Y") value onto the stack

  ; write player ship tile numbers
  LDA #$05         ; load to Accumulator top right ship tile ($05)
  STA $0201        ; store to sprite buffer
  LDA #$06         ; ...
  STA $0205        ; ...
  LDA #$07
  STA $0209
  LDA #$08
  STA $020d

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; store tile locations
  ; top left tile
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x+8)
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08                   ; Add 8 to player_x position value
  STA $0207

  ; bottom left tile (y+8)
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x+8 y+8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

; left ($00)
; right ($01)
.proc update_player
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player_x
  ; compare player_x value in accumulator to absolute $e0
  ; CMP subtracts (with the carry set) absolute value $e0 from Accumulator value
  ; in other words Accumulator value - $e0
  ; The process register will reveal the final result of that whether Negative,
  ; Zero, or Carry needed.
  ; Zero is easy to understand: 3 - 3 = 0. Two numbers that equal each other
  ; subtract out to zero.
  ; Negative is again pretty easy: 3 - 4 = -1. If Accumulator is less than
  ; $e0 than a negative flag is set (1).
  ; Carry is a bit less understandable. Just like we do math by hand on paper,
  ; when numbers are added that are larger than 9, we need to "carry" the 1 to
  ; the other column. When CMP is executed it sets the carry flag for subtraction.
  ; So if the subtraction results in the
  ; Really, CMP can be used for a variety of conditional checks. Whether greater
  ; than, less than, or equal.
  CMP #$e0
  ; BCC or Branch if Carry Cleared means if a carry was needed in the last operation.
  ; Atleast, in the context of CMP (subtraction). Because CMP starts with a 1 in the
  ; carry bit (carry set) if the compared value is greater than the accumulator
  ; than the carry was needed and will clear it out (0).
  ; Simply for our purposes, was the Accumulator less than the right most edge $e0?
  ; It is subtracting the right most edge's value from the player_x position.
  BCC not_at_right_edge
  ; if BCC is not taken we're further than $e0
  LDA #$00
  STA player_dir             ; start moving left
  JMP direction_set

not_at_right_edge:
  LDA player_x
  CMP #$10                  ;  compare player_x value in accumulator to absolute $10
  ; BCS or Branch Carry Set. Was the Accumulator GREATER than left edge ($10)?
  BCS direction_set
  ; if BCS not taken, we are less than $10
  LDA #$01
  STA player_dir            ; Move player right

direction_set:
  ; now actually update player position
  LDA player_dir
  CMP #$01
  BEQ move_right
  ; if player_dir minus $01 was not zero
  ; that means player_dir was $00 and
  ; we need to move left
  DEC player_x
  DEC player_x
  JMP exit_subroutine

move_right:
  INC player_x

exit_subroutine:
  ; all done, clean up and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"            ; Read only data
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

player_ship:
  ;      Y  tile  attr  X
  .byte $70, $05, $00, $80
  .byte $70, $06, $00, $88
  .byte $78, $07, $00, $80
  .byte $78, $08, $00, $88

.segment "CHR"
.incbin "scrolling.chr"

; tell the assembler to reserve Zero Page memory
.segment "ZEROPAGE"
; reserve a single byte of memory with the .res directive to player_x label
; A label tells the assembler to find the PRG ROM address associated with that
; label and replace the label name with the address. Remember each line of ASM
; code is stored in PRG ROM bank with its own address. Labels refer to those
; addresses
player_x: .res 1
player_y: .res 1
player_dir: .res 1
scroll: .res 1
ppuctrl_settings: .res 1
.exportzp player_x, player_y
