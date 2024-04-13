# Lab3: Multi Cycle CPU

## State Transition

| State | Description                                                  | Reads                                          | Writes                                 |
| ----- | ------------------------------------------------------------ | ---------------------------------------------- | -------------------------------------- |
| IF    | Fetch instruction in PC address from instruction memory.     | inst mem, PC                                   | instruction register                   |
| ID    | Decode instruction and select operand sources for ALU.       | instruction register                           | operand register                       |
| EX    | Run ALU and save the result to ALU register.                 | ALU output                                     | ALU register                           |
| MEM   | Access memory for load/store instructions, and set operands for PC value generation. | data mem, ALU register                         | operand register, memory data register |
| WB    | Write calculation results to register file and PC register.  | ALU register, ALU output, memory data register | register file, PC                      |

### R-type

| State | Action                                                       |
| ----- | ------------------------------------------------------------ |
| IF    | instruction fetch, set PC to PC+4                            |
| ID    | instruction decode (op1 = rs1, op2 = rs2), set ALU reg to PC + imm |
| EX    | set ALU reg to ALU result (calculate)                        |
| MEM   | pass                                                         |
| WB    | save ALU reg to register file                                |

### I-type

#### Arithmetic

| State | Action                                                       |
| ----- | ------------------------------------------------------------ |
| IF    | instruction fetch, set PC to PC+4                            |
| ID    | instruction decode (op1 = rs1, op2 = imm), set ALU reg to PC + imm |
| EX    | set ALU reg to ALU result (calculate)                        |
| MEM   | pass                                                         |
| WB    | save ALU reg to register file                                |

#### Load

| State | Action                                                       |
| ----- | ------------------------------------------------------------ |
| IF    | instruction fetch, set PC to PC+4                            |
| ID    | instruction decode (op1 = rs1, op2 = imm), set ALU reg to PC + imm |
| EX    | set ALU reg to ALU result (memory address)                   |
| MEM   | save memory data to memory data reg                          |
| WB    | save memory data reg to register file                        |

### S-type

| State | Action                                                       |
| ----- | ------------------------------------------------------------ |
| IF    | instruction fetch, set PC to PC+4                            |
| ID    | instruction decode (op1 = rs1, op2 = imm), set ALU reg to PC + imm |
| EX    | set ALU reg to ALU result (memory address)                   |
| MEM   | save rs2 to address in ALU reg                               |
| WB    | pass                                                         |

### B-type

| State | Action                                                       |
| ----- | ------------------------------------------------------------ |
| IF    | instruction fetch, set PC to PC+4                            |
| ID    | instruction decode (op1 = rs1, op2 = imm), set ALU reg to PC + imm |
| EX    | check branch condition, set PC according to condition        |
| MEM   | pass                                                         |
| WB    | pass                                                         |

### J-type

#### JAL

| State | Action                                                       |
| ----- | ------------------------------------------------------------ |
| IF    | instruction fetch, set PC to PC+4                            |
| ID    | instruction decode (op1 = rs1, op2 = imm), set ALU reg to PC + imm |
| EX    | set PC to ALU reg                                            |
| MEM   | pass                                                         |
| WB    | save PC+4 to register file                                   |

#### JALR

| State | Action                                                       |
| ----- | ------------------------------------------------------------ |
| IF    | instruction fetch, set PC to PC+4                            |
| ID    | instruction decode (op1 = rs1, op2 = imm), set ALU reg to PC + imm |
| EX    | save ALU output to PC                                        |
| MEM   | pass                                                         |
| WB    | save PC+4 to register file                                   |
