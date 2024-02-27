#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Valu.h"
#include "Valu___024root.h"


#define MAX_SIM_TIME 40
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;



// `define FUNC_ADD    4'b0000
// `define FUNC_SUB    4'b0001
// `define FUNC_ID     4'b0010
// `define FUNC_NOT    4'b0011
// `define FUNC_AND    4'b0100
// `define FUNC_OR     4'b0101
// `define FUNC_NAND   4'b0110
// `define FUNC_NOR    4'b0111
// `define FUNC_XOR    4'b1000
// `define FUNC_XNOR   4'b1001
// `define FUNC_LLS    4'b1010
// `define FUNC_LRS    4'b1011
// `define FUNC_ALS    4'b1100
// `define FUNC_ARS    4'b1101
// `define FUNC_TCP    4'b1110
// `define FUNC_ZERO   4'b1111


int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Valu *dut = new Valu;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    int sum = 0;
    
    dut->A = 0;
    dut->B = 0;
    dut->FuncCode = 0;
    dut->eval();

    while (sim_time < MAX_SIM_TIME) {
        if(sim_time >= 0 && sim_time < 2)
        {
            dut -> A = 1;
            dut -> B = 1;
            dut -> FuncCode = 0;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 1 && (dut -> C == dut -> A + dut -> B))
            {
                printf("Test 1 Passed\n");
                sum++;
            }
        }

        if(sim_time >= 2 && sim_time < 4)
        {
            dut -> A = 1;
            dut -> B = 1;
            dut -> FuncCode = 0;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 3 && (dut -> C == dut -> A + dut -> B))
            {
                printf("Test 2 Passed\n");
                sum++;
            }
        }

        if(sim_time >= 4 && sim_time < 6)
        {
            dut -> A = 1;
            dut -> B = 1;
            dut -> FuncCode = 1;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 5 && (dut -> C == dut -> A - dut -> B))
            {
                printf("Test 3 Passed\n");
                sum++;
            }
        }

        if(sim_time >= 6 && sim_time < 8)
        {
            dut -> A = 1;
            dut -> B = 1;
            dut -> FuncCode = 2;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 7 && (dut -> C == dut -> A))
            {
                printf("Test 4 Passed\n");
                sum++;
            }
        }

        if(sim_time >= 8 && sim_time < 10)
        {
            dut -> A = 1;
            dut -> B = 1;
            dut -> FuncCode = 3;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 9 && (dut -> C == (uint16_t)~(dut -> A)))
            {
                printf("Test 5 Passed\n");
                sum++;
            }
        }

        if(sim_time >= 10 && sim_time < 12)
        {
            dut -> A = 11;
            dut -> B = 5;
            dut -> FuncCode = 4;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 11 && (dut -> C == (u_int16_t)(dut -> A & dut -> B)))
            {
                printf("Test 6 Passed\n");
                sum++;
            }
        }
        
        if(sim_time >= 12 && sim_time < 14)
        {
            dut -> A = 11;  // 1011
            dut -> B = 5;   // 0101 
            dut -> FuncCode = 5;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 13 && (dut -> C == (u_int16_t)(dut -> A | dut -> B)))
            {
                printf("Test 7 Passed\n");
                sum++;
            }
        }

        if(sim_time >= 14 && sim_time < 16)
        {
            dut -> A = 11;  // 1011
            dut -> B = 5;   // 0101 
            dut -> FuncCode = 6;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 15 && (dut -> C == (u_int16_t)~(dut -> A & dut -> B)))
            {
                printf("Test 8 Passed\n");
                sum++;
            }
        }

        if(sim_time >= 16 && sim_time < 18)
        {
            dut -> A = 11;  // 1011
            dut -> B = 5;   // 0101 
            dut -> FuncCode = 7;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 17 && (dut -> C == (u_int16_t)~(dut -> A | dut -> B)))
            {
                printf("Test 9 Passed\n");
                sum++;
            }
        }
   

        if(sim_time >= 18 && sim_time < 20)
        {
            dut -> A = 11;  // 1011
            dut -> B = 5;   // 0101 
            dut -> FuncCode = 8;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 19 && (dut -> C == (u_int16_t)(dut -> A ^ dut -> B)))
            {
                printf("Test 10 Passed\n");
                sum++;
            }
        }

        if(sim_time >= 20 && sim_time < 22)
        {
            dut -> A = 11;  // 1011
            dut -> B = 5;   // 0101 
            dut -> FuncCode = 9;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 21 && (dut -> C == (u_int16_t)~(dut -> A ^ dut -> B)))
            {
                printf("Test xnor 11 Passed\n");
                sum++;
            }
        }

        if(sim_time >= 22 && sim_time < 24)
        {
            dut -> A = 11;  // 1011
            dut -> B = 5;   // 0101 
            dut -> FuncCode = 10;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 23 && (dut -> C == (u_int16_t)(dut -> A << 1)))
            {
                printf("Test 12 Passed\n");
                sum++;
            }
        }

        if(sim_time >= 24 && sim_time < 26)
        {
            dut -> A = 11;  // 1011
            dut -> B = 5;   // 0101 
            dut -> FuncCode = 11;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 25 && (dut -> C == (u_int16_t)(dut -> A >> 1)))
            {
                printf("Test 13 Passed\n");
                sum++;
            }
        }

        if(sim_time >= 26 && sim_time < 28)
        {
            dut -> A = 11;  // 1011
            dut -> B = 5;   // 0101 
            dut -> FuncCode = 12;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 27 && (dut -> C == (u_int16_t)(dut -> A << 1)))
            {
                printf("Test 14 Passed\n");
                sum++;
            }
        }

        if(sim_time >= 28 && sim_time < 30)
        {
            dut -> A = 11;  // 1011
            dut -> B = 5;   // 0101 
            dut -> FuncCode = 13;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if (sim_time == 29 && (dut -> C == (u_int16_t)(dut -> A >> 1)))
            {
                printf("Test 15 Passed\n");
                sum++;
            }
        }

        if(sim_time >= 30 && sim_time < 32)
        {
            dut -> A = 11;  // 1011
            dut -> B = 5;   // 0101 
            dut -> FuncCode = 14;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);
            if ((sim_time == 31) && (dut -> C == (u_int16_t)~(dut -> A + 1)))
            {
                printf("Test 16 Passed\n");
                sum++;
            }

        }

        if(sim_time >= 32 && sim_time < 34)
        {
            dut -> A = 11;  // 1011
            dut -> B = 5;   // 0101 
            dut -> FuncCode = 15;
            printf("sim_time : %d  A = %d, B = %d, FuncCode = %d, Result = %d\n",sim_time, dut -> A, dut -> B, dut -> FuncCode, dut -> C);

            if ((sim_time == 33) && (dut -> C == 0))
            {
                printf("Test 17 Passed\n");
                sum++;
            }
        }

        if (sim_time >= 34 && sim_time < 36)
        {
            dut -> A = 0xFFFF;  // 16'b1111111111111111
            dut -> B = 0x8001; // 16'b1000000000000001 
            dut -> FuncCode = 0;
            printf(" overflow check\n ");
            if (sim_time == 35 && (dut ->OverflowFlag > 0))
            {
                printf("sim_time : %llu overflow!!\n", sim_time);
            }
        }

        if (sim_time >= 34 && sim_time < 36)
        {
            dut -> A = 0xFFFF;  // 16'b1111111111111111
            dut -> B = 0x8001; // 16'b1000000000000001 
            dut -> FuncCode = 0;
            printf(" overflow check\n ");
            if (sim_time == 35 && (dut ->OverflowFlag > 0))
            {
                printf("sim_time : %llu  + overflow!!\n", sim_time);
            }
        }
        
        if (sim_time >= 36 && sim_time < 38)
        {
            dut -> A = -65535;  // 16'b1111111111111111
            dut -> B = -1; // 16'b1000000000000001 
            dut -> FuncCode = 0;
            printf(" overflow check\n ");
            if (sim_time == 37 && (dut ->OverflowFlag > 0))
            {
                printf("sim_time : %llu  - overflow!!\n", sim_time);
            }
        }


        if (sum == 17)
        {
            printf(" sim_time : %llu All tests passed\n", sim_time);
        }

        


        dut->eval();
        
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}