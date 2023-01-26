# Subroutines and the Stack

## Program Counter
The program counter keeps track of the next byte to be processed in the execution of the code.

## Stack
The stack is kinda like a secondary set of memory for storing (system info?).

The stack is 256 bytes in size and located from `$0300` to `$03ff`. The 6502 procesor uses a special pointer
often abbreviated "S" to keep track of where the stack is. When the system is first initialized the stack pointer
is set to `$ff`. The result is `$0300` plues whatever is in the stack pointer, in this case `$0300` + `$ff` = `$03ff`.

Everytime something is stored to the stack the pointer is decremented. And conversely everytime something is removed
the stack pointer is incremented.

Remember, only the top most element is available at any time.

## Subroutines
```
  LDA #$80
  JSR do_something_else
  STA $8000

.proc do_something_else
  LDA #$90
  RTS
.endproc
```
When the 6502 sees a `JSR` or "Jump to SubRoutine" opcode it stores whatever value is in the program counter onto the stack.
Then it takes the operand (do_something_else, remember labels are human friendly memory addresses as each line of
code is stored in the bank of PRG ROM) and puts that in the program counter. Now the program counter has the
address of do_something_else for next execution so it jumps to that subroutine. Runs execution of the next lines until
it sees `RTS`. `RTS` or "ReTurn from Subroutine" takes the "top" value of the stack (whatever that is) and pushes
it to the program counter for next execution. Hopefully that stack value is still the address of the JSR opcode. Taking
the top value off the stack is often referred to as "popping".

All subroutines must end with `RTS`

Registers are global and are readable/editable at any time. Subroutines do not keep track of register values.
