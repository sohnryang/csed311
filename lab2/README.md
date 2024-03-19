# Lab 2: Single Cycle CPU

## ALU Operations

`alu.v`에서 구현된 ALU는 다음 연산을 지원한다.

| ID   | Name     | Description          |
| ---- | -------- | -------------------- |
| 0    | ALU_ADD  | `a + b`              |
| 1    | ALU_SUB  | `a - b`              |
| 2    | ALU_SLL  | `a << b`             |
| 3    | ALU_SLT  | `a < b`              |
| 4    | ALU_SLTU | `a < b`, unsigned    |
| 5    | ALU_XOR  | `a ^ b`              |
| 6    | ALU_SRL  | `a >> b`, logical    |
| 7    | ALU_SRA  | `a >> b`, arithmetic |
| 8    | ALU_OR   | `a | b`              |
| 9    | ALU_AND  | `a & b`              |
| 10   | ALU_EQ   | `a == b`             |
| 11   | ALU_NE   | `a != b`             |

ALU_SLT, ALU_SLTU, ALU_EQ, ALU_NE는 LSB에 1비트 연산 결과를 출력하고, 나머지 비트는 0으로 출력한다.
