# Lab3: Multi Cycle CPU

## Microcode Design

| Microcode | Description                                                  | Input                               | Output               |
| --------- | ------------------------------------------------------------ | ----------------------------------- | -------------------- |
| `fetch.i` | Fetch instruction to instruction register                    | PC address                          | Instruction register |
| `fetch.o` | Fetch register and IMM values to operand registers           | Instruction register, IMMgen output | operand registers    |
| `alu`     | Run calculation on ALU and save result to ALU register       | Operand registers, ALU operation    | ALU register         |
| `load.m`  | Load data memory to memory data register from address in ALU register | ALU register                        | Memory data register |
| `store.m` | Store memory data register to data memory to address in ALU register | ALU register, memory data register  |                      |
| `write`   | Write contents of ALU register to register file              | ALU register                        |                      |

